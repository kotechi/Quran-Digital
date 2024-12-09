import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://api.equran.id/api/v2/surat";

  Future<List<dynamic>> fetchSurahs() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/surat"));
      
      if (response.statusCode == 200) {
        return json.decode(response.body)['data']; // Pastikan struktur ini sesuai dengan respons API
      } else {
        throw Exception("Failed to load surahs: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Client Exception: $e");
    }
  }
}
