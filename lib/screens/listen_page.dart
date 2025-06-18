/*
** EPITECH PROJECT, 2025
** music_app_home_page.dart
** File description:
** Home page for the Deezer app.
** This file contains the main UI and logic for the home screen of the app.
** It displays various sections like recently played songs, mixes for you,
** artists you follow, new releases, and recommended playlists.
** It also handles the playback of songs using the SongManager.
*/

import 'dart:ffi';

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

void main() {
  runApp(const MyApp());
}

class GenreTile extends StatelessWidget {
  final String name;
  final Color overlayColor;

  const GenreTile({
    Key? key,
    required this.name,
    required this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/illustrator/${name.toLowerCase()}.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            color: overlayColor.withOpacity(0.2),
            colorBlendMode: BlendMode.srcOver,
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: overlayColor.withOpacity(0.6),
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

class MyApp extends StatelessWidget {
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

class MusicAppHomePage extends StatefulWidget {
  final SongManager songManager;

  const MusicAppHomePage({Key? key, required this.songManager}) : super(key: key);

  @override
  _MusicAppHomePageState createState() => _MusicAppHomePageState();
}

class _MusicAppHomePageState extends State<MusicAppHomePage> {
  List<Map<String, dynamic>> _searchResults = [];
  String _lastQuery = "";
  CacheService cache = CacheService();
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  String? authCookie;
  int _currentIndex = 0;
  final ValueNotifier<bool> _isSearchResults = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isPageSearch = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _loadCookie();
  }

  Future<void> _loadCookie() async {
    String? value = await _secureStorage.read(key: 'auth');
    setState(() {
      authCookie = value;
    });
  }

  @override
  void dispose() {
    widget.songManager.dispose();
    super.dispose();
  }

  String extractFirstNameFromEmail(String email) {
    if (!email.contains('@epitech.eu')) {
      throw ArgumentError('L\'email doit être au format prenom.nom@epitech.eu');
    }
    List<String> parts = email.split('@');
    String localPart = parts[0];
    List<String> nameParts = localPart.split('.');
    String firstName = nameParts[0];
    firstName = firstName[0].toUpperCase() + firstName.substring(1);
    return firstName;
  }

  void _playPause(String songUrl, {String name = "", String description = "", String pictureUrl = "", String artist = "", String songId = "", bool instant = true}) async {
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

  @override
  Widget build(BuildContext context) {
    bool isPlaying = widget.songManager.isPlaying();
    final songState = widget.songManager.getSongState();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: ValueListenableBuilder<bool>(
              valueListenable: _isPageSearch,
              builder: (context, isPageSearch, child) {
                return _currentIndex == 0 
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                    ) 
                  : _currentIndex == 1 
                    ? ValueListenableBuilder<bool>(
                        valueListenable: _isSearchResults,
                        builder: (context, isSearchResults, child) {
                          return isSearchResults ? _buildSearchResultsScreen() : _buildSearchScreen();
                        },
                      )
                    : LibraryPage(songManager: widget.songManager, authCookie: authCookie);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StreamBuilder<Map<String, dynamic>>(
              stream: widget.songManager.songStateStream,
              builder: (context, snapshot) {
                final currentSongState = snapshot.data ?? {};
                return AudioPlayerWidget(
                  songManager: widget.songManager,
                  currentSongTitle: currentSongState['name'] ?? "Blinding Lights",
                  currentArtist: currentSongState['artist'] ?? "MyEcoria",
                  albumArtUrl: currentSongState['pictureUrl'] ?? "https://example.com/album_cover.jpg",
                  duration: const Duration(minutes: 3, seconds: 45),
                  onPlayPause: () => _playPause(
                    currentSongState['songUrl'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                    name: currentSongState['name'] ?? "Blinding Lights",
                    description: currentSongState['description'] ?? "",
                    pictureUrl: currentSongState['pictureUrl'] ?? "https://example.com/album_cover.jpg",
                    songId: currentSongState['song_id'] ?? "",
                  ),
                  lyricsExcerpt: "I've been tryna call, I've been on my own for long enough...",
                  isFavorite: false,
                  onToggleFavorite: () {
                    MusicApiService().createLike(currentSongState['songId'] ?? "", authCookie!);
                  },
                  onShare: () {
                    // Implement share functionality
                  },
                  isPlaying: isPlaying,
                  nextSongTitle: "Save Your Tears",
                  nextSongArtist: "The Weeknd",
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
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.waving_hand,
              color: Colors.amber,
              size: 20,
            ),
            const SizedBox(width: 4),
            FutureBuilder<String?>(
              future: cache.getCacheValue('email') as Future<String?>?,
              builder: (context, snapshot) {
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
            print('snapshot.data: ${snapshot.data}');
            return Text(
              "Hi ${extractFirstNameFromEmail(snapshot.data ?? 'default.name@epitech.eu')},",
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
              builder: (context, snapshot) {
                final username = extractFirstNameFromEmail(snapshot.data ?? 'default.name@epitech.eu');
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Recently Played",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Text(
            //   "See more",
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: authCookie == null
              ? const Center(child: Text('No auth cookie available'))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: MusicApiService().getLatestTracks(authCookie!),
                  builder: (context, snapshot) {
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
                        itemBuilder: (context, index) {
                          final track = snapshot.data![index];
                          debugPrint('track: $track');
                          return _buildAlbumCard(
                            track['title'] ?? 'Unknown Title',
                            track['cover'] ?? 'assets/caca.jpg',
                            track['song'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                            artist: track['auteur'] ?? 'MyEcoria',
                            songId: track['song_id'] ?? "",
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

  Widget _buildAlbumCard(String title, String imagePath, String url, {bool hasPlayButton = false, String artist = "", String songId = ""}) {
    return StreamBuilder(
      stream: StreamGroup.merge([widget.songManager.songStateStream, widget.songManager.isPlayingStream]),
      builder: (context, snapshot) {
        bool isPlaying = widget.songManager.isPlaying();
        bool isPlayingSong = widget.songManager.isPlayingSong(url);

        return Container(
          width: 120,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
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
                          description: "Song from your collection",
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
      children: [
        const Text(
          "Flow",
          style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, "new").then((value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem("New", "https://cdn-images.dzcdn.net/images/cover/787022e34fd666a8c1e9bff902083001/232x232-none-80-0-0.png"),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, "train").then((value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem("Train", "https://cdn-images.dzcdn.net/images/cover/0a6be3cc85fdaf033e0529f04acac686/232x232-none-80-0-0.png"),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, "party").then((value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem("Party", "https://cdn-images.dzcdn.net/images/cover/d4b988bf7b4c286b0fa5cc60190a3275/232x232-none-80-0-0.png"),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, "sad").then((value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem("Sad", "https://cdn-images.dzcdn.net/images/cover/34387ff89908f5e906e090f89f7b81a6/232x232-none-80-0-0.png"),
        ),
        GestureDetector(
          onTap: () {
            MusicApiService().getFlow(authCookie!, "chill").then((value) {
              widget.songManager.lunchPlaylist(value);
            });
          },
          child: _buildFlowItem("Chill", "https://cdn-images.dzcdn.net/images/cover/8480aa295e29d6231bc8509ff772b0e5/232x232-none-80-0-0.png"),
        ),
          ],
        ),
      ],
    );
  }

  Widget _buildFlowItem(String title, [String? imageUrl]) {
    return Column(
      children: [
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
    children: [
      const Text(
        "Mixes for you",
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
                builder: (context, snapshot) {
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
                      itemBuilder: (context, index) {
                        final track = snapshot.data![index];
                        return GestureDetector(
                          onTap: () {
                            widget.songManager.lunchPlaylist(
                                List<Map<String, dynamic>>.from(snapshot.data![index]['playlist']));
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 130,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[800],
                                        image: DecorationImage(
                                          image: NetworkImage(track["cover"] ?? 'https://example.com/default_image.jpg'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      track["title"] ?? 'Unknown Title',
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "From Artists You Follow",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Text(
            //   "See more",
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 16),
        authCookie == null
            ? const Center(child: Text('No auth cookie available'))
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: MusicApiService().getFromFollow(authCookie!),
          builder: (context, snapshot) {
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
                itemBuilder: (context, index) {
                  final release = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      _playPause(
                        release["song"] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                        name: release["title"] ?? 'Unknown Title',
                        description: "From Artists You Follow",
                        pictureUrl: release["cover"] ?? 'https://example.com/default_image.jpg',
                        artist: release["auteur"] ?? 'Unknown Auteur',
                        songId: release["song_id"] ?? "",
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(release["cover"] ?? 'https://example.com/default_image.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  release["title"] ?? 'Unknown Title',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  release["auteur"] ?? 'Unknown Auteur',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                    DateTime.fromMillisecondsSinceEpoch(int.parse(release["date"])).toLocal().toString().split(' ')[0],
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "New Releases",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // Text(
            //   "See more",
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.white,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: authCookie == null
              ? const Center(child: Text('No auth cookie available'))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: MusicApiService().getNewTracks(authCookie!),
                  builder: (context, snapshot) {
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
                        itemBuilder: (context, index) {
                          final track = snapshot.data![index];
                          return _buildAlbumCard(
                            track['title'] ?? 'Unknown Title',
                            track['cover'] ?? 'assets/caca.jpg',
                            track['song'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                            artist: track['auteur'] ?? 'MyEcoria',
                            songId: track['song_id'] ?? "",
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

  Widget _buildRecommendedPlaylists() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended Playlists",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: authCookie == null
              ? const Center(child: Text('No auth cookie available'))
              : FutureBuilder<List<Map<String, dynamic>>>(
                  future: MusicApiService().getForYouTrack(authCookie!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No mixes available'));
              } else {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final mix = snapshot.data![index];
                    final mixSongs = (mix['songs'] ?? []) as List<dynamic>;
                    return GestureDetector(
                      onTap: () {
                        widget.songManager.clearQueue();
                        for (int i = 0; i < mixSongs.length; i++) {
                          _playPause(
                            mixSongs[i]["song"] as String,
                            name: mixSongs[i]["name"] as String,
                            description: "From ${mix["name"]}",
                            pictureUrl: mixSongs[i]["picture"] as String,
                            artist: mixSongs[i]["artist"] as String,
                            songId: mixSongs[i]["song_id"] as String,
                            instant: i == 0,
                          );
                        }
                      },
                      child: Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey[800],
                                image: DecorationImage(
                                  image: NetworkImage(mixSongs[0]["picture"] as String),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mix["name"] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mix["artist"] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
        ),
      ],
    );
  }
  
  Widget _buildBottomNavigation() {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, "Home", 0),
            _buildNavItem(Icons.search, "Search", 1),
            _buildNavItem(Icons.library_music, "Your Library", 2),
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
          // Only use _isPageSearch for toggling between home and search
          if (index <= 1) {
            _isPageSearch.value = (index == 1);
          }
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
        children: [
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
                child: Row(
                  children: const [
                    Icon(Icons.search, color: Colors.grey),
                    SizedBox(width: 12),
                    Text(
                      "Search songs, artist, album or playlist",
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
              children: [
                Icon(Icons.trending_up, size: 18, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  "Your artists",
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
              builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!['artist'] == null) {
                return const Center(child: Text('No artists available'));
              }
              List<dynamic> artists = snapshot.data!['artist'];
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: artists.length,
                itemBuilder: (context, index) {
                final artist = artists[index];
                return _buildArtistItem(
                  artist['auteur'] ?? 'Unknown',
                  artist['cover'] ?? 'assets/default_artist.jpg',
                );
                },
              );
              },
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
            child: Text(
              "Browse",
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
              children: [
                _buildGenreItem("TAMIL", Colors.purple),
                _buildGenreItem("INTERNATIONAL", Colors.orange),
                _buildGenreItem("POP", Colors.teal),
                _buildGenreItem("HIP-HOP", Colors.red),
                _buildGenreItem("DANCE", Colors.blue),
                _buildGenreItem("COUNTRY", Colors.amber),
                _buildGenreItem("INDIE", Colors.indigo),
                _buildGenreItem("JAZZ", Colors.deepPurple),
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
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
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
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search songs, artist, album or playlist",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (query) async {
                      _lastQuery = query;
                      if (query.isNotEmpty) {
                        debugPrint(query);
                        var results = await MusicApiService().getSearch(authCookie!, query);
                        debugPrint(results.toString());
                        setState(() {
                          _searchResults = results;
                        });
                      } else {
                        setState(() {
                          _searchResults = [];
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Search results",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        Expanded(
          child: StatefulBuilder(
            builder: (context, setStateSB) {
              Future<void>.delayed(const Duration(seconds: 2), () async {
                if (_searchResults.any((e) => e['downloaded'] == false)) {
                  if (mounted) setStateSB(() {});
                }
                var results = await MusicApiService().getSearch(authCookie!, _lastQuery);
                setState(() {
                  _searchResults = results;
                });
              });
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final result = _searchResults[index];
                  return _buildRecentSearchItem(
                    result['title'],
                    "Song • ${result['auteur']}",
                    result['cover'],
                    result['song'],
                    result['song_id'],
                    result['auteur'],
                    result['downloaded'] ?? false,
                  );
                },
              );
            },
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _searchResults = [];
                });
              },
              child: const Text(
                "Clear history",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildArtistItem(String name, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade700,
            backgroundImage: NetworkImage(imageUrl),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreItem(String name, Color color) {
    return GenreTile(name: name, overlayColor: color);
  }

  Widget _buildRecentSearchItem(String title, String subtitle, String imageUrl, String songUrl, String songId, String artist, bool downloaded) {
  return GestureDetector(
    onTap: downloaded
        ? () {
            _playPause(
              songUrl,
              name: title,
              description: subtitle,
              pictureUrl: imageUrl,
              songId: songId,
              artist: artist,
            );
          }
        : null,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              color: downloaded ? null : Colors.grey.shade800,
            ),
            child: !downloaded
                ? const Center(
                    child: Icon(Icons.download, color: Colors.white54, size: 28),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: downloaded ? Colors.white : Colors.white54,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: downloaded ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
