
class User {
  String name;
  String email;
  String accessToken;

  User({required this.name, required this.email, required this.accessToken});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      accessToken: json['access_token'],
    );
  }
}
