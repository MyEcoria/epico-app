/*
** EPITECH PROJECT, 2025
** album_info_page.dart
** File description:
** Album info page for the Epico.
*/

import 'package:flutter/material.dart';
import '../manage/api_manage.dart';
import '../manage/song_manage.dart';
import '../manage/widget_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A page that displays information about a specific album.
///
/// It fetches album details and tracks using `MusicApiService` and allows
/// playing the album or individual songs.
class AlbumInfoPage extends StatefulWidget {
  /// The ID of the album to display.
  final String albumId;

  /// The song manager to handle song playback.
  final SongManager songManager;

  /// Callback function when the back button is pressed.
  final VoidCallback? onBack;
  const AlbumInfoPage({required this.albumId, required this.songManager, this.onBack, super.key});

  @override
  State<AlbumInfoPage> createState() => _AlbumInfoPageState();

  /// Creates the mutable state for this widget.
  ///
  /// The framework calls this method when it is about to build the widget
  /// for the first time.
  ///
  /// Subclasses should override this method to return a newly created
  /// instance of their associated [State] class:
  ///
  /// ```dart
  /// @override
  /// State<MyWidget> createState() => _MyWidgetState();
  /// ```
}

/// State class for [AlbumInfoPage].
///
/// This class manages the state and logic for the [AlbumInfoPage],
/// including fetching album data, handling loading and error states,
/// and managing song playback within the album context.
class _AlbumInfoPageState extends State<AlbumInfoPage> {
  /// Stores the album data.
  Map<String, dynamic>? _album;
  /// Stores the tracks of the album.
  List<Map<String, dynamic>>? _albumTracks;
  /// Indicates if the data is currently loading.
  bool _isLoading = true;
  /// Stores any error message that occurred during data fetching.
  String? _errorMessage;
  /// Secure storage for authentication cookies.
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  /// The authentication cookie.
  String? authCookie;

  @override
  void initState() {
    super.initState();
    _loadCookie();
    _fetchAlbum();
  }

  /// Loads the authentication cookie from secure storage.
  Future<void> _loadCookie() async {
    String? value = await _secureStorage.read(key: 'auth');
    setState(() {
      authCookie = value;
    });
  }

  /// Fetches album information and tracks from the API.
  Future<void> _fetchAlbum() async {
    try {
      debugPrint('Fetching album with ID: ${widget.albumId}');
      final Map<String, dynamic> data = await MusicApiService().getAlbumInfo(widget.albumId);
      debugPrint('Album data: $data');
      
      final List<Map<String, dynamic>> tracksData = await MusicApiService().getAlbumTracks(widget.albumId);
      debugPrint('Tracks data: $tracksData');
      
      setState(() {
        _album = data;
        _albumTracks = tracksData;
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

  /// Refreshes the album data by re-fetching it from the API.
  Future<void> _refreshAlbum() async {
    await _fetchAlbum();
  }

  /// Plays the entire album by adding all tracks to the playlist.
  void _playAlbum() {
    if (_albumTracks == null || _albumTracks!.isEmpty) {
      return;
    }
    
    final List<Map<String, dynamic>> tracks = _albumTracks!;
    final List<Map<String, dynamic>> playlist = tracks.map<Map<String, dynamic>>((Map<String, dynamic> track) {
      return {
        'title': track['SNG_TITLE'] ?? track['title'] ?? 'Unknown',
        'song': track['song'],
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

  /// Returns the URL for the album cover image.
  String _getAlbumCoverUrl() {
    final String? albumPicture = (_album?['ALB_PICTURE'] ?? _album?['cover']) as String?;
    if (albumPicture != null) {
      return 'https://cdn-images.dzcdn.net/images/cover/$albumPicture/500x500-000000-80-0-0.jpg';
    }
    return 'https://via.placeholder.com/500x500?text=No+Image';
  }

  /// Plays a single song.
  ///
  /// [songUrl] The URL of the song.
  /// [name] The name of the song.
  /// [description] The description of the song.
  /// [pictureUrl] The URL of the song's cover art.
  /// [artist] The artist of the song.
  /// [songId] The ID of the song.
  /// [instant] Whether to play the song instantly.
  void _playSong(String songUrl, {String name = '', String description = '', String pictureUrl = '', String artist = '', String songId = '', bool instant = true}) async {
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

  /// Formats a duration string (in seconds) into a "minutes:seconds" format.
  String _formatDuration(String duration) {
    final int seconds = int.tryParse(duration) ?? 0;
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    

    return PopScope(
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          if (widget.onBack != null) {
            widget.onBack!();
          }
        }
      },
      child: Scaffold(
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
            Padding(
              padding: const EdgeInsets.all(0),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _album == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text('Error loading album',
                                  style: TextStyle(color: Colors.white, fontSize: 18)),
                              if (_errorMessage != null) ...<Widget>[
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
                      : RefreshIndicator(
                          onRefresh: _refreshAlbum,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
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
                                Text(
                                  _album!['ALB_TITLE'] ?? _album!['title'] ?? 'Unknown Album',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _album!['ART_NAME'] ?? _album!['artist'] ?? 'Unknown Artist',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _playAlbum,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('Play Album'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amber,
                                    foregroundColor: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Tracks',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (_albumTracks != null && _albumTracks!.isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _albumTracks!.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final Map<String, dynamic> track = _albumTracks![index];
                                      debugPrint('Track data: $track');
                                      return ListTile(
                                        leading: const Icon(Icons.music_note, color: Colors.white),
                                        title: Text(
                                          track['SNG_TITLE'] ?? track['title'] ?? 'Unknown',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        subtitle: Text(
                                          _formatDuration(track['DURATION']?.toString() ?? '0'),
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                        onTap: () => _playSong(
                                          track['song'],
                                          name: track['SNG_TITLE'] ?? track['title'] ?? 'Unknown',
                                          description: _album!['ALB_TITLE'] ?? _album!['title'] ?? '',
                                          pictureUrl: _getAlbumCoverUrl(),
                                          artist: track['ART_NAME'] ?? track['artist'] ?? _album?['ART_NAME'] ?? _album?['artist'] ?? 'Unknown',
                                          songId: track['SNG_ID'] ?? track['song_id'] ?? track['id'] ?? '',
                                        ),
                                      );
                                    },
                                  )
                                else
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No tracks found.',
                                        style: TextStyle(color: Colors.white54),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: StreamBuilder<bool>(
                stream: widget.songManager.isPlayingStream,
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  final bool isPlaying = snapshot.data ?? false;
                  final bool isPaused = widget.songManager.isPaused();
                  if (!isPlaying && !isPaused) {
                    return const SizedBox.shrink();
                  }
                  return StreamBuilder<Map<String, dynamic>>(
                    stream: widget.songManager.songStateStream,
                    builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> songSnapshot) {
                      final Map<String, dynamic> currentSongState = songSnapshot.data ?? widget.songManager.getSongState();
                      return AudioPlayerWidget(
                        songManager: widget.songManager,
                        currentSongTitle: currentSongState['name'] ?? 'Unknown',
                        currentArtist: currentSongState['artist'] ?? 'Unknown',
                        albumArtUrl: currentSongState['pictureUrl'] ?? 'https://via.placeholder.com/150',
                        duration: const Duration(minutes: 3, seconds: 45),
                        isPlaying: isPlaying,
                        lyricsExcerpt: '',
                        isFavorite: false,
                        nextSongTitle: '',
                        nextSongArtist: '',
                        onPlayPause: () {
                          final Map<String, dynamic> songState = widget.songManager.getSongState();
                          widget.songManager.togglePlaySong(
                            name: songState['name'] ?? '',
                            description: songState['description'] ?? '',
                            songUrl: songState['songUrl'] ?? '',
                            pictureUrl: songState['pictureUrl'] ?? '',
                            artist: songState['artist'] ?? '',
                            songId: songState['songId'] ?? '',
                          );
                        },
                        onToggleFavorite: () {},
                        onSimilar: () {
                          widget.songManager.similarSong();
                        },
                        onNext: () {},
                        onPrevious: () {},
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

