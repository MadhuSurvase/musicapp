import 'package:flutter/material.dart';
import '../models/song.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  List<SongModel> _songs = [];
  final String baseUrl = 'http://143.244.131.156:8000'; // Base URL for the API

  User? get user => _user;
  List<SongModel> get songs => _songs;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void setSongs(List<SongModel> songs) {
    _songs = songs;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final response = await ApiService(baseUrl: baseUrl, authToken: '').login(email, password);
    _user = User.fromJson(response);
    notifyListeners();
  }

  Future<void> signup(String email, String password, String name) async {
    final response = await ApiService(baseUrl: baseUrl, authToken: '').signup(email, password, name);
    _user = User.fromJson(response);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
