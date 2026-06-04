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
    required String passwordConfirmation,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');

    final Map<String, dynamic> body = {
      'name': name,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    if (emailOrContact.contains('@')) {
      body['email'] = emailOrContact;
    } else {
      body['contact'] = emailOrContact;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map) {
            final errors = responseData['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstVal = errors.values.first;
              if (firstVal is List && firstVal.isNotEmpty) {
                throw Exception(firstVal.first);
              } else {
                throw Exception(firstVal.toString());
              }
            }
          }
          final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Registration failed';
          throw Exception(errorMsg);
        } catch (e) {
          if (e is Exception && !e.toString().contains('FormatException') && !e.toString().contains('TypeError')) {
            rethrow;
          }
          throw Exception('Registration failed (Status: ${response.statusCode}). Response: ${response.body}');
        }
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData is Map) {
            final errors = responseData['errors'];
            if (errors is Map && errors.isNotEmpty) {
              final firstVal = errors.values.first;
              if (firstVal is List && firstVal.isNotEmpty) {
                throw Exception(firstVal.first);
              } else {
                throw Exception(firstVal.toString());
              }
            }
          }
          final errorMsg = responseData['message'] ?? responseData['error'] ?? 'Invalid credentials';
          throw Exception(errorMsg);
        } catch (e) {
          if (e is Exception && !e.toString().contains('FormatException') && !e.toString().contains('TypeError')) {
            rethrow;
          }
          throw Exception('Login failed (Status: ${response.statusCode}). Response: ${response.body}');
        }
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error during login: $e');
    }
  }
}
