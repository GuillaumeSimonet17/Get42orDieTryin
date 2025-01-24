class User {
  final int id;
  final String login;
  final String url;
  final String? displayName;
  final String? image;
  final String? email;

  User({
    required this.id,
    required this.login,
    required this.url,
    this.displayName,
    this.image,
    this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      login: json['login'] as String,
      url: json['url'] as String,
      displayName: json['displayname'] as String?,
      image: json['image_url'] as String?,
      email: json['email'] as String?,
    );
  }
}