import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

//evelyn@gmail.com
//Evelyn2000
class AuthProvider with ChangeNotifier {
  final String baseUrl = 'https://aldeacristorey.com/api/auth';
  //final String baseUrl = 'https://aldeacristoreyocr.netlify.app/api/auth';
  Map<String, String>? currentUser;
  bool expiredToken = false;
  List<dynamic> users = [];
  int totalItems = 0;
  int perPage = 5;
  String? token;
  int currentPage = 1;

  AuthProvider() {
    init();
  }

  Future<void> init() async {
    await getToken();
    await getCurrentUser();
  }

  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (kDebugMode) {
      print('Token retrieved: $token');
    }
    if (token == null) {
      expiredToken = true;
      logout();
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{'Content-Type': 'application/json'},
        body:
            json.encode(<String, String>{'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['access_token']);
        token = data['access_token'];
        if (kDebugMode) {
          print('Token saved: $token');
        }
        await getCurrentUser();
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        await logout();
        notifyListeners();
        return false;
      }
      notifyListeners();
      return false;
    } catch (error) {
      if (kDebugMode) {
        print('Exception: $error');
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (kDebugMode) {
          print('Logout response status: ${response.statusCode}');
        }
      } catch (error) {
        if (kDebugMode) {
          print('Exception: $error');
        }
      }
    }

    await prefs.remove('token');
    token = null;
    currentUser = null;
    expiredToken = true;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token');
  }

  Future<String?> getLoginToken() async {
    if (await isLoggedIn()) {
      token = token;
      return token;
    }
    return null;
  }

  Future<void> getCurrentUser() async {
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      if (kDebugMode) {
        print('getCurrentUser token: $token');
      }
    }

    if (token == null) {
      expiredToken = true;
      notifyListeners();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getCurrentUser'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          currentUser =
              data.map((key, value) => MapEntry(key, value.toString()));
          expiredToken = false;
        } else {
          throw Exception('Unexpected response format');
        }
      } else if (response.statusCode == 401) {
        expiredToken = true;
        await logout();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception: $error');
      }
      await logout();
    }
    notifyListeners();
  } //!=

  Future<bool> registerUser(Map<String, String> userData) async {
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    if (token == null) {
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        return true; // Registro exitoso
      } else {
        print(
            'Error: ${response.statusCode} - ${response.body}'); // Imprime el error
        return false; // Registro fallido
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception: $error');
      }

      return false;
    }
  }

  Future<void> getAllUsers() async {
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
      if (kDebugMode) {
        print('getAllUsers token: $token');
      }
    }

    if (token == null) {
      expiredToken = true;
      notifyListeners();
      return;
    }

    try {
      final uri = Uri.parse('$baseUrl/getAll').replace();
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        expiredToken = false;
        var jsonResponse = json.decode(response.body);
        users = jsonResponse['items'];
      } else if (response.statusCode == 401) {
        expiredToken = true;
        await logout();
      }
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Exception: $error');
      }
    }
  }

  void handleTokenExpiration() {
    expiredToken = true;
    notifyListeners();
  }

  Future<bool> updateUser(int id, Map<String, String> userData) async {
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/updateUser/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(userData),
      );

      return response.statusCode == 200;
    } catch (error) {
      if (kDebugMode) {
        print('Exception: $error');
      }

      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    if (token == null) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('token');
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/deleteUser/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Exception: $error');
      }
      return false;
    }
  }
}
