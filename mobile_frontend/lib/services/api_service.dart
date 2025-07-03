import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile_frontend/views/users/home.dart';
import 'package:mobile_frontend/views/doctor/d_home.dart';
import 'dart:convert';

class ApiService {
  // Base URL for your Laravel backend
  static String baseUrl = '${dotenv.env['BASE_URL']}/api';

  Future<void> loginAsUser(
    String userEmail,
    String userPassword,
    BuildContext context,
  ) async {
    final storage = FlutterSecureStorage();
    final uri = Uri.parse('$baseUrl/LoginUser');

    debugPrint('Base URL: $baseUrl');
    debugPrint('API Endpoint: $uri');

    final body = jsonEncode({
      'UserEmail': userEmail,
      'UserPassword': userPassword,
    });

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
        },
        body: body,
      );

      debugPrint("Request Body: $body");
      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final responseData = json.decode(response.body);

      // Handle success case (status code 200)
      if (response.statusCode == 200) {
        // Check for token in different possible locations
        final token = responseData['token'] ?? responseData['data']?['token'];
        final int userId = responseData['data']?['UserID'];
        const role = "user";

        if (token == null) {
          throw FormatException('Token not found in response');
        }

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'userId', value: userId.toString());
        await storage.write(key: 'role', value: role);

        // Navigate to home with proper user data
        debugPrint('Navigating to home with userData: ${responseData['data']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(userData: responseData['data']),
          ),
        );
      }
      // Handle error cases
      else {
        final errorMessage =
            responseData['error'] ?? responseData['message'] ?? 'Login failed';

        switch (response.statusCode) {
          case 400:
            throw BadRequestException(errorMessage);
          case 401:
            throw UnauthorizedException(errorMessage);
          case 402: // Handle the 402 case we saw in the logs
            throw UnauthorizedException(errorMessage);
          case 500:
            throw ServerException(errorMessage);
          default:
            throw Exception('Unexpected status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  //User Login as Doctor
  Future<void> loginAsDoctor(
    String userEmail,
    String userPassword,
    BuildContext context,
  ) async {
    final storage = FlutterSecureStorage();
    final uri = Uri.parse('$baseUrl/LoginDoctor');

    debugPrint('API Endpoint: $uri');
    final body = jsonEncode({
      'UserEmail': userEmail.trim(),
      'UserPassword': userPassword,
    });
    debugPrint("Request Body: $body");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      if (response.body.isEmpty) throw Exception('Empty response from server');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = responseData['token'] ?? responseData['data']?['token'];
        final int userId = responseData['data']?['UserID'];
        const role = "doctor";

        if (token == null) throw FormatException('Token not found');

        await storage.write(key: 'token', value: token);
        await storage.write(key: 'userId', value: userId.toString());
        await storage.write(key: 'role', value: role);

        // Navigate to doctor home with proper user data
        debugPrint('Navigating to doctor home with userData: ${responseData['data']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DHomeScreen(userData: responseData['data']),
          ),
        );
      } else {
        final error = responseData['error'] ??
            responseData['message'] ??
            'Login failed (${response.statusCode})';

        if (response.statusCode == 401 || response.statusCode == 402) {
          throw UnauthorizedException(error);
        } else {
          throw Exception(error);
        }
      }
    } catch (e) {
      debugPrint('Doctor login error: $e');
      rethrow;
    }
  }

  //Register User
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/RegisterUser');
    debugPrint('API Endpoint: $uri');

    final body = jsonEncode({
      'UserName': name.trim(),
      'UserEmail': email.trim(),
      'UserPassword': password,
    });
    debugPrint("Request Body: $body");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final error = responseData['error'] ??
            responseData['message'] ??
            'Registration failed (${response.statusCode})';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('User registration error: $e');
      rethrow;
    }
  }

  //Register Doctor
  Future<Map<String, dynamic>> registerDoctor({
    required String name,
    required String email,
    required String password,
    String? doctorImage,
  }) async {
    final uri = Uri.parse('$baseUrl/RegisterDoctor');
    debugPrint('API Endpoint: $uri');

    final body = jsonEncode({
      'UserName': name.trim(),
      'UserEmail': email.trim(),
      'UserPassword': password,
      'DoctorPict': doctorImage ?? '',
    });
    debugPrint("Request Body: $body");

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        final error = responseData['error'] ??
            responseData['message'] ??
            'Registration failed (${response.statusCode})';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Doctor registration error: $e');
      rethrow;
    }
  }

  // Logout User
  Future<void> logout(BuildContext context) async {
    final storage = FlutterSecureStorage();

    try {
      final token = await storage.read(key: 'token');
      final userId = await storage.read(key: 'userId');

      final uri = Uri.parse('$baseUrl/logout/$userId');
      debugPrint('API Endpoint: $uri');

      if (token == null) throw UnauthorizedException('No token found');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      // Always delete token regardless of response
      await storage.delete(key: 'token');
      await storage.delete(key: 'userId');
      await storage.delete(key: 'role');

      if (response.statusCode == 200) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
        debugPrint('login success');
      } else {
        final responseData = json.decode(response.body);
        final error = responseData['error'] ??
            responseData['message'] ??
            'Logout failed (${response.statusCode})';
        throw Exception(error);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }
  //  ------------------------ Profile -------------------------------------------

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    final storage = FlutterSecureStorage();
    
    try {
      // Get stored authentication token
      final token = await storage.read(key: 'token');
      if (token == null) {
        return {
          'status': 401,
          'error': 'No authentication token found',
        };
      }

      final url = Uri.parse('$baseUrl/DeleteUser/$userId/user');
      print('Delete user URL: $url'); // Debug print

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
    final storage = FlutterSecureStorage();
    
    try {
      // Get stored authentication token
      final token = await storage.read(key: 'token');
      if (token == null) {
        return {
          'status': 401,
          'error': 'No authentication token found',
        };
      }

      final url = Uri.parse('$baseUrl/EditUser/$userId/user');
      print('Edit user URL: $url'); // Debug print
      print('Edit user token: ${token.substring(0, 10)}...'); // Debug print (partial token)

      // Try form data format instead of JSON
      final body = <String, String>{
        'UserName': name,
        'UserEmail': email,
      };

      if (password != null) {
        body['UserPassword'] = password;
      }

      print('Edit user request body: $body'); // Debug print

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
      
      print('Edit user headers: $headers'); // Debug print

      final response = await http.post(
        url,
        headers: headers,
        body: body, // Send as form data instead of JSON
      );

      print('Edit user response status: ${response.statusCode}');
      print('Edit user response body: ${response.body}');

      return json.decode(response.body);
    } catch (e) {
      return {
        'status': 500,
        'error': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> getUserData(int userId) async {
    final storage = FlutterSecureStorage();
    
    try {
      // Get stored authentication token
      final token = await storage.read(key: 'token');
      if (token == null) {
        return {
          'status': 401,
          'error': 'No authentication token found',
        };
      }

      final url = Uri.parse('$baseUrl/GetUserData/$userId/user');
      print('Requesting URL: $url'); // Debug print
      print('Using token: ${token.substring(0, 10)}...'); // Debug print (partial token)

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
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

// Custom Exceptions
class FetchDataException implements Exception {
  final String message;
  FetchDataException(this.message);
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}
