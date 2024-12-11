import 'package:flutter/material.dart';
import 'package:myapp/screens/doa_list.dart';
import 'package:myapp/screens/surah_list.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:myapp/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' show pi;

void main() => runApp(const QuranApp());

class QuranApp extends StatelessWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QursnNow',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 255, 255, 255),
          secondary: const Color.fromARGB(255, 255, 255, 255),
          background: Colors.black,
          surface: Colors.grey.shade900,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Typography.whiteMountainView.copyWith(
            bodyLarge: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            headlineMedium: TextStyle(
              color: const Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        useMaterial3: true,
      ),
      home: const LandingPage(),
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
    bool isGranted =
        await LocationPermissionHandler.handleLocationPermission(context);

    setState(() {
      _isPermissionGranted = isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 19, 20),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header Section
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 60,
                        color: const Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Qur'anNow",
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontSize: 28,
                              ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Qiblah Compass Section
                _buildQiblahSection(context),

                const SizedBox(height: 32),

                // Navigation Buttons
                _buildNavigationButtons(context),

                const SizedBox(height: 32),

                // Version Information
                Text(
                  'Powered by :',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),

                Text(
                  'Pengembangan Perangkat Lunak & Gim',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),
                Text(
                  'SMKN 1 Ciomas',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.6),
                    fontSize: 15,
                  ),
                ),

                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 255, 255, 255)
                        .withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQiblahSection(BuildContext context) {
    if (!_isPermissionGranted) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Mohon izinkan akses lokasi",
              style: TextStyle(
                color: const Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Izinkan Akses Lokasi",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }

    return FutureBuilder(
      future: FlutterQiblah.androidDeviceSensorSupport(),
      builder: (_, AsyncSnapshot<bool?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                const Color.fromARGB(255, 255, 255, 255)),
          );
        }

        if (snapshot.hasError || (snapshot.data != true)) {
          return Text(
            "Sensor tidak mendukung arah kiblat",
            style: TextStyle(
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
          );
        }

        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade900,
            border: Border.all(
              color: const Color.fromARGB(127, 255, 255, 255),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 255, 255, 255).withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const QiblahCompass(),
        );
      },
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton(
          context,
          icon: Icons.auto_stories,
          label: 'Baca Surat',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SurahListPage()),
          ),
        ),
        const SizedBox(width: 16),
        _buildNavButton(
          context,
          icon: Icons.volunteer_activism,
          label: 'Baca Doa',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoaListPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: const Color.fromARGB(255, 255, 255, 255),
            width: 1.5,
          ),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 24,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: const Color.fromARGB(255, 255, 255, 255),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// QiblahCompass widget remains mostly the same with styling updates
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
          return Center(
              child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                const Color.fromARGB(255, 255, 255, 255)),
          ));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text(
            'Error: ${snapshot.error}',
            style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
          ));
        }

        final qiblahDirection = snapshot.data!;

        return Transform.rotate(
          angle: (qiblahDirection.qiblah * (pi / 180) * -1),
          child: SvgPicture.asset(
            'assets/images/compass.svg',
            width: 200,
            height: 200,
            colorFilter: ColorFilter.mode(
                const Color.fromARGB(255, 255, 255, 255), BlendMode.srcIn),
          ),
        );
      },
    );
  }
}
