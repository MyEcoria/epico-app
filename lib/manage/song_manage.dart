/*
** EPITECH PROJECT, 2025
** song_manager.dart
** File description:
** Manages the playback of songs, including queue and history management.
** This file contains methods to play, pause, add to queue, and manage the playback state.
*/

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SongManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  static bool playing = false;
  bool _isPlaying = false;
  String? _currentSongName;
  String? _currentSongUrl;
  String? _currentPictureUrl;
  String? _currentDescription;
  String? _currentArtist;

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

  Stream<bool> get isPlayingStream => _audioPlayer.onPlayerStateChanged.map((state) => state == PlayerState.playing);
  Stream<bool> get isPausedStream => _audioPlayer.onPlayerStateChanged.map((state) => state == PlayerState.paused);
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;

  void addToQueue({
    required String name,
    required String description,
    required String songUrl,
    required String pictureUrl,
    required String artist,
  }) {
    _queue.add({
      'name': name,
      'description': description,
      'songUrl': songUrl,
      'pictureUrl': pictureUrl,
      'artist': artist,
    });
    debugPrint('Added song to queue: $name');
  }

  List<Map<String, dynamic>> getQueue() {
    return _queue;
  }

  void clearQueue() {
    _queue.clear();
  }

  Future<void> playNextInQueue() async {
    if (_queue.length < _queueIndex) {
      return;
    }
    _queueIndex++;
    await togglePlaySong(
      name: _queue[_queueIndex]['name'],
      description: _queue[_queueIndex]['description'],
      songUrl: _queue[_queueIndex]['songUrl'],
      pictureUrl: _queue[_queueIndex]['pictureUrl'],
      artist: _queue[_queueIndex]['artist'],
      instant: true,
    );
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
      instant: true,
    );
  }

  Future<void> lunchPlaylist(List<Map<String, dynamic>> playlist) async {
    clearQueue();
    for (var element in playlist) {
      addToQueue(
        name: element['name'],
        description: element['description'],
        songUrl: element['songUrl'],
        pictureUrl: element['pictureUrl'],
        artist: element['artist'],
      );
    }
    await togglePlaySong(
      name: _queue[_queueIndex]['name'],
      description: _queue[_queueIndex]['description'],
      songUrl: _queue[_queueIndex]['songUrl'],
      pictureUrl: _queue[_queueIndex]['pictureUrl'],
      artist: _queue[_queueIndex]['artist'],
      instant: true,
    );
  }

  Future<void> togglePlaySong({
    required String name,
    required String description,
    required String songUrl,
    required String pictureUrl,
    required String artist,
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

        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(songUrl));
        _isPlaying = true;

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
        );

        if (!_isPlaying) {
          await playNextInQueue();

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
    };
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
