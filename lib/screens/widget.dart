import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final String currentSongTitle;
  final String currentArtist;
  final String albumArtUrl;
  final Duration duration;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isPlaying;
  final String lyricsExcerpt;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onShare;
  final String nextSongTitle;
  final String nextSongArtist;

  const AudioPlayerWidget({
    Key? key,
    required this.audioPlayer,
    required this.currentSongTitle,
    required this.currentArtist,
    required this.albumArtUrl,
    required this.duration,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.isPlaying,
    required this.lyricsExcerpt,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
    required this.nextSongTitle,
    required this.nextSongArtist,
  }) : super(key: key);

  @override
  _AudioPlayerWidgetState createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  Duration _position = Duration.zero;
  double _dragValue = 0.0;
  bool _isDragging = false;

  // Variable pour suivre l'offset vertical dû au drag
  double _dragOffset = 0.0;
  late AnimationController _dragController;
  late Animation<double> _dragAnimation;

  @override
  void initState() {
    super.initState();
    _setupPositionListener();
    _dragController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _dragController.dispose();
    super.dispose();
  }

  void _setupPositionListener() {
    widget.audioPlayer.onPositionChanged.listen((position) {
      if (!_isDragging && mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return _isExpanded ? _buildExpandedPlayer(context) : _buildMiniPlayer(context);
  }

  Widget _buildMiniPlayer(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          // Swipe up - étendre le player
          setState(() {
            _isExpanded = true;
            _dragOffset = 0.0; // réinitialisation lors de l'extension
          });
        }
      },
      onTap: () {
        setState(() {
          _isExpanded = true;
          _dragOffset = 0.0;
        });
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
            // Pochette d'album
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
            // Infos de la chanson
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
            // Bouton lecture/pause
            IconButton(
              icon: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 28,
              ),
              onPressed: widget.onPlayPause,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer(BuildContext context) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double halfScreen = screenHeight / 2;

  return GestureDetector(
    onVerticalDragUpdate: (details) {
      setState(() {
        _isDragging = true;
        _dragOffset += details.delta.dy;
        if (_dragOffset < 0) _dragOffset = 0;
      });
    },
    onVerticalDragEnd: (details) {
      _isDragging = false;
      if (_dragOffset > halfScreen) {
        // Si le drag est supérieur à 50% de la hauteur, passer en mode mini
        _animateDrag(_dragOffset, screenHeight, onCompleted: () {
          setState(() {
            _isExpanded = false;
            _dragOffset = 0.0;
          });
          _dragController.reset();
        });
      } else {
        // Sinon, revenir en mode étendu
        _animateDrag(_dragOffset, 0.0, onCompleted: () {
          setState(() {
            _dragOffset = 0.0;
          });
          _dragController.reset();
        });
      }
    },
    child: Transform.translate(
      offset: Offset(0, _dragOffset),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          width: double.infinity,
          height: screenHeight,
          color: Colors.black,
          padding: const EdgeInsets.only(top: 100.0, left: 24.0, right: 24.0, bottom: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Barre supérieure avec la flèche et le bouton "Connect to a device"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: () {
                      _animateDrag(_dragOffset, screenHeight, onCompleted: () {
                        setState(() {
                          _isExpanded = false;
                          _dragOffset = 0.0;
                        });
                        _dragController.reset();
                      });
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.devices, color: Colors.white, size: 16),
                    label: const Text(
                      "Connect to a device",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    onPressed: () {
                      // Implémenter la fonctionnalité de connexion
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Artwork de l'album
              Expanded(
                flex: 5,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
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
              const SizedBox(height: 20),
              // Extrait de paroles
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
              const SizedBox(height: 20),
              // Titre de la chanson et boutons d'action (favori, partage)
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
              const SizedBox(height: 16),
              // Barre de progression
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
                            widget.audioPlayer.seek(newPosition);
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
              const SizedBox(height: 20),
              // Contrôles de lecture
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                    onPressed: widget.onPrevious,
                  ),
                  Container(
                    width: 70,
                    height: 70,
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
                    child: IconButton(
                      icon: Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 38,
                      ),
                      onPressed: widget.onPlayPause,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                    onPressed: widget.onNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}


  // Méthode pour animer le _dragOffset jusqu'à une valeur cible
  void _animateDrag(double from, double to, {required VoidCallback onCompleted}) {
    _dragAnimation = Tween<double>(begin: from, end: to).animate(
      CurvedAnimation(parent: _dragController, curve: Curves.easeOut),
    );
    _dragController.addListener(() {
      setState(() {
        _dragOffset = _dragAnimation.value;
      });
    });
    _dragController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onCompleted();
      }
    });
    _dragController.forward();
  }
}



// Example usage
class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = const Duration(minutes: 3, seconds: 45);
  bool _isFavorite = false;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    // Handle actual play/pause logic here
  }

  void _skipToNext() {
    // Handle next song logic
  }

  void _skipToPrevious() {
    // Handle previous song logic
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  void _shareTrack() {
    // Handle sharing functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Your main app content goes here
          ListView(
            padding: const EdgeInsets.only(bottom: 60), // Space for mini player
            children: const [
              // Your app content
              SizedBox(height: 300), // Example placeholder content
              Center(child: Text("Main App Content", style: TextStyle(fontSize: 24))),
              SizedBox(height: 1000), // Example placeholder content
            ],
          ),

          // The audio player widget positioned at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AudioPlayerWidget(
              audioPlayer: _audioPlayer,
              currentSongTitle: "Blinding Lights",
              currentArtist: "The Weeknd",
              albumArtUrl: "https://example.com/album_cover.jpg",
              duration: _duration,
              onPlayPause: _togglePlayPause,
              onNext: _skipToNext,
              onPrevious: _skipToPrevious,
              isPlaying: _isPlaying,
              lyricsExcerpt: "I've been tryna call, I've been on my own for long enough...",
              isFavorite: _isFavorite,
              onToggleFavorite: _toggleFavorite,
              onShare: _shareTrack,
              nextSongTitle: "Save Your Tears",
              nextSongArtist: "The Weeknd",
            ),
          ),
        ],
      ),
    );
  }
}