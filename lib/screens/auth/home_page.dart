/*
** EPITECH PROJECT, 2025
** home_page.dart
** File description:
** Home page for the Deezer app.
** This file contains the UI and logic for the home screen.
** It handles authentication checks and navigation to the appropriate screens.
*/

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:epico/screens/auth/email_page.dart';
import 'package:epico/screens/auth/login_page.dart';
import 'package:epico/screens/listen_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:epico/manage/song_manage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SongManager songManager = SongManager();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authToken = await _storage.read(key: 'auth');
    if (authToken != null) {
      // If auth token exists, navigate to listen page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MusicAppHomePage(songManager: songManager)),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'For epitech students',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              // Buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('Sign up'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
