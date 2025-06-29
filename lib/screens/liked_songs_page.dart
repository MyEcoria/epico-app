/*
** EPITECH PROJECT, 2025
** liked_songs_page.dart
** File description:
** Liked songs page for the Epico.
*/

import 'package:flutter/material.dart';
import '../manage/song_manage.dart';
import '../manage/api_manage.dart';
import '../theme.dart';

class LikedSongsPage extends StatefulWidget {
  final SongManager songManager;
  final String authCookie;
  final VoidCallback onBack;

  const LikedSongsPage({
    required this.songManager,
    required this.authCookie,
    required this.onBack,
    super.key,
  });

  @override
  State<LikedSongsPage> createState() => _LikedSongsPageState();
}

class _LikedSongsPageState extends State<LikedSongsPage> {
  List<Map<String, dynamic>> _songs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSongs();
  }

  Future<void> _fetchSongs() async {
    try {
      final tracks = await MusicApiService().getLikedSongs(widget.authCookie);
      setState(() {
        _songs = tracks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading liked songs: $e');
    }
  }

  Future<void> _refreshSongs() async {
    await _fetchSongs();
  }

  void _playAll() {
    if (_songs.isNotEmpty) {
      widget.songManager.lunchPlaylist(_songs);
    }
  }

  void _playSong(Map<String, dynamic> track) {
    widget.songManager.togglePlaySong(
      name: track['title'] ?? 'Unknown',
      description: track['album'] ?? '',
      songUrl: track['song'] ?? '',
      pictureUrl: track['cover'] ?? '',
      artist: track['auteur'] ?? '',
      songId: track['song_id']?.toString() ?? '',
      instant: true,
    );
  }

  String _formatDuration(String duration) {
    int seconds = int.tryParse(duration) ?? 0;
    int minutes = seconds ~/ 60;
    int remaining = seconds % 60;
    return '$minutes:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        widget.onBack();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: const Text('Liked Songs'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.black,
        floatingActionButton: _songs.isNotEmpty
            ? FloatingActionButton(
                backgroundColor: kAccentColor,
                onPressed: _playAll,
                child: const Icon(Icons.play_arrow),
              )
            : null,
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _songs.isEmpty
                ? const Center(
                    child: Text(
                      'No liked songs',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshSongs,
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final track = _songs[index];
                        return ListTile(
                          leading: track['cover'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    track['cover'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const SizedBox(width: 50, height: 50),
                          title: Text(
                            track['title'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track['auteur'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            _formatDuration(track['dure']?.toString() ?? '0'),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                          onTap: () => _playSong(track),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}