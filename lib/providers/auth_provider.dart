import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  DateTime? _expiresAt;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _expiresAt!.isAfter(DateTime.now());

  // URL d'authentification OAuth2
  final String _authUrl = "https://api.intra.42.fr/oauth/authorize";
  final String _tokenUrl = "https://api.intra.42.fr/oauth/token";

  // Méthode pour rediriger l'utilisateur vers la page de connexion 42
  Future<void> login() async {
    final clientId = dotenv.env['CLIENT_ID'];
    final redirectUri = dotenv.env['REDIRECT_URI']; // Met une URI valide

    final url = '$_authUrl?client_id=$clientId&redirect_uri=$redirectUri&response_type=code';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception("Impossible d'ouvrir l'URL d'authentification");
    }
  }

  // Récupération du token après redirection
  Future<void> exchangeCodeForToken(String authorizationCode) async {
    final clientId = dotenv.env['CLIENT_ID'];
    final clientSecret = dotenv.env['CLIENT_SECRET'];
    final redirectUri = dotenv.env['REDIRECT_URI'];

    final response = await http.post(
      Uri.parse(_tokenUrl),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'client_id': clientId,
        'client_secret': clientSecret,
        'code': authorizationCode,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _expiresAt = DateTime.now().add(Duration(seconds: data['expires_in']));
      notifyListeners();
    } else {
      throw Exception("Échec de l'authentification avec 42");
    }
  }
}
