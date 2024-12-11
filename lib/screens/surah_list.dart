import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:myapp/models/surah.dart';
import 'package:flutter/services.dart' show rootBundle;

// Import the SurahDetail screen
import 'package:myapp/screens/surah_detail.dart';

void main() {
  runApp(QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al-Quran App',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.blueGrey.shade50,
        scaffoldBackgroundColor: Colors.blueGrey.shade100,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blueGrey.shade50,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.blueGrey.shade900),
          bodyMedium: TextStyle(color: Colors.blueGrey.shade900),
        ),
      ),
      home: SurahListPage(),
    );
  }
}

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  _SurahListPageState createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  List<Surah> surahs = [];
  List<Surah> filteredSurahs = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchSurahs();
  }

  Future<void> fetchSurahs() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final String jsonString =
          await rootBundle.loadString('assets/quran_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      if (data['data'] != null) {
        setState(() {
          surahs = (data['data'] as List)
              .map((surahJson) => Surah.fromJson(surahJson))
              .toList();
          filteredSurahs = surahs; // Initially, all surahs are shown
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Tidak ada data surah yang ditemukan';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _filterSurahs(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      filteredSurahs = surahs.where((surah) {
        // Enhanced search with multiple criteria
        final lowercaseQuery = query.toLowerCase();
        return surah.longName.toLowerCase().contains(lowercaseQuery) ||
            surah.transliterationId.toLowerCase().contains(lowercaseQuery) ||
            surah.number.toString().contains(lowercaseQuery) ||
            surah.arabicName.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filterSurahs('');
      _isSearching = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 20),
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "Al-Qur'an digital\n",
                style: TextStyle(
                  color: Colors.blueGrey.shade900,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: "List Surat",
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade50,
        iconTheme: IconThemeData(color: Colors.blueGrey.shade900),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.blueGrey.shade200,
            height: 1.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.blueGrey.shade900, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blueGrey.shade50,
                hintText: 'Cari Surat...',
                hintStyle: TextStyle(color: Colors.blueGrey.shade400),
                prefixIcon: Icon(Icons.search, color: Colors.blueGrey.shade600),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.blueGrey.shade600),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.blueGrey.shade300, width: 1.5),
                ),
              ),
              onChanged: _filterSurahs,
            ),
          ),

          // Surah List
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blueGrey.shade300),
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMessage,
                              style: TextStyle(color: Colors.blueGrey.shade900),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: fetchSurahs,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade200,
                              ),
                              child: Text('Coba Lagi', style: TextStyle(color: Colors.blueGrey.shade900)),
                            ),
                          ],
                        ),
                      )
                    : filteredSurahs.isEmpty
                        ? Center(
                            child: Text(
                              'Tidak ada surah ditemukan',
                              style: TextStyle(
                                color: Colors.blueGrey.shade900,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredSurahs.length,
                            itemBuilder: (context, index) {
                              final surah = filteredSurahs[index];
                              return Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.blueGrey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blueGrey.shade200,
                                    child: Text(
                                      '${surah.number}',
                                      style: TextStyle(
                                        color: Colors.blueGrey.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    surah.transliterationId,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey.shade900,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${surah.translationId} - ${surah.totalVerses} ayat',
                                    style: TextStyle(
                                      color: Colors.blueGrey.shade700,
                                    ),
                                  ),
                                  trailing: Text(
                                    surah.arabicName,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.blueGrey.shade900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SurahDetail(surah: surah),
                                        ));
                                  },
                                ),
                              );
                            },
                          ),
          )
        ],
      ),
    );
  }
}