import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProfilesList extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const ProfilesList({Key? key, required this.data}) : super(key: key);

  @override
  _ProfilesListState createState() => _ProfilesListState();
}

class _ProfilesListState extends State<ProfilesList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.data.map((userData) {
          var user = userData['user'];
          var level = userData['level'];

          return ProfileCard(user: user, level: level);
        }).toList(),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  final user;
  final level;

  const ProfileCard({
    Key? key,
    required this.user,
    required this.level,
  }) : super(key: key);

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 700,
        child: Card(
          margin: EdgeInsets.all(8),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12), // Arrondi les coins de la Card
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              // Assure l'arrondi du dégradé
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                // Dégradé horizontal (de gauche à droite)
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
                    widget.user['image']['link'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user['login'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Level: ${widget.level}'),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
