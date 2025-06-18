/*
** EPITECH PROJECT, 2025
** main.dart
** File description:
** Main entry point for the Deezer app.
** This file initializes the Flutter application and handles
** the authentication state to determine which screen to display.
** It uses Flutter Secure Storage to securely store authentication tokens.
** The app displays a loading indicator while checking authentication status.
** If authenticated, it navigates to the MusicAppHomePage; otherwise, it shows the HomePage.
*/

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart' show DefaultMaterialLocalizations;
import 'screens/auth/home_page.dart';
import 'screens/listen_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'manage/song_manage.dart';
import 'manage/api_manage.dart';
import 'manage/cache_manage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLoading = true;
  bool _isAuthenticated = false;
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
    return CupertinoApp(
      title: 'Epico',
      theme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: CupertinoColors.activeBlue,
        textTheme: CupertinoTextThemeData(
          textStyle: TextStyle(fontFamily: '.SF Pro Text'),
        ),
      ),
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
      ],
      home: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _isAuthenticated
              ? MusicAppHomePage(songManager: SongManager())
              : HomePage(),
    );
  }
}
