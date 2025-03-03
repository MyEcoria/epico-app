import 'package:flutter/material.dart';
import 'screens/auth/home_page.dart';
import 'screens/listen_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'manage/song_manage.dart'; // Update with the correct path
import 'manage/api_manage.dart'; // Update with the correct path

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    MusicApiService().getMe();
  }

  Future<void> _checkAuthentication() async {
    final authCookie = await _secureStorage.read(key: 'auth');
    setState(() {
      _isAuthenticated = authCookie != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Epico',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _isLoading 
          ? Center(child: CircularProgressIndicator()) 
          : _isAuthenticated ? MusicAppHomePage(songManager: SongManager()) : HomePage(),
    );
  }
}