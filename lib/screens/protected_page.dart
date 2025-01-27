import 'package:api_42_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProtectedPage extends StatelessWidget {
  final String accessToken;

  const ProtectedPage({Key? key, required this.accessToken}) : super(key: key);

  Future logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');  // Supprime le token

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<Map<String, dynamic>> fetchUserData(BuildContext context) async {
    try {
      final userResponse = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (userResponse.statusCode == 200) {
        return json.decode(userResponse.body);
      } else {
        throw Exception("Failed to load user data: ${userResponse.statusCode}");
      }
    } catch (e) {
      await logout(context);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Page Protégée"),
        backgroundColor: Colors.blue, // Couleur de la barre de navigation
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(context),
          // On appelle la fonction pour récupérer les données
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Affiche un loader pendant le chargement
            } else if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final user = snapshot.data!; // Les données utilisateur

              List<dynamic> cursus = user['cursus_users'];
              List<dynamic> projects = user['projects_users'];

              List<dynamic> skillsData = cursus.isNotEmpty && cursus[1] != null
                  ? cursus[1]['skills']
                  : [];

              List<String> skillNames = skillsData
                  .map((s) =>
                      '${s['name']}: ${(s['level'] as num).toStringAsFixed(2)}') // Utilisation de l'interpolation de chaîne
                  .toList();
              List<double> skillLevels = skillsData
                  .map((s) => (s['level'] as num).toDouble())
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(user['image']
                          ['link']), // Affiche l'image de l'utilisateur
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${user['first_name']} ${user['last_name']}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${user['email']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Login: ${user['login']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Wallet: ${user['wallet']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Level: ${cursus[1]['level']}',
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '📌 Compétences :',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    SizedBox(
                      height: 400,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: RadarChart(
                          ticks: [5, 10, 15],
                          features: skillNames,
                          data: [skillLevels],
                          sides: skillNames.length,
                          outlineColor: Colors.blue,
                          graphColors: [Colors.blue],
                        ),
                      ),
                    ),
                    Text(
                      '📌 Projets :',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Wrap(
                        spacing: 10,
                        // Espacement horizontal entre les cartes
                        runSpacing: 10,
                        // Espacement vertical si besoin de passer à la ligne
                        alignment: WrapAlignment.center,
                        children: projects.map((project) {
                          return Container(
                            width: 180, // Taille des cartes
                            child: Card(
                              elevation: 5,
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      project['project']['name'],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Status: ${project['status']}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      'Validé: ${project['validated?'] == true ? "Oui" : "Non"}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: project['validated?'] == true
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Text("Aucune donnée disponible");
            }
          },
        ),
      ),
    );
  }
}
