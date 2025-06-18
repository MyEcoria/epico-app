/*
** EPITECH PROJECT, 2025
** home_page.dart
** File description:
** Home page for the Deezer app.
** This file contains the UI and logic for the home screen.
** It handles authentication checks and navigation to the appropriate screens.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:epico/screens/auth/email_page.dart';
import 'package:epico/screens/auth/login_page.dart';
import 'package:epico/screens/listen_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:epico/manage/song_manage.dart';
import 'package:epico/manage/api_manage.dart';
import 'package:epico/manage/cache_manage.dart';
import '../../logger.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final SongManager songManager = SongManager();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  CacheService cache = CacheService();

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
      try {
        final userInfo = await MusicApiService().userInfo(authToken);
        cache.setCacheValue('email', userInfo['email']);
        // If auth token exists and user info is valid, navigate to listen page
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => MusicAppHomePage(songManager: songManager)),
        );
      } catch (e) {
        AppLogger.log('Error fetching user info: $e');
      }
    } else {
      AppLogger.log('No auth token found');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
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
                  color: CupertinoColors.white,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              // Buttons
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => EmailScreen()),
                  );
                },
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                borderRadius: BorderRadius.circular(25),
                child: const Text(
                  'Sign up',
                  style: TextStyle(color: CupertinoColors.black),
                ),
              ),
              SizedBox(height: 16),
              CupertinoButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => LoginPage()),
                  );
                },
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: const Text(
                  'Log in',
                  style: TextStyle(color: CupertinoColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
