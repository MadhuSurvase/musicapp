import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:memesoundapp/models/song.dart';

class SongDetailScreen extends StatelessWidget {
  final SongModel song;

  final AudioPlayer _audioPlayer = AudioPlayer();

  SongDetailScreen({required this.song});

  void _playSong() {
    _audioPlayer.play(UrlSource(song.song_url));
  }

  void _pauseSong() {
    _audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(song.song_name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      song.image_url,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 8),
                    Text(
                      song.song_name,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "By ${song.user_id}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Likes: ${song.likes}  Views: ${song.views}",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 4.0,
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  song.lyrics,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                ),
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.limeAccent),
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                  ),
                  onPressed: _playSong,
                  child: Text('Play Song'),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.limeAccent),
                    padding: MaterialStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    ),
                  ),
                  onPressed: _pauseSong,
                  child: Text('Pause Song'),
                ),
              ],
            ),
          ],
        ),
      ),


    );
  }
}
