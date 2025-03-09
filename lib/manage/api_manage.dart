/*
** EPITECH PROJECT, 2025
** music_api_service.dart
** File description:
** Service class for handling API requests related to music data.
** This file contains methods to fetch user data, latest tracks,
** tracks for you, followed tracks, new releases, and recommended playlists.
** It uses Flutter Secure Storage to securely store user information.
*/

import 'dart:convert';
import 'package:flutter/material.dart';
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

  Future<List<Map<String, dynamic>>> getLatestTracks(String cookie) async {
    debugPrint('Cookie: $cookie');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/latest'),
        headers: {'token': cookie}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Latest tracks: $data');
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load latest tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching latest tracks: $e');
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
        throw Exception('Failed to load recommended playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching recommended playlists: $e');
    }
  }

  Future<Map<String, dynamic>> createUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to login user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error logining user: $e');
    }
  }

  Future<Map<String, dynamic>> userInfo(String cookie) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/info'),
        headers: {'token': cookie},
      );
      if (response.statusCode == 200) {
        debugPrint('User info: ${response.body}');
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  Future<Map<String, dynamic>> createSongAuth(String songId, String token) async {
    debugPrint('Creating song auth for song: $songId');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/auth'),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: json.encode({'song_id': songId}),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create auth user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error create auth user: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFlow(String cookie, String type) async {
    debugPrint('Cookie: $cookie');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/flow/$type'),
        headers: {'token': cookie}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Latest New: ${data.length}');
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load latest tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching latest tracks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getNewTracks(String cookie) async {
    debugPrint('Cookie: $cookie');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/new'),
        headers: {'token': cookie}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load new tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching new tracks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getForYouTrack(String cookie) async {
    debugPrint('Cookie: $cookie');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/for-you'),
        headers: {'token': cookie}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load for-you tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching new for you: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFromFollow(String cookie) async {
    debugPrint('Cookie: $cookie');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/from-follow'),
        headers: {'token': cookie}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        debugPrint('Latest tracks: $data');
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load from follow tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching from follow tracks: $e');
    }
  }
}
