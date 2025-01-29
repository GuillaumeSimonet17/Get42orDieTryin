import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class UserInfos extends StatefulWidget {
  final String username;
  final Map<String, dynamic> user;
  final List<dynamic> cursus;
  final String image;

  const UserInfos({
    Key? key,
    required this.user,
    required this.username,
    required this.cursus,
    required this.image
  }) : super(key: key);


  @override
  _UserInfosState createState() => _UserInfosState();
}

class _UserInfosState extends State<UserInfos> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(widget.image),
          ),
          SizedBox(width: 40),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.user['first_name']} ${widget.user['last_name']}',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Login: ${widget.username}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Wallet: ${widget.user['wallet']}',
                style: TextStyle(fontSize: 16),
              ),
              Text(
                'Level: ${widget.cursus[1]['level']}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

}