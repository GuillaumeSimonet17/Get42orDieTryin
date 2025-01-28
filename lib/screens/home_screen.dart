import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uni_links/uni_links.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'protected_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    _checkForStoredToken();
  }

  void _checkForStoredToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedToken = prefs.getString('access_token');

    if (storedToken != null) {
      setState(() {
        _accessToken = storedToken;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProtectedPage(accessToken: _accessToken!),
        ),
      );
    }
  }

  void _handleIncomingLinks() async {
    Uri? initialUri = await getInitialUri();

    if (initialUri != null &&
        initialUri.scheme == "http" &&
        initialUri.queryParameters.containsKey("code")) {
      String? authCode = initialUri.queryParameters["code"];

      if (authCode != null && _accessToken == null) {
        await _exchangeCodeForToken(authCode);
      }
    }

    uriLinkStream.listen((Uri? uri) async {
      if (uri != null && uri.queryParameters.containsKey("code")) {
        String? authCode = uri.queryParameters["code"];
        if (authCode != null && _accessToken == null) {
          await _exchangeCodeForToken(authCode);
        }
      }
    }, onError: (err) {
      print("Erreur lors de l'écoute des deep links : $err");
    });
  }

  Future<void> _exchangeCodeForToken(String authCode) async {
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          _accessToken = data['access_token'];
        });

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _accessToken!);

        // Naviguer vers la page protégée après avoir obtenu le token
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProtectedPage(accessToken: _accessToken!),
          ),
        );
      } else {
        print("Erreur lors de l'échange du code: ${response.body}");
      }
    } catch (e) {
      print("Erreur catch lors de l'échange du code: ${e}");
    }
  }

  Future<void> _launchAuthUrl() async {
    final String authUrl = "https://api.intra.42.fr/oauth/authorize?"
        "client_id=${dotenv.env['CLIENT_ID']}"
        "&redirect_uri=${Uri.encodeComponent(dotenv.env['REDIRECT_URI']!)}"
        "&response_type=code";

    Uri url = Uri.parse(authUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Impossible d'ouvrir l'URL : $authUrl";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  SvgPicture.asset(
                    'assets/42_Logo.svg',
                    height: 200,
                    color: Colors.white,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _launchAuthUrl,
                    child: Text("Se connecter avec 42"),
                  ),
                ]))));
  }
}
