import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ProjectsList extends StatefulWidget {
  final List<dynamic> projects;

  const ProjectsList({
    Key? key,
    required this.projects,
  }) : super(key: key);

  @override
  _ProjectsListState createState() => _ProjectsListState();
}

class _ProjectsListState extends State<ProjectsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        '📌 Projets :',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
            children: widget.projects.map((project) {
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
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '${project['status']}',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
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
                    )),
              );
            }).toList(),
          ),
        ),
      )
    ]);
  }
}
