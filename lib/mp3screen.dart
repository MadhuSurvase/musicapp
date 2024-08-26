import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:memesoundapp/songlistscreen.dart';
import 'dart:convert';
import 'package:mime/mime.dart';

import 'createcustom.dart';
import 'homescreen.dart';

class CloneSongScreen extends StatefulWidget {
  final String authToken;

  CloneSongScreen({required this.authToken});

  @override
  _CloneSongScreenState createState() => _CloneSongScreenState();
}

class _CloneSongScreenState extends State<CloneSongScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _mp3File;
  final _promptController = TextEditingController();
  final _lyricsController = TextEditingController();
  Map<String, dynamic>? _songDetails;
  String? _errorMessage;
  bool _isLoading = false;
  int _selectedIndex = 0;

  void _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final mimeType = lookupMimeType(file.path);

      print('Selected file path: ${file.path}');
      print('Detected MIME type: $mimeType');

      // Check MIME type and file extension
      if (mimeType == 'audio/mpeg' || file.path.endsWith('.mp3')) {
        setState(() {
          _mp3File = file;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _mp3File = null;
          _errorMessage = 'Selected file is not an MP3';
        });
      }
    }
  }


  Future<void> _cloneSong() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true; // Set loading to true before starting the request
      });

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://143.244.131.156:8000/clonesong'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', _mp3File!.path),
      );
      request.fields['prompt'] = _promptController.text;
      request.fields['lyrics'] = _lyricsController.text;

      // Use the authToken passed from the previous screen
      request.headers['Authorization'] = 'Bearer ${widget.authToken}';

      try {
        final response = await request.send();

        if (!mounted) return;

        final responseData = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          final decodedData = json.decode(responseData);
          setState(() {
            _songDetails = decodedData;
            _errorMessage = null;
          });
        } else {
          setState(() {
            _songDetails = null;
            _errorMessage = 'Failed to clone song: ${response.statusCode} - $responseData';
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _songDetails = null;
          _errorMessage = 'Failed to clone song: $e';
        });
      } finally {
        setState(() {
          _isLoading = false; // Reset loading state after the request completes
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clone Song')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: _pickFile,
                child: Text('Pick MP3 File'),
              ),
              if (_mp3File != null)
                Column(
                  children: [
                    Text('File selected: ${_mp3File!.path}'),
                    if (lookupMimeType(_mp3File!.path) == 'audio/mpeg')
                      Text('File type: MP3')
                    else
                      Text('Error: Selected file is not an MP3'),
                  ],
                ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        labelText: 'Prompt',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a prompt';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _lyricsController,
                      decoration: InputDecoration(
                        labelText: 'Lyrics',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter lyrics';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(Colors.limeAccent),
                ),
                onPressed: _isLoading ? null : () async { await _cloneSong(); },
                child: _isLoading ? CircularProgressIndicator() : Text('Clone Song'),
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: 20),
                Text('Error: $_errorMessage', style: TextStyle(color: Colors.red)),
              ],
              if (_songDetails != null) ...[
                SizedBox(height: 20),
                Text('Song ID: ${_songDetails!['song_id']}'),
                Text('User ID: ${_songDetails!['user_id']}'),
                Text('Song Name: ${_songDetails!['song_name']}'),
                Text('Song URL: ${_songDetails!['song_url']}'),
                Text('Likes: ${_songDetails!['likes']}'),
                Text('Views: ${_songDetails!['views']}'),
                Image.network(_songDetails!['image_url']),
                Text('Lyrics: ${_songDetails!['lyrics']}'),
                Text('Tags: ${(_songDetails!['tags'] as List).join(', ')}'),
                Text('Date/Time: ${_songDetails!['date_time']}'),
              ],
            ],
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
                    builder: (context) => CloneSongScreen(authToken: widget.authToken),
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
