import 'package:flutter/material.dart';
import '../manage/api_manage.dart';
import '../manage/song_manage.dart';
import '../theme.dart';

class AlbumInfoPage extends StatefulWidget {
  final String albumId;
  final SongManager songManager;
  const AlbumInfoPage({Key? key, required this.albumId, required this.songManager}) : super(key: key);

  @override
  State<AlbumInfoPage> createState() => _AlbumInfoPageState();
}

class _AlbumInfoPageState extends State<AlbumInfoPage> {
  Map<String, dynamic>? _album;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlbum();
  }

  Future<void> _fetchAlbum() async {
    try {
      final data = await MusicApiService().getAlbumInfo(widget.albumId);
      setState(() {
        _album = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playAlbum() {
    final tracks = (_album?['songs'] ?? _album?['tracks'] ?? []) as List<dynamic>;
    final playlist = tracks.map<Map<String, dynamic>>((track) {
      return {
        'title': track['title'] ?? track['name'],
        'song': track['song'],
        'cover': track['cover'] ?? track['picture'],
        'auteur': track['artist'] ?? track['auteur'] ?? _album?['ART_NAME'] ?? '',
        'song_id': track['song_id'] ?? track['id'] ?? '',
      };
    }).toList();
    if (playlist.isNotEmpty) {
      widget.songManager.lunchPlaylist(playlist);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Album info'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _album == null
              ? const Center(
                  child: Text('Error loading album',
                      style: TextStyle(color: Colors.white)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_album!["ALB_PICTURE"] != null || _album!["cover"] != null)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                                  _album!["cover"] ?? _album!["ALB_PICTURE"]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _album!["ALB_TITLE"] ?? _album!["title"] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _album!["ART_NAME"] ?? _album!["artist"] ?? '',
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style:
                            ElevatedButton.styleFrom(backgroundColor: kAccentColor),
                        onPressed: _playAlbum,
                        child: const Text('Play Album'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

