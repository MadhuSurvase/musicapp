class SongModel {
  final int song_id; // int
  final String user_id;
  final String song_name;
  final String song_url;
  final int likes;
  final int views;
  final String image_url;
  final String lyrics;
  final List<String> tags;
  final String date_time;

  SongModel({
    required this.song_id,
    required this.user_id,
    required this.song_name,
    required this.song_url,
    required this.likes,
    required this.views,
    required this.image_url,
    required this.lyrics,
    required this.tags,
    required this.date_time,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      song_id: json['song_id'], // int
      user_id: json['user_id'], // String
      song_name: json['song_name'], // String
      song_url: json['song_url'], // String
      likes: json['likes'], // int
      views: json['views'], // int
      image_url: json['image_url'], // String
      lyrics: json['lyrics'], // String
      tags: List<String>.from(json['tags']), // List<String>
      date_time: json['date_time'], // String
    );
  }
}


