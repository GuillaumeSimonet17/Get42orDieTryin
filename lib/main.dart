import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart'; // Import provider here
import 'screens/home_screen.dart';
import 'screens/protected_page.dart';
import 'providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  runApp(
    MyApp(accessToken: accessToken),
  );
}

class MyApp extends StatelessWidget {
  final String? accessToken;

  const MyApp({Key? key, this.accessToken}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        // scaffoldBackgroundColor: Color(0xFF003366),
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: Colors.blue.shade50),
          titleLarge: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue.shade50),
        ),
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0X003366),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Colors.blue.shade50, // Couleur de la bordure
                width: 2, // Largeur de la bordure
              ),
            ),
          ),
        ),
      ),
      home: accessToken != null
          ? ProtectedPage(accessToken: accessToken!)
          : HomePage(),
    );
  }
}
