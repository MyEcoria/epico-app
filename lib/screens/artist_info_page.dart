import 'package:flutter/material.dart';
import '../manage/api_manage.dart';
import '../manage/song_manage.dart';
import '../theme.dart';

class ArtistInfoPage extends StatefulWidget {
  final String artistId;
  final SongManager songManager;
  final VoidCallback onBack;

  const ArtistInfoPage({
    Key? key,
    required this.artistId,
    required this.songManager,
    required this.onBack,
  }) : super(key: key);

  @override
  State<ArtistInfoPage> createState() => _ArtistInfoPageState();
}

class _ArtistInfoPageState extends State<ArtistInfoPage> {
  Map<String, dynamic>? _artist;
  List<Map<String, dynamic>>? _tracks;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final artistData = await MusicApiService().getArtistInfo(widget.artistId);
      final tracksData = await MusicApiService().getArtistTracks(artistData["ART_NAME"] ?? artistData["name"] ?? 'Unknown');

      setState(() {
        _artist = artistData;
        _tracks = List<Map<String, dynamic>>.from(tracksData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(String duration) {
    int seconds = int.tryParse(duration) ?? 0;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _playAllTracks() {
    if (_tracks == null || _tracks!.isEmpty) return;
    widget.songManager.lunchPlaylist(_tracks!.map((track) => {
      'title': track['title'] ?? 'Unknown',
      'song': track['song'] ?? '',
      'cover': track['cover'] ?? '',
      'auteur': track['auteur'] ?? _artist?['ART_NAME'] ?? _artist?['name'] ?? 'Unknown',
      'song_id': track['song_id']?.toString() ?? track['id']?.toString() ?? '',
    }).toList());
  }

  void _playTrack(Map<String, dynamic> track) {
    widget.songManager.togglePlaySong(
      name: track['title'] ?? 'Unknown',
      description: track['album'] ?? '',
      songUrl: track['song'] ?? '',
      pictureUrl: track['cover'] ?? '',
      artist: track['auteur'] ?? _artist?['ART_NAME'] ?? _artist?['name'] ?? 'Unknown',
      songId: track['song_id']?.toString() ?? track['id']?.toString() ?? '',
      instant: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text('Artist info'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _artist == null
              ? const Center(
                  child: Text('Error loading artist',
                      style: TextStyle(color: Colors.white)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Artist Info Section
                      if (_artist!["ART_PICTURE"] != null ||
                          _artist!["picture"] != null)
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                              'https://cdn-images.dzcdn.net/images/artist/${_artist!["ART_PICTURE"]}/500x500-000000-80-0-0.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        _artist!["ART_NAME"] ?? _artist!["name"] ?? 'Unknown',
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      if (_artist!["NB_FAN"] != null)
                        Text('${_artist!["NB_FAN"]} fans',
                            style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      if (_artist!["FACEBOOK"] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_artist!["FACEBOOK"],
                              style: const TextStyle(color: Colors.white54, fontSize: 14)),
                        ),
                      if (_artist!["TWITTER"] != null)
                        Text(_artist!["TWITTER"],
                            style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      
                      // Ajout du bouton "Tout jouer"
                      if (_tracks != null && _tracks!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Tout jouer'),
                              onPressed: _playAllTracks,
                            ),
                          ),
                        ),
                      // Tracks Section
                      const SizedBox(height: 16),
                      const Text(
                        'Tracks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_tracks != null && _tracks!.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _tracks!.length,
                          itemBuilder: (context, index) {
                            final track = _tracks![index];
                            return GestureDetector(
                              onTap: () => _playTrack(track),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    // Cover Image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.network(
                                        track["cover"] ?? '',
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[700],
                                              child: const Icon(Icons.music_note,
                                                  color: Colors.white54),
                                            ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    
                                    // Track Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            track["title"] ?? 'Unknown',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            track["album"] ?? 'Unknown Album',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Duration
                                    Text(
                                      _formatDuration(track["dure"]?.toString() ?? '0'),
                                      style: const TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                      else
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No tracks found',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
