import 'package:api_42_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_radar_chart/flutter_radar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProtectedPage extends StatefulWidget {
  final String accessToken;

  const ProtectedPage({Key? key, required this.accessToken}) : super(key: key);

  @override
  _ProtectedPageState createState() => _ProtectedPageState();
}

class _ProtectedPageState extends State<ProtectedPage> {
  int currentPage = 1;
  String username = '';
  late Future<Map<String, dynamic>> userDataFuture;

  @override
  void initState() {
    super.initState();
    userDataFuture = fetchUserData();
  }

  Future logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<Map<String, dynamic>> fetchUserData() async {
    try {
      final userResponse = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/me'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      if (userResponse.statusCode == 200) {
        final data = json.decode(userResponse.body);
        setState(() {
          username = data['login'] ?? 'Inconnu';
        });
        return data;
      } else {
        throw Exception("Failed to load user data: ${userResponse.statusCode}");
      }
    } catch (e) {
      // await logout();
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAllUsersData(int page) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.intra.42.fr/v2/cursus_users?filter[campus_id]=9&sort=-level&page[size]=9&page[number]=$page'),
        headers: {'Authorization': 'Bearer ${widget.accessToken}'},
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .where((user) =>
                user is Map<String, dynamic> &&
                user['user'] is Map<String, dynamic>)
            .map((user) => user as Map<String, dynamic>)
            .toList();
      } else {
        throw Exception("Failed to load user data: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Get 42 or Die Tryin\''), // Titre à gauche
              Row(
                children: [
                  Text(username,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  // Remplace par la variable du nom de l'utilisateur
                  SizedBox(width: 10),
                  // Espace entre le nom et le bouton
                  IconButton(
                    icon: Icon(Icons.logout, color: Colors.blue.shade900),
                    onPressed: logout,
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: Colors.white,
          bottom: TabBar(
            indicatorColor: Colors.blue.shade900,
            labelColor: Colors.blue.shade900,
            unselectedLabelColor: Colors.blue.shade600,
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Profil"),
              Tab(icon: Icon(Icons.check), text: "Ranking"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: FutureBuilder<Map<String, dynamic>>(
                future: userDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Affiche un loader pendant le chargement
                  } else if (snapshot.hasError) {
                    return Text('Unknown user');
                  } else if (snapshot.hasData) {
                    final user = snapshot.data!; // Les données utilisateur
                    List<dynamic> cursus = user['cursus_users'];
                    List<dynamic> projects = user['projects_users'];

                    List<dynamic> skillsData =
                        cursus.isNotEmpty && cursus[1] != null
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
                      child: Container(
                        width: 700,
                        margin: EdgeInsets.only(top: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
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
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${user['email']}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Login: $username',
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
                          SizedBox(
                            height: 300,
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: RadarChart(
                                ticks: [5, 10, 15],
                                features: skillNames,
                                data: [skillLevels],
                                sides: skillNames.length,
                                outlineColor: Colors.blue.shade900,
                                graphColors: [Colors.blue.shade900],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            '📌 Projets :',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              width: 1000,
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
                                        child: Container(
                                      height: 180,
                                      color: Colors.black12,
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(height: 5),
                                            Text(
                                              project['project']['name'],
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              '${project['status']}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              'Validé: ${project['validated?'] == true ? "Oui" : "Non"}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: project['validated?'] ==
                                                        true
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
                  } else {
                    return Text("Aucune donnée disponible");
                  }
                },
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchAllUsersData(currentPage),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      } else if (snapshot.hasData) {
                        var data = snapshot.data!;

                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: data.map((userData) {
                              var user = userData['user'];
                              var level = userData['level'];

                              return Container(
                                  width: 700,
                                  child: Card(
                                    color: Colors.white,
                                    margin: EdgeInsets.all(8),
                                    elevation: 5,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          ClipOval(
                                            child: Image.network(
                                              user['image']['link'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user['login'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text('Level: ${level}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ));
                            }).toList(),
                          ),
                        );
                      } else {
                        return Center(child: Text('Aucune donnée disponible'));
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 700,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: currentPage > 1
                              ? () {
                                  setState(() {
                                    currentPage--;
                                  });
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            // Fond blanc
                            foregroundColor: Colors.black,
                            // Texte noir
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            // Ajuste la taille du bouton
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Coins arrondis
                            ),
                          ),
                          child: Text("Précédent"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              currentPage++;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            // Fond blanc
                            foregroundColor: Colors.black,
                            // Texte noir
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            // Ajuste la taille du bouton
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10), // Coins arrondis
                            ),
                          ),
                          child: Text("Suivant"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
