import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProtectedPage extends StatelessWidget {
  final String accessToken;

  const ProtectedPage({Key? key, required this.accessToken}) : super(key: key);

  // Fonction pour récupérer les données de l'utilisateur
  Future<Map<String, dynamic>> fetchUserData() async {
    final userResponse = await http.get(
      Uri.parse('https://api.intra.42.fr/v2/me'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (userResponse.statusCode == 200) {
      final userData = json.decode(userResponse.body);
      return userData;
    } else {
      throw Exception("Failed to load user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Page Protégée")),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserData(), // On appelle la fonction pour récupérer les données
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Affiche un loader pendant le chargement
            } else if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else if (snapshot.hasData) {
              final user = snapshot.data!; // Les données utilisateur
              print(user);
              print(user['cursus']);
              List<dynamic> cursus = user['cursus_users'];
              List<dynamic> projects = user['projects_users'];

              return SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user['image']['link']), // Affiche l'image de l'utilisateur
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Nom: ${user['first_name']} ${user['last_name']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Email: ${user['email']}',
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
                        '📌 Projets :',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Wrap(
                          spacing: 10, // Espacement horizontal entre les cartes
                          runSpacing: 10, // Espacement vertical si besoin de passer à la ligne
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
                                        style: TextStyle(fontWeight: FontWeight.bold),
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
                                          color: project['validated?'] == true ? Colors.green : Colors.red,
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
