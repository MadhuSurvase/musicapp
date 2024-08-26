import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:memesoundapp/songlistscreen.dart';

import 'createcustom.dart';
import 'mp3screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController songController = TextEditingController();
  Map<String, dynamic> _createdSongData = {};
  int _selectedIndex = 0;
  bool _isLoading = false;
  bool _isPlaying = false;
  String? token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6Imthdml0YUBnbWFpbC5jb20iLCJleHAiOjE3MjM4MjE3NDh9.WxytnrzE1syqYZUFyxzuMLTteDKHSh40xZ7PePQUxRQ"; // Set your token here for testing
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Song'),
      ),
      body: SafeArea(
        child: SingleChildScrollView( // Allow vertical scrolling to avoid overflow
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: songController,
                  decoration: InputDecoration(
                    labelText: 'Enter song details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
                SizedBox(height: 50),
                Center(
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.limeAccent),
                    ),
                    onPressed: createSong,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(
                      "Create Song",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                if (_createdSongData.isNotEmpty)
                  Center(
                    child: Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_createdSongData["image_url"] != null) ...[
                                Image.network(
                                  _createdSongData["image_url"],
                                  height: 100,
                                ),
                                SizedBox(width: 16),
                              ],
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Song Name: ${_createdSongData["song_name"]}',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Song Id: ${_createdSongData["song_id"]}'),
                                  Text('User Id: ${_createdSongData["user_id"]}'),
                                  Row(
                                    children: [
                                      Text('Likes: ${_createdSongData["likes"]}'),
                                      SizedBox(width: 4),
                                      Icon(Icons.favorite, color: Colors.red, size: 16),
                                    ],
                                  ),
                                  Text('Views: ${_createdSongData["views"]}'),
                                  Text('Lyrics: ${_createdSongData["lyrics"]}'),
                                  Text('Tags: ${_createdSongData["tags"].join(', ')}'),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(Colors.limeAccent),
                                    ),
                                    onPressed: () {
                                      _playPause(_createdSongData["song_url"]);
                                    },
                                    child: Text(
                                      _isPlaying ? "Pause Song" : "Play Song",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
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
                      authToken: token!,
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

  Future<void> createSong() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://143.244.131.156:8000/create'),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"song": songController.text}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        setState(() {
          _createdSongData = {
            "song_id": responseData['song_id'],
            "user_id": responseData['user_id'],
            "song_name": responseData['song_name'],
            "song_url": responseData['song_url'],
            "likes": responseData['likes'],
            "views": responseData['views'],
            "image_url": responseData['image_url'],
            "lyrics": responseData['lyrics'],
            "tags": responseData['tags'],
            "date_time": responseData['date_time'],
          };
        });
      } else {
        print('Failed to create song: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
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
        await _audioPlayer.setSourceUrl("https://soundofmeme.s3.amazonaws.com/d8e8b5e1-f013-45df-b82f-ae1cb76df8a6.mp3");
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
}
