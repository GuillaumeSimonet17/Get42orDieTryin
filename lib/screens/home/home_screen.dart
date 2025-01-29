import 'dropdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'user_infos_wisget.dart';
import 'radar_chart_widget.dart';
import 'projects_list_widget.dart';
import 'profile_widgets.dart';
import '../utils.dart';

class HomeScreen extends StatefulWidget {
  final String accessToken;

  const HomeScreen({Key? key, required this.accessToken}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPage = 1;
  String username = '';
  late Future<Map<String, dynamic>> userDataFuture;


  @override
  void initState() {
    super.initState();
    userDataFuture = fetchUserData();
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
      await logout(context);
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
                  )
              ),
              DropdownWidget(username:username)
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
                            '${s['name']}: ${(s['level'] as num).toStringAsFixed(2)}')
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
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 50),
                          UserInfos(
                              user: user,
                              username: username,
                              cursus: cursus,
                              image: user['image']['link']),
                          SizedBox(height: 70),
                          RadarChartExtend(
                              skillNames: skillNames, skillLevels: skillLevels),
                          SizedBox(height: 70),
                          ProjectsList(projects: projects),
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
                        List<Map<String, dynamic>> data = snapshot.data!;

                        return ProfilesList(data: data);
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
