import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:myapp/models/doa.dart';
import 'package:flutter/services.dart' show rootBundle;
class DoaListPage extends StatefulWidget {
  const DoaListPage({super.key});

  @override
  _DoaListPageState createState() => _DoaListPageState();
}

class _DoaListPageState extends State<DoaListPage> {
  List<Doa> duas = [];
  List<Doa> filteredDuas = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchDuas();
  }

  /// Mengambil data doa dari API
Future<void> fetchDuas() async {
  setState(() {
    isLoading = true;
    errorMessage = '';
  });

  try {
    // Membaca file JSON lokal dari assets
    final String response = await rootBundle.loadString('assets/doa.json');
    final List<dynamic> data = json.decode(response);

    List<Doa> loadedDuas = data.map((item) => Doa.fromJson(item)).toList();

    setState(() {
      duas = loadedDuas;
      filteredDuas = loadedDuas;
      isLoading = false;
    });
  } catch (e) {
    setState(() {
      isLoading = false;
      errorMessage = 'Terjadi kesalahan saat memuat doa: $e';
    });
  }
}

  /// Menyaring daftar doa berdasarkan kata kunci pencarian
  void _filterDuas(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      filteredDuas = duas.where((dua) {
        final lowercaseQuery = query.toLowerCase();
        return dua.doa.toLowerCase().contains(lowercaseQuery) ||
            dua.artinya.toLowerCase().contains(lowercaseQuery);
      }).toList();
    });
  }

  /// Menghapus pencarian
  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _filterDuas('');
      _isSearching = false;
    });
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
                text: "Kumpulan Doa\n",
                style: TextStyle(
                  color: Colors.purple[200],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 18,
                ),
              ),
              TextSpan(
                text: "mobile",
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
          // Pencarian
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[900],
                hintText: 'Cari Doa...',
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
              onChanged: _filterDuas,
            ),
          ),
          // Error message jika ada
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red[300]),
              ),
            ),
          // Konten utama
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[200]!),
                    ),
                  )
                : filteredDuas.isEmpty
                    ? Center(
                        child: Text(
                          'Tidak ada doa ditemukan',
                          style: TextStyle(
                            color: Colors.purple[200],
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredDuas.length,
                        itemBuilder: (context, index) {
                          final dua = filteredDuas[index];
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            child: ExpansionTile(
                              title: Text(
                                dua.doa,
                                style: TextStyle(
                                  color: Colors.purple[200],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        dua.ayat,
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        dua.latin,
                                        style: TextStyle(
                                          color: Colors.purple[100],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        dua.artinya,
                                        style: TextStyle(
                                          color: Colors.purple[200],
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
