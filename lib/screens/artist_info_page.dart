import 'package:flutter/material.dart';
import '../manage/api_manage.dart';
import '../theme.dart';

class ArtistInfoPage extends StatefulWidget {
  final String artistId;
  const ArtistInfoPage({Key? key, required this.artistId}) : super(key: key);

  @override
  State<ArtistInfoPage> createState() => _ArtistInfoPageState();
}

class _ArtistInfoPageState extends State<ArtistInfoPage> {
  Map<String, dynamic>? _artist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchArtist();
  }

  Future<void> _fetchArtist() async {
    try {
      final data = await MusicApiService().getArtistInfo(widget.artistId);
      setState(() {
        _artist = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Artist Info: $_artist");
    return Scaffold(
      appBar: AppBar(
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
                            style:
                                const TextStyle(color: Colors.white70, fontSize: 16)),
                      if (_artist!["FACEBOOK"] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(_artist!["FACEBOOK"],
                              style:
                                  const TextStyle(color: Colors.white54, fontSize: 14)),
                        ),
                      if (_artist!["TWITTER"] != null)
                        Text(_artist!["TWITTER"],
                            style:
                                const TextStyle(color: Colors.white54, fontSize: 14)),
                    ],
                  ),
                ),
    );
  }
}

