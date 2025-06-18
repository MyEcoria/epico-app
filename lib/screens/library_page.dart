import 'package:flutter/material.dart';
import '../manage/song_manage.dart';
import '../manage/api_manage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../logger.dart';

class LibraryPage extends StatefulWidget {
  final SongManager songManager;
  final String? authCookie;

  const LibraryPage({Key? key, required this.songManager, this.authCookie}) : super(key: key);

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  List<Map<String, dynamic>> _recentlyPlayed = [];
  bool _isLoading = true;
  String _likedCount = '0';
  String _artistCount = '0';
  
  @override
  void initState() {
    super.initState();
    _loadRecentlyPlayed();
    _loadLikedCount();
    _loadArtistCount();
  }

  Future<void> _loadRecentlyPlayed() async {
    setState(() {
      _isLoading = true;
    });
    
    if (widget.authCookie != null) {
      try {
        final tracks = await MusicApiService().getLatestTracks(widget.authCookie!);
        setState(() {
          _recentlyPlayed = tracks;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        AppLogger.log('Error loading recently played tracks: $e');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLikedCount() async {
    if (widget.authCookie != null) {
      try {
        final count = await MusicApiService().countLiked(widget.authCookie!);
        setState(() {
          _likedCount = count;
        });
      } catch (e) {
        AppLogger.log('Error loading liked count: $e');
      }
    }
  }

  Future<void> _loadArtistCount() async {
    if (widget.authCookie != null) {
      try {
        final count = await MusicApiService().countFollow(widget.authCookie!);
        setState(() {
          _artistCount = count;
        });
      } catch (e) {
        AppLogger.log('Error loading artist count: $e');
      }
    }
  }

  void _playSong(Map<String, dynamic> track) {
    widget.songManager.togglePlaySong(
      name: track['title'] ?? 'Unknown Title',
      description: 'From Your Library',
      songUrl: track['song'] ?? "https://dl.sndup.net/q4ksm/Quack%20Quest.mp3",
      pictureUrl: track['cover'] ?? 'assets/caca.jpg',
      artist: track['auteur'] ?? 'Unknown Artist',
      songId: track['song_id'] ?? "",
      instant: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Page title
            const Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: Text(
                'Your Library',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
// Collection categories (2x2 grid)
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.8, // Ajuste le ratio
    mainAxisExtent: 100, // Hauteur fixe pour éviter l’overflow
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
  ),
  itemCount: 4,
  itemBuilder: (context, index) {
    switch (index) {
      case 0:
        return _buildCollectionCard(
          icon: Icons.favorite,
          title: 'Liked Songs',
          subtitle: '$_likedCount songs',
          onTap: () {},
        );
      case 1:
        return _buildCollectionCard(
          icon: Icons.download,
          title: 'Downloads',
          subtitle: '210 songs',
          onTap: () {},
        );
      case 2:
        return _buildCollectionCard(
          icon: Icons.playlist_play,
          title: 'Playlists',
          subtitle: '12 playlists',
          onTap: () {},
        );
      case 3:
        return _buildCollectionCard(
          icon: Icons.person,
          title: 'Artists',
          subtitle: '$_artistCount artists',
          onTap: () {},
        );
      default:
        return Container();
    }
  },
),
            
            // Recently played section
            Padding(
              padding: const EdgeInsets.only(top: 28.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recently Played',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // See more functionality
                    },
                    child: const Text(
                      'See more',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Recently played songs list
            _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: _recentlyPlayed.take(6).map((track) => _buildRecentTrackItem(track)).toList(),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTrackItem(Map<String, dynamic> track) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: NetworkImage(track['cover'] ?? 'assets/caca.jpg'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      title: Text(
        track['title'] ?? 'Unknown Title',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track['auteur'] ?? 'Unknown Artist',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[400],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.white70),
        onPressed: () {
          // Show options menu
        },
      ),
      onTap: () => _playSong(track),
    );
  }
}