import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:memesoundapp/homescreen.dart';
import 'package:memesoundapp/songlistscreen.dart';
import 'package:memesoundapp/mp3screen.dart'; // Make sure to include the right import

class CreateSongScreen extends StatefulWidget {
  @override
  _CreateSongScreenState createState() => _CreateSongScreenState();
}

class _CreateSongScreenState extends State<CreateSongScreen> {
  final _titleController = TextEditingController();
  final _lyricsController = TextEditingController();
  final _genreController = TextEditingController();
  bool _isLoading = false;
  bool _isSongCreated = false;
  bool _isPlaying = false;
  int _selectedIndex = 0;
  Map<String, dynamic>? _songDetails;
  AudioPlayer _audioPlayer = AudioPlayer();
  String? _songUrl;
  final _jwtToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InNod2V0YTEyM0BnbWFpbC5jb20iLCJleHAiOjE3MjM4ODI2MjZ9.vRyMU-zvfDoM8LN2Cnascd415H9_v0cUWBDq-gZoH_0';

  Future<Map<String, dynamic>> createCustomSong({
    required String title,
    required String lyrics,
    required String genre,
    required String jwtToken,
  }) async {
    final url = 'http://143.244.131.156:8000/createcustom';
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $jwtToken',
    };

    final body = json.encode({
      'title': title,
      'lyric': lyrics,
      'genere': genre,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create custom song: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error making request: $e');
      rethrow;
    }
  }

  Future<void> _createSong() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await createCustomSong(
        title: _titleController.text,
        lyrics: _lyricsController.text,
        genre: _genreController.text,
        jwtToken: _jwtToken,
      );

      setState(() {
        _songDetails = response;
        _isSongCreated = true;
        _songUrl = response['song_url'];
      });
    } catch (e) {
      print('Error creating song: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating song: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playPause(String songUrl) async {
    try {
      if (_isPlaying) {
        await _audioPlayer.stop();
      } else {
        await _audioPlayer.setSourceUrl(songUrl);
        await _audioPlayer.resume();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print("Error in play/pause: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Custom Song')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _lyricsController,
                  decoration: InputDecoration(
                      labelText: 'Lyrics',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _genreController,
                  decoration: InputDecoration(
                      labelText: 'Genre',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      )),
                ),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.limeAccent)),
                    onPressed: _isLoading
                        ? null
                        : () async {
                      await _createSong();
                    },
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                      'Create Song',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_isSongCreated && _songDetails != null)
                  Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_songDetails!['image_url'] != null)
                            Image.network(_songDetails!['image_url']),
                          SizedBox(height: 10),
                          Text(
                            'Title: ${_songDetails!['song_name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Likes: ${_songDetails!['likes']}'),
                          Text('Views: ${_songDetails!['views']}'),
                          Text('Date: ${_songDetails!['date_time']}'),
                          SizedBox(height: 10),
                          Text(
                            'Lyrics:\n${_songDetails!['lyrics']}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Tags: ${(_songDetails!['tags'] as List).join(', ')}'),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.limeAccent),
                            ),
                            onPressed: () {
                              _playPause(_songDetails!["song_url"]);
                            },
                            child: Text(
                              _isPlaying ? "Pause Song" : "Play Song",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Icon(Icons.home, color: Colors.grey),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateSongScreen()),
                );
              },
              child: Icon(Icons.my_library_music, color: Colors.grey),
            ),
            label: 'customsong',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CloneSongScreen(
                      authToken: 'your_auth_token',
                    ),
                  ),
                );
              },
              child: Icon(Icons.supervised_user_circle, color: Colors.grey),
            ),
            label: 'cloneSong',
          ),
          BottomNavigationBarItem(
            icon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SongListScreen(),
                  ),
                );
              },
              child: Icon(Icons.queue_music_outlined, color: Colors.grey),
            ),
            label: 'AllSong',
          ),
        ],
      ),
    );
  }
}
