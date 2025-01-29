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
      await logout();
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
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.white,
          // Change la couleur ici
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Get 42 or Die Tryin\'',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  )),
              Row(
                children: [
                  Text(username,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary)),
                  // Remplace par la variable du nom de l'utilisateur
                  SizedBox(width: 10),
                  // Espace entre le nom et le bouton
                  IconButton(
                    icon: Icon(Icons.logout,
                        color: Theme.of(context).colorScheme.primary),
                    onPressed: logout,
                  ),
                ],
              ),
            ],
          ),
          bottom: TabBar(
            indicatorColor: Theme.of(context).colorScheme.primary,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.secondary,
            tabs: [
              Tab(icon: Icon(Icons.person), text: "Profil"),
              Tab(icon: Icon(Icons.check), text: "Ranking (Lyon)"),
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
                        image: DecorationImage(
                          image: AssetImage('assets/background.png'),
                          fit: BoxFit.cover,
                        ),
                        // color: Color(0xFF003366),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundImage: NetworkImage(user['image'][
                                      'link']), // Affiche l'image de l'utilisateur
                                ),
                                SizedBox(width: 40),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${user['first_name']} ${user['last_name']}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    // Text(
                                    //   '${user['email']}',
                                    //   style: TextStyle(fontSize: 16),
                                    // ),
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 70),
                          Container(
                            height: 250,
                            margin: EdgeInsets.symmetric(horizontal: 50),
                            // Padding à gauche et à droite
                            padding: EdgeInsets.symmetric(vertical: 20),
                            // Padding à gauche et à droite
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(50), // Bords arrondis
                            ),
                            child: SizedBox(
                              height: 200,
                              child: RadarChart(
                                ticks: [5, 10, 15],
                                features: skillNames,
                                data: [skillLevels],
                                sides: skillNames.length,
                                outlineColor: Color(0xFF4B70AF),
                                graphColors: [
                                  Color(0xFF4B70AF),
                                ],
                                featuresTextStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 70),
                          Text(
                            '📌 Projets :',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          SizedBox(height: 20),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Expanded(
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
                                        color: Color(0xFF455D87),
                                        child: Container(
                                          height: 150,
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
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${project['status']}',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white),
                                                ),
                                                Text(
                                                  'Validé: ${project['validated?'] == true ? "Oui" : "Non"}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                        project['validated?'] ==
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
                          padding: EdgeInsets.only(top: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: data.map((userData) {
                              var user = userData['user'];
                              var level = userData['level'];

                              return Container(
                                  width: 700,
                                  child: Card(
                                    margin: EdgeInsets.all(8),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // Arrondi les coins de la Card
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12), // Assure l'arrondi du dégradé
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft, // Dégradé horizontal (de gauche à droite)
                                          end: Alignment.centerRight,
                                          colors: [
                                            Theme.of(context).colorScheme.primary,
                                            Theme.of(context).colorScheme.secondary,
                                          ],
                                        ),
                                      ),
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
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
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
                            foregroundColor: Color(0xFF003366),
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
