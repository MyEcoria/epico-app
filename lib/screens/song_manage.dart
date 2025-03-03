import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SongManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _currentSongName;
  String? _currentSongUrl;
  String? _currentPictureUrl;
  String? _currentDescription;

  AudioPlayer getAudioPlayer() {
    return _audioPlayer;
  }

  bool isPlaying() {
    return _audioPlayer.state == PlayerState.playing;
  }

  // Function to play or stop a song
  Future<void> togglePlaySong({
    required String name,
    required String description,
    required String songUrl,
    required String pictureUrl,
  }) async {
    try {
      // If already playing the same song, stop it
      if (_isPlaying && _currentSongUrl == songUrl) {
        await _audioPlayer.stop();
        _isPlaying = false;
        return;
      }
      
      // If playing a different song or no song is playing
      _currentSongName = name;
      _currentDescription = description;
      _currentSongUrl = songUrl;
      _currentPictureUrl = pictureUrl;
      
      await _audioPlayer.stop(); // Stop any currently playing song
      await _audioPlayer.play(UrlSource(songUrl));
      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing song: $e');
      _isPlaying = false;
    }
  }

  // Function to get the current song state
  Map<String, dynamic> getSongState() {
    return {
      'isPlaying': _isPlaying,
      'name': _currentSongName,
      'description': _currentDescription,
      'songUrl': _currentSongUrl,
      'pictureUrl': _currentPictureUrl,
    };
  }

  // Dispose resources when finished
  void dispose() {
    _audioPlayer.dispose();
  }
}