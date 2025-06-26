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
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/music/search'),
        headers: {'Content-Type': 'application/json', 'token': cookie},
        body: json.encode({'name': name}),
      );
      // Retourner l'objet complet au lieu d'une liste
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } catch (e) {
      throw Exception('Error fetching search results: $e');
    }
  }

  Future<Map<String, dynamic>> createLike(String songId, String token) async {
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

  Future<List<Map<String, dynamic>>> getLikedSongs(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/music/liked'),
        headers: {'token': token},
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load liked songs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching liked songs: $e');
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

  Future<List<Map<String, dynamic>>> getAlbumTracks(String albumId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/music/album_track/$albumId'),
      );
      if (response.statusCode == 200) {
        dynamic data = json.decode(response.body);
        debugPrint('Raw album tracks data: ${data.toString()}');
        
        // Vérifier si data est une Map ou une List
        if (data is Map<String, dynamic>) {
          // Si c'est une Map, chercher une clé qui contient les pistes
          // Les clés possibles peuvent être 'tracks', 'data', 'songs', etc.
          if (data.containsKey('tracks') && data['tracks'] is List) {
            List<dynamic> tracks = data['tracks'];
            return tracks.map((item) => item as Map<String, dynamic>).toList();
          } else if (data.containsKey('data') && data['data'] is List) {
            List<dynamic> tracks = data['data'];
            return tracks.map((item) => item as Map<String, dynamic>).toList();
          } else if (data.containsKey('songs') && data['songs'] is List) {
            List<dynamic> tracks = data['songs'];
            return tracks.map((item) => item as Map<String, dynamic>).toList();
          } else {
            // Si aucune clé connue n'est trouvée, convertir les valeurs de la Map en List
            List<Map<String, dynamic>> tracks = [];
            data.forEach((key, value) {
              if (value is Map<String, dynamic>) {
                tracks.add(value);
              } else if (value is List) {
                for (var item in value) {
                  if (item is Map<String, dynamic>) {
                    tracks.add(item);
                  }
                }
              }
            });
            return tracks;
          }
        } else if (data is List) {
          // Si c'est déjà une List, la traiter normalement
          return data.map((item) => item as Map<String, dynamic>).toList();
        } else {
          debugPrint('Unexpected data type: ${data.runtimeType}');
          return [];
        }
      } else {
        throw Exception('Failed to load album tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching album tracks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getArtistTracks(String artistId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/music/artist_tracks/$artistId'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load artist tracks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching artist tracks: $e');
    }
  }
}
