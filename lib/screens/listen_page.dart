/*
** EPITECH PROJECT, 2025
** listen_page.dart
** File description:
** Home page for the Epico.
** This file contains the main UI and logic for the home screen of the app.
** It displays various sections like recently played songs, mixes for you,
** artists you follow, new releases, and recommended playlists.
** It also handles the playback of songs using the SongManager.
*/

import 'package:flutter/material.dart';
import '../manage/widget_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../manage/song_manage.dart';
import '../manage/api_manage.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:async/async.dart';
import '../manage/cache_manage.dart';
import 'library_page.dart';
import 'package:flutter/cupertino.dart';
import '../theme.dart';
import 'album_info_page.dart';
import 'artist_info_page.dart';

void main() {
  runApp(const MyApp());
}

/// A tile representing a music genre.
class GenreTile extends StatelessWidget {
  /// The name of the genre.
  final String name;
  /// The overlay color of the tile.
  final Color overlayColor;

  /// Creates a genre tile.
  const GenreTile({
    required this.name,
    required this.overlayColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.asset(
            'assets/illustrator/${name.toLowerCase()}.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: overlayColor.withAlpha((255 * 0.2).round()),
            colorBlendMode: BlendMode.srcOver,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: overlayColor.withAlpha((255 * 0.6).round()),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              name,
                                                        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                    fontFamily: '.SF Pro Text',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The main application widget.
class MyApp extends StatelessWidget {
  /// Creates the main application widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),
      home: MusicAppHomePage(songManager: SongManager()),
    );
  }
}

/// The home page of the music application.
class MusicAppHomePage extends StatefulWidget {
  /// The song manager.
  final SongManager songManager;

  /// Creates the home page.
  const MusicAppHomePage({required this.songManager, super.key});

  @override
  State<MusicAppHomePage> createState() => _MusicAppHomePageState();
}

/// The state of the home page.
class _MusicAppHomePageState extends State<MusicAppHomePage> {
  List<Map<String, dynamic>> _searchResults = <Map<String, dynamic>>[];
  String _lastQuery = '';
  final CacheService cache = CacheService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  String? authCookie;
  int _currentIndex = 0;
  String? _selectedAlbumId;
  String? _selectedArtistId; // Ajout pour navigation artiste
  final ValueNotifier<bool> _isSearchResults = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPageSearch = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadCookie();
  }

  Future<void> _loadCookie() async {
    final String? value = await _secureStorage.read(key: 'auth');
    setState(() {
      authCookie = value;
    });
  }

  @override
  void dispose() {
    widget.songManager.dispose();
    super.dispose();
  }

  /// Extracts the first name from an email address.
  String extractFirstNameFromEmail(String email) {
    if (!email.contains('@epitech.eu')) {
      throw ArgumentError("L'email doit être au format prenom.nom@epitech.eu");
    }
    final List<String> parts = email.split('@');
    final String localPart = parts[0];
    final List<String> nameParts = localPart.split('.');
    String firstName = nameParts[0];
    firstName = firstName[0].toUpperCase() + firstName.substring(1);
    return firstName;
  }

  void _playPause(String songUrl, {String name = '', String description = '', String pictureUrl = '', String artist = '', String songId = '', bool instant = true}) async {
    await widget.songManager.togglePlaySong(
      name: name,
      description: description,
      songUrl: songUrl,
      pictureUrl: pictureUrl,
      artist: artist,
      instant: instant,
      songId: songId,
    );
    setState(() {});
  }

  Future<void> _refreshHome() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = widget.songManager.isPlaying();

    Widget mainContent;
    if (_selectedAlbumId != null) {
      mainContent = AlbumInfoPage(
        albumId: _selectedAlbumId!,
        songManager: widget.songManager,
        onBack: () {
          setState(() {
            _selectedAlbumId = null;
          });
        },
      );
    } else if (_selectedArtistId != null) {
      mainContent = ArtistInfoPage(
        artistId: _selectedArtistId!,
        songManager: widget.songManager,
        onBack: () {
          setState(() {
            _selectedArtistId = null;
          });
        },
      );
    } else {
      mainContent = SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isPageSearch,
          builder: (BuildContext context, bool isPageSearch, Widget? child) {
            final Widget page = _currentIndex == 0
              ? RefreshIndicator(
                  onRefresh: _refreshHome,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _buildHeader(),
                          const SizedBox(height: 24),
                          _buildRecentlyPlayed(),
                          const SizedBox(height: 24),
                          _buildFlowSection(),
                          const SizedBox(height: 24),
                          _buildMixesForYou(),
                          const SizedBox(height: 24),
                          _buildArtistsYouFollow(),
                          const SizedBox(height: 24),
                          _buildNewReleases(),
                        ],
                      ),
                    ),
                  ),
                )
              : _currentIndex == 1
                ? ValueListenableBuilder<bool>(
                    valueListenable: _isSearchResults,
                    builder: (BuildContext context, bool isSearchResults, Widget? child) {
                      return isSearchResults ? _buildSearchResultsScreen() : _buildSearchScreen();
                    },
                  )
                : LibraryPage(
                    songManager: widget.songManager,
                    authCookie: authCookie,
                    onArtistSelected: (String id) {
                      setState(() {
                        _selectedArtistId = id;
                      });
                    },
                  );
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(key: ValueKey<int>(_currentIndex), child: page),
            );
          },
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) {
          return;
        }
        if (_selectedAlbumId != null) {
          setState(() => _selectedAlbumId = null);
          return;
        }
        if (_selectedArtistId != null) {
          setState(() => _selectedArtistId = null);
          return;
        }
        if (_isSearchResults.value) {
          _isSearchResults.value = false;
          return;
        }
        Navigator.of(context).pop();
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          mainContent,
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: StreamBuilder<Map<String, dynamic>>(
              stream: widget.songManager.songStateStream,
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
                final Map<String, dynamic> currentSongState = snapshot.data ?? <String, dynamic>{};
                return AudioPlayerWidget(
                  songManager: widget.songManager,
                  currentSongTitle: currentSongState['name'] as String? ?? 'Blinding Lights',
                  currentArtist: currentSongState['artist'] as String? ?? 'MyEcoria',
                  albumArtUrl: currentSongState['pictureUrl'] as String? ?? 'https://example.com/album_cover.jpg',
                  duration: const Duration(minutes: 3, seconds: 45),
                  onPlayPause: () => _playPause(
                    currentSongState['songUrl'] as String? ?? 'https://dl.sndup.net/q4ksm/Quack%20Quest.mp3',
                    name: currentSongState['name'] as String? ?? 'Blinding Lights',
                    description: currentSongState['description'] as String? ?? '',
                    pictureUrl: currentSongState['pictureUrl'] as String? ?? 'https://example.com/album_cover.jpg',
                    songId: currentSongState['song_id'] as String? ?? '',
                  ),
                                    lyricsExcerpt: "I've been tryna call, I've been on my own for long enough...",
                  isFavorite: false,
                  onToggleFavorite: () {
                    MusicApiService().createLike(currentSongState['songId'] as String? ?? '', authCookie!);
                  },
                  onShare: () {
                    // Implement share functionality
                  },
                  onSimilar: () {
                    widget.songManager.similarSong();
                  },
                  isPlaying: isPlaying,
                  nextSongTitle: 'Save Your Tears',
                  nextSongArtist: 'The Weeknd',
                  onNext: () {
                    // Implement next song functionality
                  },
                  onPrevious: () {
                    // Implement previous song functionality
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Icon(
              Icons.waving_hand,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            FutureBuilder<String?>(
              future: cache.getCacheValue('email') as Future<String?>?,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            );
          } else {
            return Text(
              'Hi ${extractFirstNameFromEmail(snapshot.data ?? 'default.name@epitech.eu')},',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            );
          }
              },
            ),
          ],
        ),
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[800],
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: ClipOval(
            child: FutureBuilder<String?>(
              future: cache.getCacheValue('email') as Future<String?>?,
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                final String username = extractFirstNameFromEmail(snapshot.data ?? 'default.name@epitech.eu');
                return ProfilePicture(name: username, radius: 31, fontsize: 21);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentlyPlayed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Recently Played',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: authCookie == null
              ? const Center(child: Text('No auth cookie available'))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: MusicApiService().getLatestTracks(authCookie!),
                  builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No tracks available'));
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> track = snapshot.data![index];
                          return _buildAlbumCard(
                            track['title'] as String? ?? 'Unknown Title',
                            track['cover'] as String? ?? 'assets/caca.jpg',
                            track['song'] as String? ?? 'https://dl.sndup.net/q4ksm/Quack%20Quest.mp3',
                            artist: track['auteur'] as String? ?? 'MyEcoria',
                            songId: track['song_id'] as String? ?? '',
                            hasPlayButton: true,
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(String title, String imagePath, String url, {bool hasPlayButton = false, String artist = '', String songId = ''}) {
    return StreamBuilder<dynamic>(
      stream: StreamGroup.merge(<Stream<dynamic>>[widget.songManager.songStateStream, widget.songManager.isPlayingStream]),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        final bool isPlaying = widget.songManager.isPlaying();
        final bool isPlayingSong = widget.songManager.isPlayingSong(url);

        return Container(
          width: 120,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[800],
                      image: DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  if (hasPlayButton)
                    GestureDetector(
                      onTap: () {
                        _playPause(
                          url,
                          name: title,
                          description: 'Song from your collection',
                          pictureUrl: imagePath,
                          artist: artist,
                          songId: songId,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        child: Icon(
                          isPlaying && isPlayingSong ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Flow',
          style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, 'new').then((List<Map<String, dynamic>> value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem('New', 'https://cdn-images.dzcdn.net/images/cover/787022e34fd666a8c1e9bff902083001/232x232-none-80-0-0.png'),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, 'train').then((List<Map<String, dynamic>> value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem('Train', 'https://cdn-images.dzcdn.net/images/cover/0a6be3cc85fdaf033e0529f04acac686/232x232-none-80-0-0.png'),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, 'party').then((List<Map<String, dynamic>> value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem('Party', 'https://cdn-images.dzcdn.net/images/cover/d4b988bf7b4c286b0fa5cc60190a3275/232x232-none-80-0-0.png'),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, 'sad').then((List<Map<String, dynamic>> value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem('Sad', 'https://cdn-images.dzcdn.net/images/cover/34387ff89908f5e906e090f89f7b81a6/232x232-none-80-0-0.png'),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, 'chill').then((List<Map<String, dynamic>> value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem('Chill', 'https://cdn-images.dzcdn.net/images/cover/8480aa295e29d6231bc8509ff772b0e5/232x232-none-80-0-0.png'),
        ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowItem(String title, [String? imageUrl]) {
    return Column(
      children: <Widget>[
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF333333), // Darker gray
            image: imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMixesForYou() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      const Text(
        'Mixes for you',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        height: 160,
        child: authCookie == null
            ? const Center(child: Text('No auth cookie available'))
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: MusicApiService().getForYouTrack(authCookie!),
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No tracks available'));
                  } else {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Map<String, dynamic> track = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            widget.songManager.lunchPlaylist(
                                List<Map<String, dynamic>>.from(snapshot.data![index]['playlist'] as List<dynamic>));
                          },
                          child: Stack(
                            children: <Widget>[
                              Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[800],
                                        image: DecorationImage(
                                          image: NetworkImage(track['cover'] as String? ?? 'https://example.com/default_image.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      track['title'] as String? ?? 'Unknown Title',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
      ),
    ],
  );
}


  Widget _buildArtistsYouFollow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'From Artists You Follow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        authCookie == null
            ? const Center(child: Text('No auth cookie available'))
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: MusicApiService().getFromFollow(authCookie!),
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No tracks available'));
            } else {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  final Map<String, dynamic> release = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      _playPause(
                        release['song'] as String? ?? 'https://dl.sndup.net/q4ksm/Quack%20Quest.mp3',
                        name: release['title'] as String? ?? 'Unknown Title',
                        description: 'From Artists You Follow',
                        pictureUrl: release['cover'] as String? ?? 'https://example.com/default_image.jpg',
                        artist: release['auteur'] as String? ?? 'Unknown Auteur',
                        songId: release['song_id'] as String? ?? '',
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(release['cover'] as String? ?? 'https://example.com/default_image.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  release['title'] as String? ?? 'Unknown Title',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  release['auteur'] as String? ?? 'Unknown Auteur',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                    DateTime.fromMillisecondsSinceEpoch(int.parse(release['date'] as String)).toLocal().toString().split(' ')[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Colors.white),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildNewReleases() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'New Releases',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: authCookie == null
              ? const Center(child: Text('No auth cookie available'))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: MusicApiService().getNewTracks(authCookie!),
                  builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No tracks available'));
                    } else {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> track = snapshot.data![index];
                          return _buildAlbumCard(
                            track['title'] as String? ?? 'Unknown Title',
                            track['cover'] as String? ?? 'assets/caca.jpg',
                            track['song'] as String? ?? 'https://dl.sndup.net/q4ksm/Quack%20Quest.mp3',
                            artist: track['auteur'] as String? ?? 'MyEcoria',
                            songId: track['song_id'] as String? ?? '',
                            hasPlayButton: true,
                          );
                        },
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  
  
  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        boxShadow: <BoxShadow>[BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavItem(Icons.home_filled, 'Home', 0),
            _buildNavItem(Icons.search, 'Search', 1),
            _buildNavItem(Icons.library_music, 'Your Library', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _selectedAlbumId = null;
          _selectedArtistId = null; // Ferme la page artiste si on change d'onglet
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: isSelected ? Colors.white : Colors.white54),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSearchResults.value = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.search, color: kAccentColor),
                    SizedBox(width: 12),
                    Text(
                      'Search songs, artist, album or playlist',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.trending_up, size: 18, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Your artists',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(
            height: 130,
            child: FutureBuilder<Map<String, dynamic>>(
              future: MusicApiService().yourArtist(authCookie!),
              builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!['artist'] == null) {
                return const Center(child: Text('No artists available'));
              }
              final List<dynamic> artists = snapshot.data!['artist'] as List<dynamic>;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: artists.length,
                itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> artist = artists[index] as Map<String, dynamic>;
                return _buildArtistItem(
                  artist['artist_id'] as String? ?? '',
                  artist['auteur'] as String? ?? 'Unknown',
                  artist['cover'] as String? ?? 'assets/default_artist.jpg',
                );
                },
              );
              },
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Text(
              'Browse',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.6,
              children: <Widget>[
                _buildGenreItem('TAMIL', Colors.purple),
                _buildGenreItem('INTERNATIONAL', Colors.orange),
                _buildGenreItem('POP', Colors.teal),
                _buildGenreItem('HIP-HOP', Colors.red),
                _buildGenreItem('DANCE', Colors.blue),
                _buildGenreItem('COUNTRY', Colors.amber),
                _buildGenreItem('INDIE', Colors.indigo),
                _buildGenreItem('JAZZ', Colors.deepPurple),
              ],
            ),
          ),
          
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSearchResultsScreen() {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearchResults.value = false;
                  });
                },
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search songs, artist, album or playlist',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.white70),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (String query) async {
                      _lastQuery = query;
                      if (query.isNotEmpty) {
                        final Map<String, dynamic> results = await MusicApiService().getSearch(authCookie!, query, authCookie!);
                        setState(() {
                          _searchResults = <Map<String, dynamic>>[results]; // Wrapping the response in a list
                        });
                      } else {
                        setState(() {
                          _searchResults = <Map<String, dynamic>>[];
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: StatefulBuilder(
            builder: (BuildContext context, void Function(void Function()) setStateSB) {
              Future<void>.delayed(const Duration(seconds: 2), () async {
                if (_searchResults.isNotEmpty && 
                    _searchResults.first.containsKey('songsArray') &&
                    (_searchResults.first['songsArray'] as List<dynamic>).any((dynamic e) => (e as Map<String, dynamic>)['downloaded'] == false)) {
                  if (mounted) {
                    setStateSB(() {});
                  }
                }
                final Map<String, dynamic> results = await MusicApiService().getSearch(authCookie!, _lastQuery, authCookie!);
                setState(() {
                  _searchResults = <Map<String, dynamic>>[results];
                });
              });
              
              List<Map<String, dynamic>> songs = <Map<String, dynamic>>[];
              List<Map<String, dynamic>> artists = <Map<String, dynamic>>[];
              List<Map<String, dynamic>> albums = <Map<String, dynamic>>[];
              
              if (_searchResults.isNotEmpty) {
                final Map<String, dynamic> response = _searchResults.first;
                
                if (response.containsKey('songsArray')) {
                  songs = (response['songsArray'] as List<dynamic>)
                      .map((dynamic item) => item as Map<String, dynamic>)
                      .toList();
                }
                
                if (response.containsKey('artistsArray')) {
                  artists = (response['artistsArray'] as List<dynamic>)
                      .map((dynamic item) => item as Map<String, dynamic>)
                      .toList();
                }
                
                if (response.containsKey('albumsArray')) {
                  albums = (response['albumsArray'] as List<dynamic>)
                      .map((dynamic item) => item as Map<String, dynamic>)
                      .toList();
                }
              }
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (artists.isNotEmpty) ...<Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text(
                          'Artists',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: artists.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> artist = artists[index];
                            return _buildArtistItem(
                              artist['artist_id'] as String? ?? '',
                              artist['name'] as String? ?? 'Unknown',
                                (artist['cover'] != null && (artist['cover'] as String).contains('/images/cover/'))
                                  ? (artist['cover'] as String).replaceFirst(
                                    '/images/cover/',
                                    '/images/artist/'
                                  ).replaceFirst(
                                    RegExp(r'/\d+x\d+\.jpg'),
                                    '/500x500-000000-80-0-0.jpg'
                                  )
                                  : (artist['cover'] as String? ?? 'assets/default_artist.jpg'),
                            );
                          },
                        ),
                      ),
                    ],
                    
                    if (albums.isNotEmpty) ...<Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text(
                          'Albums',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: albums.length,
                          itemBuilder: (BuildContext context, int index) {
                            final Map<String, dynamic> album = albums[index];
                            return _buildAlbumSearchItem(
                              album['album_id']?.toString() ?? album['ALB_ID']?.toString() ?? '',
                              album['title'] as String? ?? album['name'] as String? ?? 'Unknown Album',
                              album['cover'] as String? ?? 'https://via.placeholder.com/150',
                            );
                          },
                        ),
                      ),
                    ],
                    
                    if (songs.isNotEmpty) ...<Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                        child: Text(
                          'Songs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: songs.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Map<String, dynamic> result = songs[index];
                          return _buildResultCard(result);
                        },
                      ),
                    ],
                    
                    if (songs.isEmpty && artists.isEmpty && albums.isEmpty && _searchResults.isNotEmpty) ...<Widget>[
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No results found',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 80),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtistItem(String id, String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedArtistId = id;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.network(
                imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[800],
                  child: const Icon(Icons.person, color: Colors.white54, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 70,
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildAlbumSearchItem(String id, String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        if (id.isNotEmpty) {
          setState(() {
            _selectedAlbumId = id;
          });
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenreItem(String name, Color color) {
    return GenreTile(name: name, overlayColor: color);
  }

  

  Widget _buildResultCard(Map<String, dynamic> result) {
    final bool downloaded = result['downloaded'] as bool? ?? false;
    return GestureDetector(
      onTap: downloaded
          ? () {
              _playPause(
                result['song'] as String,
                name: result['title'] as String,
                description: 'Song • ${result['auteur']}',
                pictureUrl: result['cover'] as String,
                songId: result['song_id'] as String,
                artist: result['auteur'] as String,
              );
            }
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(result['cover'] as String),
                  fit: BoxFit.cover,
                ),
                color: downloaded ? null : Colors.grey.shade800,
              ),
              child: !downloaded
                  ? const Center(
                      child: Icon(Icons.download, color: Colors.white54, size: 30),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            result['title'] as String,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            'Song • ${result['auteur']}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}