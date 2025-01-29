import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProfilesList extends StatefulWidget {
  final List<Map<String, dynamic>> data;
  final int currentPage;

  const ProfilesList({
    Key? key,
    required this.data,
    required this.currentPage
  }) : super(key: key);

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
        children: widget.data
            .asMap()
            .map((index, userData) {
              return MapEntry(index, userData);
            })
            .entries
            .map((entry) {
              int idx = entry.key + ((widget.currentPage - 1) * 9);
              String index = idx.toString();
              var userData = entry.value;
              var user = userData['user'] ?? 'null';
              var level = userData['level'] ?? 'null';

              return ProfileCard(index: index, user: user, level: level);
            })
            .toList(),
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  final user;
  final level;
  final index;

  const ProfileCard({
    Key? key,
    required this.index,
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
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
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
                Text(widget.index),
                SizedBox(width: 12),
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
