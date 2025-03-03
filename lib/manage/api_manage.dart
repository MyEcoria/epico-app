import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicApiService {
  static const String baseUrl = 'http://192.168.1.53:3000';
  
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
}