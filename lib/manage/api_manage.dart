import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MusicApiService {
  static const String baseUrl = 'http://192.168.1.53:3000';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

    Future<Map<String, dynamic>> getMe() async {
      try {
        final response = await http.get(Uri.parse('$baseUrl/me'));
        if (response.statusCode == 200) {
          dynamic data = json.decode(response.body);
          await _secureStorage.write(key: 'name', value: data['name']);
          await _secureStorage.write(key: 'email', value: data['email']);
          return data;
        } else {
          throw Exception('Failed to load user data: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching user data: $e');
      }
    }

  Future<List<Map<String, dynamic>>> getLatestTracks() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/latest'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load latest tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching latest tracks: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getForYouTracks() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/for-you'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load for-you tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching for-you tracks: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getFollowTracks() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/follow'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load follow tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching follow tracks: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getNewReleases() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/releases'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load new releases: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching new releases: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendedPlaylist() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/recommended'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load for-you tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching for-you tracks: $e');
    }
  }
}