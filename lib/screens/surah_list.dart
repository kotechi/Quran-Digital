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
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
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
    final String jsonString = await rootBundle.loadString('assets/quran_data.json');
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: "Al-Qur'an digital\n",
                style: TextStyle(
                  color: Colors.purple[200], 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: "Mobile",
                style: TextStyle(
                  color: Colors.purple[200], 
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.purple[700],
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
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Cari Surat...',
                hintStyle: TextStyle(color: Colors.purple[200]?.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.purple[200]),
                suffixIcon: _isSearching
                  ? IconButton(
                      icon: Icon(Icons.clear, color: Colors.purple[200]),
                      onPressed: _clearSearch,
                    )
                  : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.purple[200]!, width: 1.5),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[200]!),
            ),
          )
        : errorMessage.isNotEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 50,
                    ),
                    SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: fetchSurahs,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[700],
                      ),
                      child: Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : filteredSurahs.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada surah ditemukan',
                      style: TextStyle(
                        color: Colors.purple[200],
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
                          color: Colors.grey[900],
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
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple[700],
                            child: Text(
                              '${surah.number}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            surah.transliterationId,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[200],
                            ),
                          ),
                          subtitle: Text(
                            '${surah.translationId} - ${surah.totalVerses} ayat',
                            style: TextStyle(
                              color: Colors.purple[100],
                            ),
                          ),
                          trailing: Text(
                            surah.arabicName,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SurahDetail(surah: surah),
                              )
                            );
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