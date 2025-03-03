import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

// Import SongManager
import 'song_manage.dart';

class AudioPlayerWidget extends StatefulWidget {
  final SongManager songManager;
  final String currentSongTitle;
  final String currentArtist;
  final String albumArtUrl;
  final Duration duration;
  final VoidCallback onPlayPause;
  final String lyricsExcerpt;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;
  final bool isPlaying;
  final String nextSongTitle;
  final String nextSongArtist;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const AudioPlayerWidget({
    Key? key,
    required this.songManager,
    required this.currentSongTitle,
    required this.currentArtist,
    required this.albumArtUrl,
    required this.duration,
    required this.onNext,
    required this.onPrevious,
    required this.lyricsExcerpt,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
    required this.nextSongTitle,
    required this.nextSongArtist,
    required this.isPlaying,
    required this.onPlayPause,
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  Duration _position = Duration.zero;
  double _dragValue = 0.0;
  bool _isDragging = false;
  bool _isPlaying = false;
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    // Get the AudioPlayer from SongManager
    _audioPlayer = widget.songManager.getAudioPlayer();
    // Update isPlaying from SongManager
    _isPlaying = widget.songManager.isPlaying();
    _setupPositionListener();
  }

  void _setupPositionListener() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (!_isDragging && mounted) {
        setState(() {
          _position = position;
        });
      }
    });
    
    // Listen for play state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });
  }

  // Handle play/pause toggle using SongManager
  void _handlePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      // If we already have a current song URL in SongManager
      Map<String, dynamic> currentState = widget.songManager.getSongState();
      if (currentState['songUrl'] != null) {
        _audioPlayer.resume();
        setState(() {
          _isPlaying = true;
        });
      } else {
        // This is a fallback, normally you'd have a current song to play
        widget.songManager.togglePlaySong(
          name: widget.currentSongTitle,
          description: widget.currentArtist,
          songUrl: "YOUR_DEFAULT_SONG_URL", // Replace with actual URL
          pictureUrl: widget.albumArtUrl,
        );
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _showExpandedPlayer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildExpandedPlayer(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildMiniPlayer(context);
  }

  Widget _buildMiniPlayer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showExpandedPlayer(context);
      },
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swipe up - open expanded player
          _showExpandedPlayer(context);
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: Colors.black87,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Album artwork
            Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: DecorationImage(
                  image: NetworkImage(widget.albumArtUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Song info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.currentSongTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.currentArtist,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Play/pause button
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _handlePlayPause,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // Utilisation de calculs adaptatifs pour les dimensions
    final double artworkSize = screenWidth * 0.7 < screenHeight * 0.35 
      ? screenWidth * 0.7 
      : screenHeight * 0.35;
    
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      // Ajout de snapPoints pour contrôler les positions d'arrêt
      snapSizes: const [0.5, 0.95],
      // Ajout du comportement de snap
      snap: true,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(
              vertical: screenHeight * 0.02,
              horizontal: screenWidth * 0.06,
            ),
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Top bar with down arrow and "Connect to a device" button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.devices, color: Colors.white, size: 16),
                    label: const Text(
                      "Connect to a device",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onPressed: () {
                      // Implement connection functionality
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              // Album artwork - taille adaptative
              Center(
                child: Container(
                  width: artworkSize,
                  height: artworkSize,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    image: DecorationImage(
                      image: NetworkImage(widget.albumArtUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Lyrics excerpt
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenHeight * 0.01,
                ),
                child: Text(
                  widget.lyricsExcerpt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              // Song title and action buttons (favorite, share)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentSongTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.currentArtist,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: widget.onToggleFavorite,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: widget.onShare,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              // Progress bar
              Row(
                children: [
                  Text(
                    _formatDuration(_position),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.grey[800],
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _isDragging
                            ? _dragValue
                            : (widget.duration.inMilliseconds > 0
                                ? _position.inMilliseconds / widget.duration.inMilliseconds
                                : 0.0),
                        onChanged: (value) {
                          setState(() {
                            _isDragging = true;
                            _dragValue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          setState(() {
                            _isDragging = false;
                            final newPosition = Duration(
                              milliseconds: (value * widget.duration.inMilliseconds).round(),
                            );
                            _audioPlayer.seek(newPosition);
                            _position = newPosition;
                          });
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(widget.duration),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              // Playback controls - taille adaptative
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                    onPressed: widget.onPrevious,
                  ),
                  // Correction du bouton de lecture
                  GestureDetector(
                    onTap: _handlePlayPause,
                    child: Container(
                      width: screenWidth * 0.15 > 60 ? screenWidth * 0.15 : 60,
                      height: screenWidth * 0.15 > 60 ? screenWidth * 0.15 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 38,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                    onPressed: widget.onNext,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              // Next song info
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.queue_music, color: Colors.white70),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Next",
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            "${widget.nextSongTitle} · ${widget.nextSongArtist}",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}