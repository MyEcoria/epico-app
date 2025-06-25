import 'package:flutter/material.dart';
import '../manage/api_manage.dart';
import '../manage/song_manage.dart';
import '../manage/widget_manage.dart';
import '../theme.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AlbumInfoPage extends StatefulWidget {
  final String albumId;
  final SongManager songManager;
  final VoidCallback? onBack;
  const AlbumInfoPage({Key? key, required this.albumId, required this.songManager, this.onBack}) : super(key: key);

  @override
  State<AlbumInfoPage> createState() => _AlbumInfoPageState();
}

class _AlbumInfoPageState extends State<AlbumInfoPage> {
  Map<String, dynamic>? _album;
  List<Map<String, dynamic>>? _album_tracks;
  bool _isLoading = true;
  String? _errorMessage;
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? authCookie;

  @override
  void initState() {
    super.initState();
    _loadCookie();
    _fetchAlbum();
  }

  Future<void> _loadCookie() async {
    String? value = await _secureStorage.read(key: 'auth');
    setState(() {
      authCookie = value;
    });
  }

  Future<void> _fetchAlbum() async {
    try {
      debugPrint('Fetching album with ID: ${widget.albumId}');
      final data = await MusicApiService().getAlbumInfo(widget.albumId);
      debugPrint('Album data: $data');
      
      final tracksData = await MusicApiService().getAlbumTracks(widget.albumId);
      debugPrint('Tracks data: $tracksData');
      
      setState(() {
        _album = data;
        _album_tracks = tracksData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading album: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _playAlbum() {
    if (_album_tracks == null || _album_tracks!.isEmpty) return;
    
    final tracks = _album_tracks!;
    final playlist = tracks.map<Map<String, dynamic>>((track) {
      // Adapter selon la structure réelle des données retournées par l'API
      return {
        'title': track['SNG_TITLE'] ?? track['title'] ?? 'Unknown',
        'song': 'http://192.168.1.53:8000/music/${track['SNG_ID']}.mp3',
        'cover': _getAlbumCoverUrl(),
        'auteur': track['ART_NAME'] ?? track['artist'] ?? _album?['ART_NAME'] ?? _album?['artist'] ?? 'Unknown',
        'song_id': track['SNG_ID'] ?? track['song_id'] ?? track['id'] ?? '',
      };
    }).toList();
    debugPrint('Playlist to play: $playlist');
    
    if (playlist.isNotEmpty) {
      widget.songManager.lunchPlaylist(playlist);
    }
  }

  String _getAlbumCoverUrl() {
    final albumPicture = _album?["ALB_PICTURE"] ?? _album?["cover"];
    if (albumPicture != null) {
      return "https://cdn-images.dzcdn.net/images/cover/$albumPicture/500x500-000000-80-0-0.jpg";
    }
    return 'https://via.placeholder.com/500x500?text=No+Image';
  }

  void _playSong(String songUrl, {String name = "", String description = "", String pictureUrl = "", String artist = "", String songId = "", bool instant = true}) async {
    await widget.songManager.togglePlaySong(
      name: name,
      description: description,
      songUrl: songUrl,
      pictureUrl: pictureUrl,
      artist: artist,
      instant: instant,
      songId: songId,
    );
  }

  String _formatDuration(String duration) {
    int seconds = int.tryParse(duration) ?? 0;
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying = widget.songManager.isPlaying();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Album info'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Contenu principal avec padding bottom pour éviter le chevauchement
          Padding(
            padding: const EdgeInsets.all(0), // Suppression du padding bottom
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _album == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Error loading album',
                                style: TextStyle(color: Colors.white, fontSize: 18)),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isLoading = true;
                                  _errorMessage = null;
                                });
                                _fetchAlbum();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Album cover
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(_getAlbumCoverUrl()),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Album title
                            Text(
                              _album!["ALB_TITLE"] ?? _album!["title"] ?? 'Unknown Album',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Artist name
                            Text(
                              _album!["ART_NAME"] ?? _album!["artist"] ?? 'Unknown Artist',
                              style: const TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            
                            // Play button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kAccentColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: _playAlbum,
                              child: const Text('Play Album'),
                            ),
                            
                            // Track list (if available)
                            if (_album_tracks != null && _album_tracks!.isNotEmpty) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Tracks',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _album_tracks!.length,
                                itemBuilder: (context, index) {
                                  final track = _album_tracks![index];
                                  return GestureDetector(
                                    onTap: () {
                                      widget.songManager.togglePlaySong(
                                        name: track['SNG_TITLE'] ?? track['title'] ?? 'Unknown',
                                        description: '',
                                        songUrl: 'http://192.168.1.53:8000/music/${track['SNG_ID']}.mp3',
                                        pictureUrl: _getAlbumCoverUrl(),
                                        artist: track['ART_NAME'] ?? track['artist'] ?? _album?['ART_NAME'] ?? _album?['artist'] ?? 'Unknown',
                                        songId: track['SNG_ID'] ?? track['song_id'] ?? track['id'] ?? '',
                                        instant: true,
                                      );
                                    },
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
                                              _getAlbumCoverUrl(),
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
                                                  track['SNG_TITLE'] ?? track['title'] ?? 'Unknown',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  track['ART_NAME'] ?? track['artist'] ?? _album?['ART_NAME'] ?? _album?['artist'] ?? 'Unknown',
                                                  style: const TextStyle(
                                                    color: Colors.white54,
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
                                            _formatDuration(track['DURATION']?.toString() ?? track['dure']?.toString() ?? '0'),
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
                              ),
                            ],
                          ],
                        ),
                      ),
          ),
          
          // Mini Player en bas - Simplifié pour éviter les conflits
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: StreamBuilder<bool>(
              stream: widget.songManager.isPlayingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? false;
                final isPaused = widget.songManager.isPaused();
                
                // Afficher le mini player seulement s'il y a une chanson en cours ou en pause
                if (!isPlaying && !isPaused) {
                  return const SizedBox.shrink();
                }
                
                return StreamBuilder<Map<String, dynamic>>(
                  stream: widget.songManager.songStateStream,
                  builder: (context, songSnapshot) {
                    final currentSongState = songSnapshot.data ?? widget.songManager.getSongState();
                    return AudioPlayerWidget(
                      songManager: widget.songManager,
                      currentSongTitle: currentSongState['name'] ?? "Unknown",
                      currentArtist: currentSongState['artist'] ?? "Unknown",
                      albumArtUrl: currentSongState['pictureUrl'] ?? "https://via.placeholder.com/150",
                      duration: const Duration(minutes: 3, seconds: 45),
                      onPlayPause: () {
                        final songState = widget.songManager.getSongState();
                        widget.songManager.togglePlaySong(
                          name: songState['name'] ?? '',
                          description: songState['description'] ?? '',
                          songUrl: songState['songUrl'] ?? '',
                          pictureUrl: songState['pictureUrl'] ?? '',
                          artist: songState['artist'] ?? '',
                          songId: songState['songId'] ?? '',
                        );
                      },
                      lyricsExcerpt: "I've been tryna call, I've been on my own for long enough...",
                      isFavorite: false,
                      onToggleFavorite: () {
                        if (authCookie != null && currentSongState['songId'] != null) {
                          MusicApiService().createLike(currentSongState['songId'], authCookie!);
                        }
                      },
                      onShare: () {
                        // Implement share functionality
                      },
                      isPlaying: isPlaying,
                      nextSongTitle: "Save Your Tears",
                      nextSongArtist: "The Weeknd",
                      onNext: widget.songManager.playNextInQueue,
                      onPrevious: widget.songManager.playLastFromQueue,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

