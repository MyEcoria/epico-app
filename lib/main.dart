/*
** EPITECH PROJECT, 2025
** main.dart
** File description:
** Main entry point for the Epico.
** This file initializes the Flutter application and handles
** the authentication state to determine which screen to display.
** It uses Flutter Secure Storage to securely store authentication tokens.
** The app displays a loading indicator while checking authentication status.
** If authenticated, it navigates to the MusicAppHomePage; otherwise, it shows the HomePage.
*/

import 'package:flutter/material.dart';
import 'screens/auth/home_page.dart';
import 'screens/listen_page.dart';
import 'theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'manage/song_manage.dart';
import 'manage/api_manage.dart';
import 'manage/cache_manage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Secure storage for authentication cookies.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  /// Indicates if the app is currently loading authentication status.
  bool _isLoading = true;
  /// Indicates if the user is authenticated.
  bool _isAuthenticated = false;
  /// Cache service for storing application data.
  CacheService cache = CacheService();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    MusicApiService().getMe();
  }



  Future<void> _checkAuthentication() async {
    final authCookie = await _secureStorage.read(key: 'auth');
    if (authCookie != null) {
      try {
        final userInfo = await MusicApiService().userInfo(authCookie);
        cache.setCacheValue('email', userInfo['email']);
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epico',
      theme: appTheme,
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isAuthenticated ? MusicAppHomePage(songManager: SongManager()) : const HomePage(),
    );
  }
}