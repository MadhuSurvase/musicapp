import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class AudioSourse extends StatefulWidget {
  const AudioSourse({super.key});

  @override
  State<AudioSourse> createState() => _AudiosourseState();

  static uri(String s) {

  }
}

class _AudiosourseState extends State<AudioSourse> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      child: Text('Play Song'),
      onPressed: () async {
        await _audioPlayer.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
      },
    );
  }
}