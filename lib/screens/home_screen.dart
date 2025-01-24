import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'protected_page.dart'; // Importer la page protégée

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() async {
    // Vérifier si l'application a été lancée avec un deep link
    Uri? initialUri = await getInitialUri();
    print('Initial URI: $initialUri');  // Imprime l'URI initiale reçue
    print('Initial URI: ${initialUri?.scheme}');  // Imprime l'URI initiale reçue

    if (initialUri != null && initialUri.scheme == "http" &&
        initialUri.queryParameters.containsKey("code")) {
      String? authCode = initialUri.queryParameters["code"];
      print('Code OAuth initial reçu: $authCode');  // Affiche le code OAuth

      if (authCode != null && _accessToken == null) {
        print("App lancée avec code OAuth : $authCode");
        await _exchangeCodeForToken(authCode);
      }
    }

    // Écoute des deep links en temps réel
    uriLinkStream.listen((Uri? uri) async {
      print('Deep link reçu : $uri');  // Affiche l'URI du deep link en temps réel

      if (uri != null && uri.queryParameters.containsKey("code")) {
        String? authCode = uri.queryParameters["code"];
        if (authCode != null && _accessToken == null) {
          print("Deep link détecté avec code : $authCode");
          await _exchangeCodeForToken(authCode);
        }
      }
    }, onError: (err) {
      print("Erreur lors de l'écoute des deep links : $err");
    });
  }

  Future<void> _exchangeCodeForToken(String authCode) async {
    print('coucou1 _exchangeCodeForToken');
    final String clientId = dotenv.env['CLIENT_ID']!;
    final String clientSecret = dotenv.env['CLIENT_SECRET']!;
    final String redirectUri = dotenv.env['REDIRECT_URI']!;
    final String tokenUrl = "https://api.intra.42.fr/oauth/token";

    try {

      final response = await http.post(
        Uri.parse(tokenUrl),
        body: {
          'grant_type': 'authorization_code',
          'client_id': clientId,
          'client_secret': clientSecret,
          'code': authCode,
          'redirect_uri': redirectUri,
        },
      );
      print('coucou222 200');

      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> data = json.decode(response.body);
        print('suuuuu1 = $data');

        setState(() {
          _accessToken = data['access_token'];
        });

        final userResponse = await http.get(
          Uri.parse('https://api.intra.42.fr/v2/me'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );

        final userData = json.decode(userResponse.body);
        print(userData);

        // Naviguer vers la page protégée
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProtectedPage(accessToken: _accessToken!),
          ),
        );

      } else {
        print("Erreur lors de l'échange du code: ${response.body}");
      }
    } catch(e) {
      print("Erreur catch lors de l'échange du code: ${e}");
    }

  }

  Future<void> _launchAuthUrl() async {
    print('coucou1 _launchAuthUrl');

    final String authUrl = "https://api.intra.42.fr/oauth/authorize?"
        "client_id=${dotenv.env['CLIENT_ID']}"
        "&redirect_uri=${Uri.encodeComponent(dotenv.env['REDIRECT_URI']!)}"
        "&response_type=code";

    Uri url = Uri.parse(authUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      print('yo');
    } else {
      throw "Impossible d'ouvrir l'URL : $authUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login 42")),
      body: Center(
        child: ElevatedButton(
          onPressed: _launchAuthUrl,
          child: Text("Se connecter avec 42"),
        ),
      ),
    );
  }
}
