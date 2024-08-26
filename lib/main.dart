import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'signupscreen.dart';
import 'homescreen.dart';
import 'loginscreen.dart';
import 'models/song.dart';

void main() {
  Map<String, dynamic> songData = {
    "song_id": 1, // Changed to int
    "user_id": "user_id",
    "song_name": "song_name",
    "song_url": "song_url",
    "likes": 10,
    "views": 200,
    "image_url": "image_url",
    "lyrics": "lyrics_value",
    "tags": ["tag1", "tag2", "tag3"],
    "date_time": "date_time_value"
  };

  SongModel songModel = SongModel.fromJson(songData);

  runApp(
    ChangeNotifierProvider(
      create: (context) {
        AuthProvider authProvider = AuthProvider();
        authProvider.setSongs([songModel]);
        return authProvider;
      },
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Sound App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => Consumer<AuthProvider>(
          builder: (context, auth, _) {

            return auth.user == null ? LoginScreen() : HomeScreen();
          },
        ),
        '/signup': (context) => SignupScreen(),
      },
    );
  }
}
