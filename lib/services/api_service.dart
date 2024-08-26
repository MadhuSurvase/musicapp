import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final String authToken;

  ApiService({required this.baseUrl, required this.authToken});

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }


  Future<Map<String, dynamic>> signup(String email, String password, String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to sign up');
    }
  }

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $authToken',
  };


  Future<Map<String, dynamic>> createCustomSong(String title, String lyric, String genre) async {
    final response = await http.post(
      Uri.parse('$baseUrl/createcustom'),
      headers: headers,
      body: jsonEncode({'title': title, 'lyric': lyric, 'genre': genre}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create custom song');
    }
  }

  Future<Map<String, dynamic>> getUserSongs(int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl/usersongs?page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user songs');
    }
  }

  Future<Map<String, dynamic>> getAllSongs(int page) async {
    final response = await http.get(
      Uri.parse('$baseUrl/allsongs?page=$page'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get all songs');
    }
  }

  Future<Map<String, dynamic>> getUserDetails() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get user details');
    }
  }

  Future<Map<String, dynamic>> getSongById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getsongbyid?id=$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get song by ID');
    }
  }

  Future<Map<String, dynamic>> likeSong(int songId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'song_id': songId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to like song');
    }
  }

  Future<Map<String, dynamic>> dislikeSong(int songId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/dislike'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'song_id': songId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to dislike song');
    }
  }

  Future<Map<String, dynamic>> viewSong(int songId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/view'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'song_id': songId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to view song');
    }
  }

  Future<Map<String, dynamic>> cloneSong(String filePath, String prompt, String lyrics) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/clonesong'));
    request.headers['Authorization'] = 'Bearer $authToken';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    request.fields['prompt'] = prompt;
    request.fields['lyrics'] = lyrics;

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    } else {
      throw Exception('Failed to clone song');
    }
  }
}
