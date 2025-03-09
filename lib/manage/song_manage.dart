/*
** EPITECH PROJECT, 2025
** song_manager.dart
** File description:
** Manages the playback of songs, including queue and history management.
** This file contains methods to play, pause, add to queue, and manage the playback state.
*/

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_manage.dart';

class SongManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static bool playing = false;
  bool _isPlaying = false;
  String? _currentSongName;
  String? _currentSongUrl;
  String? _currentPictureUrl;
  String? _currentDescription;
  String? _currentArtist;
  String? _currentSongId;

  final List<Map<String, dynamic>> _queue = [];
  static int _queueIndex = 0;

  AudioPlayer getAudioPlayer() {
    return _audioPlayer;
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  bool isPlayingSong(String songUrl) {
    return _currentSongUrl == songUrl;
  }

  bool isPaused() {
    return _audioPlayer.state == PlayerState.paused;
  }

  bool isPausedSong(String songUrl) {
    return _currentSongUrl == songUrl && _audioPlayer.state == PlayerState.paused;
  }

  Stream<bool> get isPlayingStream => _audioPlayer.onPlayerStateChanged.map((state) => state == PlayerState.playing);
  Stream<bool> get isPausedStream => _audioPlayer.onPlayerStateChanged.map((state) => state == PlayerState.paused);
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;
  Stream<Map<String, dynamic>> get songStateStream => _audioPlayer.onPlayerStateChanged.map((state) => getSongState());

  void addToQueue({
    required String name,
    required String description,
    required String songUrl,
    required String pictureUrl,
    required String artist,
    required String songId,
  }) {
    _queue.add({
      'name': name,
      'description': description,
      'songUrl': songUrl,
      'pictureUrl': pictureUrl,
      'artist': artist,
      'songId': songId,
    });
  }

  List<Map<String, dynamic>> getQueue() {
    return _queue;
  }

  void clearQueue() {
    _queue.clear();
    _queueIndex = 0;
  }

  Future<void> playNextInQueue() async {
    if (_queueIndex < _queue.length - 1) {
      _queueIndex++;
      await togglePlaySong(
        name: _queue[_queueIndex]['name'],
        description: _queue[_queueIndex]['description'],
        songUrl: _queue[_queueIndex]['songUrl'],
        pictureUrl: _queue[_queueIndex]['pictureUrl'],
        artist: _queue[_queueIndex]['artist'],
        songId: _queue[_queueIndex]['songId'],
        instant: true,
      );
    } else {
      debugPrint('No more songs in the queue.');
    }
  }

  Future<void> playLastFromQueue() async {
    if (_queueIndex == 0) {
      return;
    }
    _queueIndex--;
    await togglePlaySong(
      name: _queue[_queueIndex]['name'],
      description: _queue[_queueIndex]['description'],
      songUrl: _queue[_queueIndex]['songUrl'],
      pictureUrl: _queue[_queueIndex]['pictureUrl'],
      artist: _queue[_queueIndex]['artist'],
      songId: _queue[_queueIndex]['songId'],
      instant: true,
    );
  }

  Future<void> lunchPlaylist(List<Map<String, dynamic>> playlist) async {
    clearQueue();
    for (var element in playlist) {
      if (element['title'] != null && element['song'] != null &&
        element['cover'] != null && element['auteur'] != null && element['song_id'] != null &&
        element['title'] is String && element['song'] is String &&
        element['cover'] is String && element['auteur'] is String && element['song_id'] is String) {
      addToQueue(
        name: element['title'],
        description: "",
        songUrl: element['song'],
        pictureUrl: element['cover'],
        artist: element['auteur'],
        songId: element['song_id'],
      );
      } else {
      debugPrint('Skipping song with missing information: $element');
      }
    }
    if (_queue.isNotEmpty) {
      await togglePlaySong(
      name: _queue[_queueIndex]['name'],
      description: _queue[_queueIndex]['description'],
      songUrl: _queue[_queueIndex]['songUrl'],
      pictureUrl: _queue[_queueIndex]['pictureUrl'],
      artist: _queue[_queueIndex]['artist'],
      songId: _queue[_queueIndex]['songId'],
      );
    } else {
      debugPrint('No valid songs to play.');
    }
  }

  Future<void> togglePlaySong({
    required String name,
    required String description,
    required String songUrl,
    required String pictureUrl,
    required String artist,
    required String songId,
    bool instant = true,
  }) async {
    try {
      if (_currentSongUrl == songUrl) {
        if (_isPlaying) {
          await _audioPlayer.pause();
          _isPlaying = false;
          return;
        } else {
          await _audioPlayer.resume();
          _isPlaying = true;
          return;
        }
      }

      if (instant) {
        _currentSongName = name;
        _currentDescription = description;
        _currentSongUrl = songUrl;
        _currentPictureUrl = pictureUrl;
        _currentArtist = artist;
        _currentSongId = songId;

        await _audioPlayer.stop();
        final authCookie = await _secureStorage.read(key: 'auth');
        if (authCookie != null) {
          final pubKey = await MusicApiService().createSongAuth(songId, authCookie);
          await _audioPlayer.play(UrlSource('$songUrl?token=${pubKey['token']}'));
        _isPlaying = true;

        } else {
          throw Exception('Auth cookie is null');
        }

        _audioPlayer.onPlayerComplete.listen((event) async {
          await playNextInQueue();
        });
      } else {
        addToQueue(
          name: name,
          description: description,
          songUrl: songUrl,
          pictureUrl: pictureUrl,
          artist: artist,
          songId: songId,
        );

        if (!_isPlaying) {
          await _audioPlayer.stop();
          final authCookie = await _secureStorage.read(key: 'auth');
          if (authCookie != null) {
            final pubKey = await MusicApiService().createSongAuth(songId, authCookie);
            await _audioPlayer.play(UrlSource('$songUrl?token=${pubKey['token']}'));
          _isPlaying = true;

          } else {
            throw Exception('Auth cookie is null');
          }

          _audioPlayer.onPlayerComplete.listen((event) async {
            await playNextInQueue();
          });
        }
      }
    } catch (e) {
      debugPrint('Error playing song: $e');
      _isPlaying = false;
    }
  }

  Map<String, dynamic> getSongState() {
    return {
      'isPlaying': _isPlaying,
      'name': _currentSongName,
      'description': _currentDescription,
      'songUrl': _currentSongUrl,
      'pictureUrl': _currentPictureUrl,
      'artist': _currentArtist,
      'songId': _currentSongId,
    };
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
