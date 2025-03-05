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

import 'package:flutter/material.dart';
import '../manage/widget_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../manage/song_manage.dart';
import '../manage/api_manage.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

void main() {
  runApp(const MyApp());
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
  @override
  void dispose() {
    widget.songManager.dispose();
    super.dispose();
  }

  void _playPause(String songUrl, {String name = "", String description = "", String pictureUrl = "", String artist = "", bool instant = true}) async {
    debugPrint('Toggling play/pause for $name/$songUrl/$pictureUrl/$artist/$instant/$description');
    await widget.songManager.togglePlaySong(
      name: name,
      description: description,
      songUrl: songUrl,
      pictureUrl: pictureUrl,
      artist: artist,
      instant: instant,
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
            child: SingleChildScrollView(
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
                    const SizedBox(height: 24),
                    _buildRecommendedPlaylists(),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AudioPlayerWidget(
              songManager: widget.songManager,
              currentSongTitle: songState['name'] ?? "Blinding Lights",
              currentArtist: songState['artist'] ?? "MyEcoria",
              albumArtUrl: songState['pictureUrl'] ?? "https://example.com/album_cover.jpg",
              duration: const Duration(minutes: 3, seconds: 45),
              onPlayPause: () => _playPause(
                songState['songUrl'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                name: songState['name'] ?? "Blinding Lights",
                description: songState['description'] ?? "",
                pictureUrl: songState['pictureUrl'] ?? "https://example.com/album_cover.jpg",
              ),
              lyricsExcerpt: "I've been tryna call, I've been on my own for long enough...",
              isFavorite: false,
              onToggleFavorite: () {
                // Implement favorite toggle functionality
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
            FutureBuilder<String>(
              future: FlutterSecureStorage().read(key: 'name').then((value) => value ?? ''),
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
                  return Text(
                    "Hi ${snapshot.data},",
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
              future: FlutterSecureStorage().read(key: 'name'),
              builder: (context, snapshot) {
                final username = snapshot.data ?? 'MyEcoria';
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
            Text(
              "See more",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: MusicApiService().getLatestTracks(),
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
                      track['name'] ?? 'Unknown Title',
                      track['picture'] ?? 'assets/caca.jpg',
                      track['song'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                      artist: track['artist'] ?? 'MyEcoria',
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

  Widget _buildAlbumCard(String title, String imagePath, String url, {bool hasPlayButton = false, String artist = ""}) {
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
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: Icon(
                      widget.songManager.isPlaying() && widget.songManager.isPlayingSong(url) ? Icons.pause : Icons.play_arrow,
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
            _buildFlowItem("New", "https://cdn-images.dzcdn.net/images/cover/787022e34fd666a8c1e9bff902083001/232x232-none-80-0-0.png"),
            _buildFlowItem("Train", "https://cdn-images.dzcdn.net/images/cover/0a6be3cc85fdaf033e0529f04acac686/232x232-none-80-0-0.png"),
            _buildFlowItem("Party", "https://cdn-images.dzcdn.net/images/cover/d4b988bf7b4c286b0fa5cc60190a3275/232x232-none-80-0-0.png"),
            _buildFlowItem("Sad", "https://cdn-images.dzcdn.net/images/cover/34387ff89908f5e906e090f89f7b81a6/232x232-none-80-0-0.png"),
            _buildFlowItem("Chill", "https://cdn-images.dzcdn.net/images/cover/8480aa295e29d6231bc8509ff772b0e5/232x232-none-80-0-0.png"),
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
          height: 200,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: MusicApiService().getForYouTracks(),
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
            Text(
              "See more",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: MusicApiService().getFollowTracks(),
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
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(release["picture"] ?? 'https://example.com/default_image.jpg'),
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
                                release["artist"] ?? 'Unknown Artist',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                release["name"] ?? 'Unknown Title',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                release["date"] ?? 'Unknown Time',
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
            Text(
              "See more",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: MusicApiService().getNewReleases(),
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
                      track['name'] ?? 'Unknown Title',
                      track['picture'] ?? 'assets/caca.jpg',
                      track['song'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
                      artist: track['artist'] ?? 'MyEcoria',
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
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: MusicApiService().getForYouTracks(),
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
    return BottomNavigationBar(
      backgroundColor: Colors.black,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Search",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: "Your Library",
        ),
      ],
      currentIndex: 0,
    );
  }
}
