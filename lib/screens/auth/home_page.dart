/*
** EPITECH PROJECT, 2025
** home_page.dart
** File description:
** Home page for the Epico.
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
import 'package:epico/manage/api_manage.dart';
import 'package:epico/manage/cache_manage.dart';
import 'package:epico/manage/navigation_helper.dart';
import '../../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final SongManager songManager = SongManager();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  CacheService cache = CacheService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final authToken = await _storage.read(key: 'auth');
    if (authToken != null) {
      try {
        final userInfo = await MusicApiService().userInfo(authToken);
        cache.setCacheValue('email', userInfo['email']);
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MusicAppHomePage(songManager: songManager)),
          );
        }
      } catch (e) {
        debugPrint('Error fetching user info: $e');
      }
    } else {
      debugPrint('No auth token found');
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
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color(0xFF121212)],
            ),
          ),
          padding: const EdgeInsets.all(50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ScaleTransition(
                scale: _animation,
                child: SvgPicture.asset(
                  'assets/illustrator/fox_mascot.svg',
                  height: 120,
                  width: 120,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Epico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'For epitech students',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  NavigationHelper.pushFade(context, const EmailScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text('Sign up'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  NavigationHelper.pushFade(context, const LoginPage());
                },
                style: TextButton.styleFrom(
                  foregroundColor: kAccentColor,
                ),
                child: const Text('Log in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}