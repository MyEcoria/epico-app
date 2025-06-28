/*
** EPITECH PROJECT, 2025
** cache_manage.dart
** File description:
** Simple cache service for storing values locally.
*/

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  Future<void> setCacheValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String?> getCacheValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<bool> containsCacheValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
