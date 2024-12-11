import 'package:flutter/material.dart';
import 'screens/home.dart'; // Pastikan untuk mengganti dengan halaman utama yang sesuai

void main() {
  runApp(const QuranApp());
}

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuranNow',
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
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  // Fungsi untuk berpindah ke halaman utama setelah delay
  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // Splash Screen selama 3 detik
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LandingPage()), // Gantilah dengan halaman utama aplikasi Anda
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 20),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau ikon yang Anda inginkan
            Icon(
              Icons.menu_book_rounded,
              size: 100,
              color: const Color.fromARGB(255, 255, 255, 255),
            ),
            SizedBox(height: 20),
            // Teks atau nama aplikasi
            Text(
              "Qur'anNow'",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            SizedBox(height: 20),
            // Menampilkan loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  const Color.fromARGB(255, 255, 255, 255)!),
            ),
          ],
        ),
      ),
    );
  }
}
