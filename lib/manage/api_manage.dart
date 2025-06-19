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
  static const String baseUrl = 'http://192.168.1.53:8000';
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/info'));
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/latest'),
        headers: {'token': cookie}
        );
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
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }

  Future<Map<String, dynamic>> createSongAuth(String songId, String token) async {
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/flow/$type'),
        headers: {'token': cookie}
        );
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

  Future<List<Map<String, dynamic>>> getNewTracks(String cookie) async {
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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/from-follow'),
        headers: {'token': cookie}
        );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load from follow tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching from follow tracks: $e');
    }
  }

  Future<Map<String, dynamic>> getSearch(String cookie, String name) async {
    debugPrint("hello: $name");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/search'),
        headers: {'Content-Type': 'application/json', 'token': cookie},
        body: json.encode({'name': name}),
      );
      debugPrint("Search response: ${response.body}");
      
      // Retourner l'objet complet au lieu d'une liste
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Error fetching search results: $e');
    }
  }

  Future<Map<String, dynamic>> createLike(String songId, String token) async {
    debugPrint("hello: $songId/$token");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/liked'),
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

  Future<bool> isLike(String songId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/is-liked'),
        headers: {'Content-Type': 'application/json', 'token': token},
        body: json.encode({'song_id': songId}),
      );
      if (response.statusCode == 200) {
        final rep = json.decode(response.body);
        debugPrint("rep: $rep");
        if (rep["liked"] == "true") {
          return true;
        } else {
          return false;
        }
      } else {
        throw Exception('Failed to create auth user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error create auth user: $e');
    }
  }

  Future<Map<String, dynamic>> yourArtist(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/your-artist'),
        headers: {'Content-Type': 'application/json', 'token': token},
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

  Future<String> countLiked(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/count-liked'),
        headers: {'Content-Type': 'application/json', 'token': token},
      );
      debugPrint("response: ${response.body}");
      if (response.statusCode == 200) {
        return json.decode(response.body)["count"].toString();
      } else {
        throw Exception('Failed to create auth user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error create auth user: $e');
    }
  }

  Future<String> countFollow(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/count-follow'),
        headers: {'Content-Type': 'application/json', 'token': token},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)["count"].toString();
      } else {
        throw Exception('Failed to create auth user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error create auth user: $e');
    }
  }

  Future<Map<String, dynamic>> getAlbumInfo(String albumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/music/album/$albumId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load album info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching album info: $e');
    }
  }

  Future<Map<String, dynamic>> getArtistInfo(String artistId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/music/artist/$artistId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load artist info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching artist info: $e');
    }
  }
}
