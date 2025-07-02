/*
** EPITECH PROJECT, 2025
** widget_manage.dart
** File description:
** Widget for audio player UI, including mini and expanded player views.
** This file contains the UI and logic for the audio player, including playback controls,
** progress bar, and song information.
*/

import 'package:epico/manage/api_manage.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'song_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../theme.dart';
import 'dart:ui';
import 'dart:math';

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
  final VoidCallback onSimilar;
  final bool isPlaying;
  final String nextSongTitle;
  final String nextSongArtist;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const AudioPlayerWidget({
    required this.songManager,
    required this.currentSongTitle,
    required this.currentArtist,
    required this.albumArtUrl,
    required this.duration,
    required this.onPlayPause,
    required this.lyricsExcerpt,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onShare,
    required this.onSimilar,
    required this.isPlaying,
    required this.nextSongTitle,
    required this.nextSongArtist,
    required this.onNext,
    required this.onPrevious,
    super.key,
  });

  @override
  AudioPlayerWidgetState createState() => AudioPlayerWidgetState();
}

class AudioPlayerWidgetState extends State<AudioPlayerWidget>
    with TickerProviderStateMixin {
  Duration _position = Duration.zero;
  double _dragValue = 0.0;
  bool _isDragging = false;
  late AudioPlayer _audioPlayer;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? authCookie;
  final ValueNotifier<bool> _isLikedNotifier = ValueNotifier<bool>(false);
  late AnimationController _pulseController;
  bool _isExpanded = false;
  final Color _dominantColor = kAccentColor;

  Future<void> _loadCookie() async {
    String? value = await _secureStorage.read(key: 'auth');
    authCookie = value;
    if (authCookie != null && mounted) {
      final initialLike = await MusicApiService().isLike(widget.songManager.getSongState()['songId'], authCookie!);
      setState(() {
        _isLikedNotifier.value = initialLike;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadCookie();
    _audioPlayer = widget.songManager.getAudioPlayer();
    _setupPositionListener();
    _setupSongChangeListener();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 800),
    )..repeat(reverse: true);
  }

  void _setupSongChangeListener() {
    widget.songManager.songStateStream.listen((_) {
      _isLikedNotifier.value = false;
      if (authCookie != null) {
        MusicApiService().isLike(widget.songManager.getSongState()['songId'], authCookie!)
            .then((liked) {
          if (mounted) {
            setState(() {
              _isLikedNotifier.value = liked;
            });
          }
        });
      }
    });
  }

  void _setupPositionListener() {
    _audioPlayer.onPositionChanged.listen((position) {
      if (!_isDragging && mounted) {
        setState(() {
          _position = position;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handlePlayPause() {
    final songState = widget.songManager.getSongState();
    widget.songManager.togglePlaySong(name: songState['name'], description: songState['description'], songUrl: songState['songUrl'], pictureUrl: songState['pictureUrl'], artist: songState['artist'], songId: songState['songId']);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  void _showExpandedPlayer(BuildContext context) {
    setState(() {
      _isExpanded = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildExpandedPlayer(context);
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildMiniPlayer(context);
  }

  Widget _buildMiniPlayer(BuildContext context) {
    return StreamBuilder<bool>(
      stream: widget.songManager.isPlayingStream,
      builder: (context, snapshot) {
        bool isPlaying = snapshot.data ?? false;
        return StreamBuilder<bool>(
          stream: widget.songManager.isPausedStream,
          builder: (context, pausedSnapshot) {
            bool isPaused = pausedSnapshot.data ?? false;
            if (!isPlaying && !isPaused) {
              return const SizedBox.shrink();
            } else {
              return GestureDetector(
                onTap: () {
                  _showExpandedPlayer(context);
                },
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! < 0) {
                    _showExpandedPlayer(context);
                  }
                },
                child: AnimatedOpacity(
                  opacity: _isExpanded ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.7 * 255).toInt()),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: _dominantColor.withAlpha((0.6 * 255).toInt())),
                      boxShadow: [
                        BoxShadow(
                          color: _dominantColor.withAlpha((0.3 * 255).toInt()),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Row(
                      children: [
                        Hero(
                          tag: 'albumArtHero',
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(left: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _dominantColor.withAlpha((0.4 * (1 - _pulseController.value) * 255).toInt()),
                                      blurRadius: 6 + 4 * _pulseController.value,
                                      spreadRadius: 1 + _pulseController.value,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.network(
                                    widget.songManager.getSongState()['pictureUrl'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.songManager.getSongState()['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.songManager.getSongState()['artist'],
                                  style: TextStyle(
                                    color: Colors.white.withAlpha((0.7 * 255).toInt()),
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: _handlePlayPause,
                        ),
                      ],
                    ),
                      ),
                    ),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildExpandedPlayer(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return DraggableScrollableSheet(
      initialChildSize: 0.97,
      minChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: _dominantColor.withAlpha((0.4 * 255).toInt()),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0, bottom: 40.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 40),
                StreamBuilder<Map<String, String>>( 
                stream: widget.songManager.songStateStream.cast<Map<String, String>>(),
                builder: (context, snapshot) { 
                  final songState = snapshot.data ?? widget.songManager.getSongState(); 
                  return Hero( 
                    tag: 'albumArtHero', 
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _dominantColor, width: 4),
                          image: DecorationImage( 
                            image: NetworkImage(songState['pictureUrl'] ?? ''), 
                            fit: BoxFit.cover, 
                          ), 
                        ), 
                      ),
                      builder: (context, child) {
                        final waveOffset = _pulseController.value * 2 * pi;
                        return Container(
                          width: MediaQuery.of(context).size.width * 0.8,
                          height: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _dominantColor, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: _dominantColor.withAlpha(((0.3 + 0.1 * (0.5 + 0.5 * sin(waveOffset))) * 255).toInt()),
                                blurRadius: 25 + 8 * (0.5 + 0.5 * sin(waveOffset + 0.5)),
                                spreadRadius: 6 + 3 * (0.5 + 0.5 * sin(waveOffset + 1)),
                                offset: Offset(2 * sin(waveOffset + 0.3), 12 + 5 * sin(waveOffset + 0.7)),
                              ),
                              BoxShadow(
                                color: _dominantColor.withAlpha(((0.2 + 0.08 * (0.5 + 0.5 * sin(waveOffset + 1.5))) * 255).toInt()),
                                blurRadius: 40 + 12 * (0.5 + 0.5 * sin(waveOffset + 2)),
                                spreadRadius: 8 + 4 * (0.5 + 0.5 * sin(waveOffset + 2.5)),
                                offset: Offset(3 * sin(waveOffset + 1.8), 18 + 7 * sin(waveOffset + 3)),
                              ),
                              BoxShadow(
                                color: _dominantColor.withAlpha(((0.15 + 0.06 * (0.5 + 0.5 * sin(waveOffset + 3))) * 255).toInt()),
                                blurRadius: 55 + 15 * (0.5 + 0.5 * sin(waveOffset + 3.5)),
                                spreadRadius: 10 + 5 * (0.5 + 0.5 * sin(waveOffset + 4)),
                                offset: Offset(4 * sin(waveOffset + 4.2), 22 + 8 * sin(waveOffset + 4.8)),
                              ),
                            ],
                            image: DecorationImage( 
                              image: NetworkImage(songState['pictureUrl'] ?? ''), 
                              fit: BoxFit.cover, 
                            ), 
                          ), 
                        );
                      },
                    ),
                  ); 
                }, 
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                    StreamBuilder<Map<String, String>>(
                    stream: widget.songManager.songStateStream.cast<Map<String, String>>(),
                    builder: (context, snapshot) {
                      final songState = snapshot.data ?? widget.songManager.getSongState();
                      return Expanded(
                      flex: 7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Text(
                          songState['name'] ?? '',
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
                          songState['artist'] ?? '',
                          style: TextStyle(
                          color: Colors.white.withAlpha((0.7 * 255).toInt()),
                          fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        ],
                      ),
                      );
                    },
                    ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _isLikedNotifier,
                    builder: (context, isLiked, child) {
                      return IconButton(
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.redAccent : Colors.white,
                        ),
                        onPressed: () async {
                          widget.onToggleFavorite();
                          _isLikedNotifier.value = !_isLikedNotifier.value;
                        },
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: widget.onShare,
                  ),
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white),
                    onPressed: widget.onSimilar,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
  children: [
    StreamBuilder<Duration>(
      stream: widget.songManager.positionStream,
      builder: (context, snapshot) {
        return Text(
          _formatDuration(_position),
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        );
      },
    ),
    Expanded(
      child: StreamBuilder<Duration>(
        stream: widget.songManager.positionStream,
        builder: (context, snapshot) {
          _position = snapshot.data ?? Duration.zero;
          return SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.grey[800],
              thumbColor: Colors.white,
              overlayColor: Colors.white.withAlpha((0.2 * 255).toInt()),
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
          );
        },
      ),
    ),
    Text(
      _formatDuration(widget.duration),
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    ),
  ],
),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                    onPressed: widget.songManager.playLastFromQueue,
                  ),
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
                            color: Colors.white.withAlpha((0.2 * 255).toInt()),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: StreamBuilder<bool>(
                        stream: widget.songManager.isPlayingStream,
                        builder: (context, snapshot) {
                          return Icon(
                            widget.songManager.isPlaying() ? Icons.pause : Icons.play_arrow,
                            color: Colors.black,
                            size: 38,
                          );
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                    onPressed: widget.songManager.playNextInQueue,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
