/*
** EPITECH PROJECT, 2025
** song_manager.dart
** File description:
** Manages the playback of songs, including queue and history management.
** This file contains methods to play, pause, add to queue, and manage the playback state.
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

}
