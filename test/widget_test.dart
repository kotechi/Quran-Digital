import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TafsirPage extends StatefulWidget {
  final String nomor;
  const TafsirPage({super.key, required this.nomor});

  @override
  _TafsirPageState createState() => _TafsirPageState();
}

class _TafsirPageState extends State<TafsirPage> {
  late Future<Map<String, dynamic>> tafsirData;

  Future<Map<String, dynamic>> fetchTafsir() async {
    final response = await http.get(Uri.parse('https://equran.id/api/v2/tafsir/${widget.nomor}'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tafsir');
    }
  }

  @override
  void initState() {
    super.initState();
    tafsirData = fetchTafsir(); // Memanggil fungsi untuk mengambil data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tafsir Surah ${widget.nomor}')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: tafsirData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('No Data Available'));
          } else {
            // Menampilkan data tafsir
            final tafsir = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Text('Tafsir: ${tafsir['tafsir']}', style: TextStyle(fontSize: 18)),
                  // Tambahkan widget lainnya sesuai struktur data API
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
