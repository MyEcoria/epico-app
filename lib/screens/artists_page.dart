/*
** EPITECH PROJECT, 2025
** artists_page.dart
** File description:
** Artists page for the Deezer app.
*/

import 'package:flutter/material.dart';
import '../manage/api_manage.dart';
import '../manage/song_manage.dart';
import '../theme.dart';
import 'artist_info_page.dart';

class ArtistsPage extends StatefulWidget {
  final SongManager songManager;
  final String authCookie;
  final VoidCallback onBack;
  final Function(String id) onOpenArtist;

  const ArtistsPage({
    Key? key,
    required this.songManager,
    required this.authCookie,
    required this.onBack,
    required this.onOpenArtist,
  }) : super(key: key);

  @override
  _ArtistsPageState createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  List<dynamic> _artists = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtists();
  }

  Future<void> _fetchArtists() async {
    try {
      final data = await MusicApiService().yourArtist(widget.authCookie);
      setState(() {
        _artists = data['artist'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading artists: $e');
    }
  }

  Future<void> _refreshArtists() async {
    await _fetchArtists();
  }

  void _openArtist(String id) {
    debugPrint('Opening artist with ID: $id');
    if (id.isNotEmpty) {
      widget.onOpenArtist(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
        title: const Text('Artists'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _artists.isEmpty
              ? const Center(
                  child: Text(
                    'No artists found',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refreshArtists,
                  child: ListView.builder(
                    itemCount: _artists.length,
                    itemBuilder: (context, index) {
                      final artist = _artists[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade700,
                          backgroundImage: NetworkImage(
                            artist['cover'] ?? 'assets/default_artist.jpg',
                          ),
                        ),
                        title: Text(
                          artist['auteur'] ?? artist['name'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () => _openArtist(artist['artist_id']?.toString() ?? ''),
                      );
                    },
                  ),
              ),
    ),
    );
  }
}

