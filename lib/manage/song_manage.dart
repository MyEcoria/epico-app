import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SongManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  static bool PLAYING = false;
  bool _isPlaying = false;
  String? _currentSongName;
  String? _currentSongUrl;
  String? _currentPictureUrl;
  String? _currentDescription;
  String? _currentArtist;

  List<Map<String, dynamic>> _queue = [];
  List<Map<String, dynamic>> _history = [];

  AudioPlayer getAudioPlayer() {
    return _audioPlayer;
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  bool isPlayingSong(String songUrl) {
    return _currentSongUrl == songUrl;
  }

  Stream<bool> get isPlayingStream => _audioPlayer.onPlayerStateChanged.map((state) => state == PlayerState.playing);
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

  void addToHistory({
    required String name,
    required String description,
    required String songUrl,
    required String pictureUrl,
    required String artist,
  }) {
    _history.add({
      'name': name,
      'description': description,
      'songUrl': songUrl,
      'pictureUrl': pictureUrl,
      'artist': artist,
    });
    debugPrint('Added song to history: $name');
  }

  List<Map<String, dynamic>> getQueue() {
    return _queue;
  }

  List<Map<String, dynamic>> getHistory() {
    return _history;
  }

  void clearQueue() {
    _queue.clear();
  }

  void clearHistory() {
    _history.clear();
  }

  Future<void> playNextInQueue() async {
    if (_currentSongName != null && _currentSongUrl != null) {
      addToHistory(
        name: _currentSongName!,
        description: _currentDescription ?? '',
        songUrl: _currentSongUrl!,
        pictureUrl: _currentPictureUrl ?? '',
        artist: _currentArtist ?? '',
      );
    }

    debugPrint('Queue contents:');
    for (int i = 0; i < _queue.length; i++) {
      debugPrint('${i + 1}. ${_queue[i]['name']} by ${_queue[i]['artist']}');
    }

    if (_queue.isEmpty) {
      debugPrint('Queue is empty, no next song to play');
      return;
    }

    final nextSong = _queue.first;

    _queue.removeAt(0);

    await togglePlaySong(
      name: nextSong['name'],
      description: nextSong['description'],
      songUrl: nextSong['songUrl'],
      pictureUrl: nextSong['pictureUrl'],
      artist: nextSong['artist'],
      instant: true,
    );
  }

  Future<void> playLastFromHistory() async {
    if (_currentSongName != null && _currentSongUrl != null) {
      addToQueue(
        name: _currentSongName!,
        description: _currentDescription ?? '',
        songUrl: _currentSongUrl!,
        pictureUrl: _currentPictureUrl ?? '',
        artist: _currentArtist ?? '',
      );
    }

    if (_history.isEmpty) {
      debugPrint('History is empty, no song to play');
      return;
    }

    final lastSong = _history.last;
    
    _history.removeLast();

    await togglePlaySong(
      name: lastSong['name'],
      description: lastSong['description'],
      songUrl: lastSong['songUrl'],
      pictureUrl: lastSong['pictureUrl'],
      artist: lastSong['artist'],
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
      if (_isPlaying && _currentSongUrl == songUrl) {
        await _audioPlayer.stop();
        _isPlaying = false;
        return;
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
