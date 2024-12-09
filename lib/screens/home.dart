import 'package:flutter/material.dart';
import 'package:myapp/screens/doa_list.dart';
import 'package:myapp/screens/surah_list.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/permission_handler.dart';
import 'dart:async';
import 'dart:math' show pi;

void main() => runApp(const QuranApp());

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
      home: const LandingPage(),
    );
  }
}

class QiblahCompass extends StatefulWidget {
  const QiblahCompass({Key? key}) : super(key: key);

  @override
  State<QiblahCompass> createState() => _QiblahCompassState();
}

class _QiblahCompassState extends State<QiblahCompass> {
  final _streamController = StreamController<QiblahDirection>();

  @override
  void initState() {
    super.initState();
    _streamController.addStream(FlutterQiblah.qiblahStream);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: _streamController.stream,
      builder: (context, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final qiblahDirection = snapshot.data!;
        
        return Container(
          width: 200,
          height: 200,
          child: Transform.rotate(
            angle: (qiblahDirection.qiblah * (pi / 180) * -1),
            child: SvgPicture.asset(
              'assets/images/compass.svg',
              width: 200,
              height: 200,
            ),
          ),
        );
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}
class _LandingPageState extends State<LandingPage> {
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    // Periksa status permission
    bool isGranted = await LocationPermissionHandler.handleLocationPermission(context);

    // Jika granted, perbarui state
    setState(() {
      _isPermissionGranted = isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.purple,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo atau ikon
              Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Colors.purple[200],
              ),
              SizedBox(height: 20),

              // Judul
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Al-Qur'an Digital\n",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[200],
                        letterSpacing: 1.5,
                      ),
                    ),
                    TextSpan(
                      text: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple[100],
                        height: 2,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Kompas atau status permission
              if (_isPermissionGranted)
                FutureBuilder(
                  future: FlutterQiblah.androidDeviceSensorSupport(),
                  builder: (_, AsyncSnapshot<bool?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(
                        color: Colors.purple[200],
                      );
                    }
                    if (snapshot.hasError || (snapshot.data != true)) {
                      return Text(
                        "Sensor tidak mendukung arah kiblat",
                        style: TextStyle(color: Colors.purple[200]),
                      );
                    }
                    return Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.only(bottom: 30),
                      decoration: BoxDecoration(
                        color: Colors.purple[700],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const QiblahCompass(),
                    );
                  },
                )
              else
                Column(
                  children: [
                    Text(
                      "Mohon izinkan akses lokasi untuk melihat arah Kiblat",
                      style: TextStyle(color: Colors.purple[200]),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _checkPermission,
                      child: Text("Izinkan Akses Lokasi"),
                    ),
                  ],
                ),
              SizedBox(height: 30),

              // Tombol Baca Surat dan Baca Doa
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol Baca Surat
                    SizedBox(
                      width: 150,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahListPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_stories,
                              color: Colors.purple[100],
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Baca Surat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tombol Baca Doa
                    SizedBox(
                      width: 150,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoaListPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 112, 20, 140),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.volunteer_activism,
                              color: Colors.purple[100],
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Baca Doa',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[100],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Informasi versi atau pengembang
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Text(
                  'Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.purple[200]?.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
