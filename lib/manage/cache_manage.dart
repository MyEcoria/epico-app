/*
** EPITECH PROJECT, 2025
** cache_manage.dart
** File description:
** Simple cache service for storing values locally.
*/

import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  // Fonction pour enregistrer une donnée dans le cache
  Future<void> setCacheValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Fonction pour récupérer une donnée du cache
  Future<String?> getCacheValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);  // Retourne null si la clé n'existe pas
  }

  // Fonction pour vérifier si une donnée existe dans le cache
  Future<bool> containsCacheValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
