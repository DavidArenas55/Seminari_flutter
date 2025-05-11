import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  bool isLoggedIn = false; // Variable para almacenar el estado de autenticación

  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api/users';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:9000/api/users';
    } else {
      return 'http://localhost:9000/api/users';
    }
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    final body = json.encode({'email': email, 'password': password});

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Login response: $data'); // 👈 Debug

        final userId = data['id'];
        if (userId != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId); // Guarda solo el ID del usuario
          return {'id': userId};
        } else {
          return {'error': 'Resposta sense ID d\'usuari'};
        }
      } else {
        return {'error': 'email o contrasenya incorrectes'};
      }
    } catch (e) {
      return {'error': 'Error de connexió'};
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) return null;

    final response = await http.get(
      Uri.parse('$_baseUrl/$userId'), // ✅ Corregido
      headers: {
        // Puedes quitar este header si no usas token
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> logout() async {
    print("🔥 SE LLAMÓ A LOGOUT 🔥");
    isLoggedIn = false;
    print("Sessió tancada");

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // ✅ Corregido
  }

  Future<bool> updateUserProfile(String name, String email) async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId == null) return false;

  final url = Uri.parse('$_baseUrl/$userId');
  final body = json.encode({'name': name, 'email': email});

  final response = await http.put(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  return response.statusCode == 200;
  }

}