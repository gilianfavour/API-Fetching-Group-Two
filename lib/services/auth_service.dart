import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://testing.rasmuspharmaceuticals.com/api/v1';

  // =========================================
  // REGISTER USER
  // =========================================
  Future<Map<String, dynamic>> register({
    required String name,
    required String emailOrContact,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final Map<String, dynamic> body = {
      'name': name,
      'password': password,
    };

    if (emailOrContact.contains('@')) {
      body['email'] = emailOrContact;
    } else {
      body['contact'] = emailOrContact;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Registration failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during registration: $e');
    }
  }

  // =========================================
  // LOGIN USER
  // =========================================
  Future<Map<String, dynamic>> login({
    required String emailOrContact,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');

    final Map<String, dynamic> body = {
      'password': password,
    };

    if (emailOrContact.contains('@')) {
      body['email'] = emailOrContact;
    } else {
      body['contact'] = emailOrContact;
    }

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Invalid credentials';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during login: $e');
    }
  }
}
