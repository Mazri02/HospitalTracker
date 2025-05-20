import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // Base URL for your Laravel backend
  static const String baseUrl = 'http://192.168.0.15:8000'; //tukar ip sendiri

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // User Authentication APIs
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/CheckUser').replace(
          queryParameters: {
            'UserEmail': email,
            'UserPassword': password,
          },
        ),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 500,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/RegisterUser').replace(
          queryParameters: {
            'UserName': name,
            'UserEmail': email,
            'UserPassword': password,
          },
        ),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 500,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/DeleteUser').replace(
          queryParameters: {
            'UserID': userId.toString(),
          },
        ),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 500,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> editUser({
    required int userId,
    required String name,
    required String email,
    String? password,
  }) async {
    try {
      final queryParams = {
        'UserID': userId.toString(),
        'UserName': name,
        'UserEmail': email,
      };

      if (password != null) {
        queryParams['UserPassword'] = password;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/EditUser').replace(
          queryParameters: queryParams,
        ),
      );

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 500,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUserData(int userId) async {
    try {
      final url = Uri.parse('$baseUrl/api/GetUserData').replace(
        queryParameters: {
          'UserID': userId.toString(),
        },
      );

      print('Requesting URL: $url'); // Debug print

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': response.statusCode,
          'error': 'Server error: ${response.body}',
        };
      }
    } catch (e) {
      print('Error in getUserData: $e');
      return {
        'status': 500,
        'error': 'Network error: $e',
      };
    }
  }
}
