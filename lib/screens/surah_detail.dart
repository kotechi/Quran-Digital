import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models/surah.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class SurahDetail extends StatefulWidget {
  final Surah surah;

  const SurahDetail({super.key, required this.surah});

  @override
  _SurahDetailState createState() => _SurahDetailState();
}

class _SurahDetailState extends State<SurahDetail> {
  List<dynamic> verses = [];
  bool isLoading = true;
  bool isDownloaded = false;
  bool isDownloading = false;
  String errorMessage = '';
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int currentPlayingVerse = -1;
  List<String> audioUrls = [];
  bool isAutoPlaying = false;
  Set<int> favoriteVerses = {};

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      checkIfDownloaded();
    }
    fetchSurahVerses();
    setupAudioPlayer();
    loadFavorites();
    saveLastReadSurah(widget.surah.number);
  }

  
Future<void> loadFavorites() async {
  if (kIsWeb) {
    // Use window.localStorage for web (you'll need to use a web-specific package)
    // For now, we'll use SharedPreferences for all platforms
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites_${widget.surah.number}') ?? [];
    setState(() {
      favoriteVerses = favorites.map((e) => int.parse(e)).toSet();
    });
  } else {
    // Use SharedPreferences for mobile
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('favorites_${widget.surah.number}') ?? [];
    setState(() {
      favoriteVerses = favorites.map((e) => int.parse(e)).toSet();
    });
  }
}
  
Future<void> saveFavorites() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
    'favorites_${widget.surah.number}',
    favoriteVerses.map((e) => e.toString()).toList(),
  );
}


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
  Future<void> toggleFavorite(int verseIndex) async {
    setState(() {
      if (favoriteVerses.contains(verseIndex)) {
        favoriteVerses.remove(verseIndex);
      } else {
        favoriteVerses.add(verseIndex);
      }
    });
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites_${widget.surah.number}',
      favoriteVerses.map((e) => e.toString()).toList(),
    );
  }


  Future<void> saveLastReadSurah(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_read_surah', surahNumber);
  }

  Future<void> setupAudioPlayer() async {
    audioPlayer.onPlayerComplete.listen((event) {
      if (isAutoPlaying && currentPlayingVerse < verses.length - 1) {
        setState(() {
          currentPlayingVerse++;
        });
        playAudio(audioUrls[currentPlayingVerse]);
      } else {
        setState(() {
          isPlaying = false;
          isAutoPlaying = false;
          currentPlayingVerse = -1;
        });
      }
    });
  }

  Future<void> saveToLocalStorage(String data) async {
    if (!kIsWeb) {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/surah_${widget.surah.number}.json');
        await file.writeAsString(data);
      } catch (e) {
        print('Error saving to local storage: $e');
      }
    }
  }

  Future<void> fetchSurahVerses() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('https://api.quran.gading.dev/surah/${widget.surah.number}'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['data'] != null && data['data']['verses'] != null) {
          setState(() {
            verses = data['data']['verses'];
            audioUrls = verses.map<String>((verse) => verse['audio']['primary'] ?? '').toList();
            isLoading = false;
          });

          // Simpan data ke storage lokal jika bukan web
          if (!kIsWeb) {
            saveToLocalStorage(response.body);
          }
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Gagal mengambil data';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
      print('Error in fetchSurahVerses: $e');
    }
  }

  Future<void> downloadSurah() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.quran.gading.dev/surah/${widget.surah.number}'),
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/surah_${widget.surah.number}.json');
        
        await file.writeAsString(response.body);

        // Download audio files
        final audioDir = Directory('${dir.path}/audio_${widget.surah.number}');
        if (!await audioDir.exists()) {
          await audioDir.create(recursive: true);
        }

        for (var verse in verses) {
          final audioUrl = verse['audio']['primary'];
          if (audioUrl != null) {
            final audioResponse = await http.get(Uri.parse(audioUrl));
            if (audioResponse.statusCode == 200) {
              final audioFile = File(
                '${audioDir.path}/verse_${verse['number']['inSurah']}.mp3',
              );
              await audioFile.writeAsBytes(audioResponse.bodyBytes);
            }
          }
        }

        setState(() {
          isDownloaded = true;
          isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
        errorMessage = 'Gagal mengunduh: $e';
      });
    }
  }

  Future<void> downloadSurahData() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.quran.gading.dev/surah/${widget.surah.number}'),
      );

      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/surah_${widget.surah.number}.json');
        await file.writeAsString(response.body);

        setState(() {
          isDownloaded = true;
          isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        isDownloading = false;
        errorMessage = 'Gagal mengunduh: $e';
      });
    }
  }

  Future<void> downloadSurahAudio() async {
    if (isDownloading) return;

    setState(() {
      isDownloading = true;
    });

    try {
      final dir = await getApplicationDocumentsDirectory();
      final audioDir = Directory('${dir.path}/audio_${widget.surah.number}');
      if (!await audioDir.exists()) {
        await audioDir.create(recursive: true);
      }

      for (var verse in verses) {
        final audioUrl = verse['audio']['primary'];
        if (audioUrl != null) {
          final audioResponse = await http.get(Uri.parse(audioUrl));
          if (audioResponse.statusCode == 200) {
            final audioFile = File(
              '${audioDir.path}/verse_${verse['number']['inSurah']}.mp3',
            );
            await audioFile.writeAsBytes(audioResponse.bodyBytes);
          }
        }
      }

      setState(() {
        isDownloaded = true;
        isDownloading = false;
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
        errorMessage = 'Gagal mengunduh audio: $e';
      });
    }
  }

  Future<void> deleteSurah() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/surah_${widget.surah.number}.json');
      final audioDir = Directory('${dir.path}/audio_${widget.surah.number}');

      if (await file.exists()) {
        await file.delete();
      }
      if (await audioDir.exists()) {
        await audioDir.delete(recursive: true);
      }

      setState(() {
        isDownloaded = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> checkIfDownloaded() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/surah_${widget.surah.number}.json');
    setState(() {
      isDownloaded = file.existsSync();
    });
  }

  Future<void> playAudio(String audioUrl) async {
    try {
      if (audioUrl.startsWith('http')) {
        // Mainkan dari URL online
        await audioPlayer.play(UrlSource(audioUrl));
      } else {
        // Mainkan dari file lokal
        final file = File(audioUrl);
        if (await file.exists()) {
          await audioPlayer.play(DeviceFileSource(file.path));
        } else {
          throw 'File not found: $audioUrl';
        }
      }
      setState(() {
        isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error playing audio: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> togglePlayAll() async {
    if (isPlaying) {
      await audioPlayer.stop();
      setState(() {
        isPlaying = false;
        isAutoPlaying = false;
        currentPlayingVerse = -1;
      });
    } else {
      setState(() {
        isAutoPlaying = true;
        currentPlayingVerse = 0;
      });
      playAudio(audioUrls[0]);
    }
  }

  Widget buildVerseTile(int index, Map<String, dynamic> verse) {
    final isCurrentVerse = currentPlayingVerse == index && isPlaying;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isCurrentVerse ? Colors.purple.withOpacity(0.2) : Colors.grey[900],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.purple[700]!.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple[900]!.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    favoriteVerses.contains(index)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favoriteVerses.contains(index)
                        ? Colors.purple[700]
                        : Colors.grey,
                  ),
                  onPressed: () => toggleFavorite(index),
                ),
                Text(
                  'Ayat ${verse['number']['inSurah']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCurrentVerse ? Colors.white : Colors.purple[300],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Text(
              verse['text']['arab'] ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple[200],
              ),
            ),
            SizedBox(height: 10),
            Text(
              verse['text']['transliteration']['en'] ?? 'Tidak ada transliterasi',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                color: Colors.purple[200],
              ),
            ),
            SizedBox(height: 15),
            Text(
              verse['translation']['id'] ?? '',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.purple[100],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          '${widget.surah.transliterationId} (${widget.surah.arabicName})',
          style: TextStyle(
            color: Colors.purple[200],
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!kIsWeb) // Cek apakah bukan platform web
            IconButton(
              icon: Icon(
                isDownloaded
                    ? Icons.download_done
                    : isDownloading
                        ? Icons.downloading
                        : Icons.download,
                color: Colors.purple[200],
              ),
              onPressed: isDownloading ? null : () => showDownloadOptionsDialog(),
            ),
          // Tombol play/pause dan tafsir tetap ada
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              color: Colors.purple[200],
            ),
            onPressed: togglePlayAll,
          ),
          IconButton(
            icon: Icon(
              Icons.book,
              color: Colors.purple[200],
            ),
            onPressed: () => showTafsirDialog(),
          ),
        ],
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.purple[700],
            height: 1.5,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[200]!),
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    final verse = verses[index];
                    return buildVerseTile(index, verse);
                  },
                ),
    );
  }
  void showDownloadOptionsDialog() {
    if (kIsWeb) {
      // Jika dijalankan di web, tampilkan dialog hanya dengan pesan.
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Fitur Unduh Tidak Tersedia di Web',
              style: TextStyle(color: Colors.purple[200]),
            ),
            content: Text(
              'Fitur unduh hanya tersedia di aplikasi seluler.',
              style: TextStyle(color: Colors.purple[100]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Tutup',
                  style: TextStyle(color: Colors.purple[200]),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Untuk platform non-web, tetap tampilkan dialog unduhan
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Pilih Jenis Unduhan',
              style: TextStyle(color: Colors.purple[200]),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Unduh Surah Saja',
                    style: TextStyle(color: Colors.purple[200]),
                  ),
                  leading: Icon(Icons.book, color: Colors.purple[200]),
                  onTap: () {
                    Navigator.of(context).pop();
                    downloadSurahData(); // Fungsi untuk mengunduh surah saja
                  },
                ),
                ListTile(
                  title: Text(
                    'Unduh Audio Saja',
                    style: TextStyle(color: Colors.purple[200]),
                  ),
                  leading: Icon(Icons.audiotrack, color: Colors.purple[200]),
                  onTap: () {
                    Navigator.of(context).pop();
                    downloadSurahAudio(); // Fungsi untuk mengunduh audio saja
                  },
                ),
                ListTile(
                  title: Text(
                    'Unduh Keduanya',
                    style: TextStyle(color: Colors.purple[200]),
                  ),
                  leading: Icon(Icons.cloud_download, color: Colors.purple[200]),
                  onTap: () {
                    Navigator.of(context).pop();
                    downloadSurah(); // Fungsi untuk mengunduh surah dan audio
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Batal',
                  style: TextStyle(color: Colors.purple[200]),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void showNoConnectionDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.black87,
        title: Text(
          'Koneksi Internet',
          style: TextStyle(color: Colors.purple[200]),
        ),
        content: Text(
          'Tidak ada koneksi internet. Silakan aktifkan data seluler atau Wi-Fi Anda.',
          style: TextStyle(color: Colors.purple[100]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: TextStyle(color: Colors.purple[200]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              fetchSurahVerses(); // Coba lagi setelah menyalakan internet
            },
            child: Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.purple[200]),
            ),
          ),
        ],
      );
    },
  );
}


  void showTafsirDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 36, 9, 49),
                  const Color.fromARGB(255, 35, 33, 36)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tafsir Surat ${widget.surah.transliterationId}',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 233, 195, 225),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    widget.surah.tafsirId,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 188, 166, 194),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.justify,
                  ),
SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 161, 25, 199),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}