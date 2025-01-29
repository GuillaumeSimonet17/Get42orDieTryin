import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

Future<void> logout(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('access_token');

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => LoginScreen()),
  );
}
