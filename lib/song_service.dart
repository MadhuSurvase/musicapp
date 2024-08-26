import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/song.dart';

class SongService {
  Future<List<SongModel>> fetchSongs({required int page}) async {
    try {
      final response = await http.get(Uri.parse('http://143.244.131.156:8000/allsongs?page=$page'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> songList = jsonResponse['songs'];

        return songList.map((json) => SongModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load songs');
      }
    } catch (error) {
      throw Exception('Error fetching songs: $error');
    }
  }
}
