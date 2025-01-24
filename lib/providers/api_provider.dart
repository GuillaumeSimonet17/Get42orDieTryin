import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_provider.dart';

class ApiProvider with ChangeNotifier {
  final AuthProvider _authProvider;
  bool _isLoading = false;
  String? _error;

  ApiProvider() : _authProvider = AuthProvider();

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCursus() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final token = await _authProvider.getValidToken();
      final response = await http.get(
        Uri.parse('https://api.intra.42.fr/v2/cursus'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
      } else {
        throw Exception('Failed to load cursus');
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  //
  // Future<List<User>> fetchUsersForCursus(int cursusId) async {
  //   final token = await _authProvider.getValidToken();
  //   final response = await http.get(
  //     Uri.parse('https://api.intra.42.fr/v2/cursus/$cursusId/users'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => User.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load users');
  //   }
  // }
  //
  // Future<List<Project>> fetchProjectsForCursus(int cursusId) async {
  //   final token = await _authProvider.getValidToken();
  //   final response = await http.get(
  //     Uri.parse('https://api.intra.42.fr/v2/cursus/$cursusId/projects'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = json.decode(response.body);
  //     return data.map((json) => Project.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load projects');
  //   }
  // }
}