import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ApiService {
  // Base URL for your Laravel backend
  static String baseUrl = '${dotenv.env['APP_HOST']}/api';

  //User Login as Patient
  Future<void> loginAsUser(
      String userEmail, String userPassword, BuildContext context) async {
    final storage = FlutterSecureStorage();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/LoginUser'),
        headers: {
          'Content-Type':
              'application/json', // Fixed: removed space in Content-Type
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({'email': userEmail, 'password': userPassword}),
      );

      final responseData = json.decode(response.body);
      final message = responseData['message'];
      final data = responseData['data'];

      switch (response.statusCode) {
        case 200:
          try {
            await storage.write(
              key: 'token',
              value: data['token'], // Fixed: added ['token'] to access token
            );

            Navigator.pushReplacementNamed(context, '/home');
          } catch (e) {
            throw FormatException('Wrong format ${e.toString()}');
          }
          break;
        case 400:
          throw BadRequestException(
            message?.toString() ?? 'Invalid request',
          );
        case 401:
          throw UnauthorizedException(
            message?.toString() ?? 'Unauthorized!',
          );
        case 500:
          throw ServerException(
            message?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the exception to be handled by the calling function
      if (e is BadRequestException ||
          e is UnauthorizedException ||
          e is ServerException ||
          e is FormatException) {
        rethrow;
      }
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  //User Login as Doctor
  Future<void> loginAsDoctor(
      String userEmail, String userPassword, BuildContext context) async {
    final storage = FlutterSecureStorage();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/LoginDoctor'),
        headers: {
          'Content-Type':
              'application/json', // Fixed: removed space in Content-Type
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({'email': userEmail, 'password': userPassword}),
      );

      final responseData = json.decode(response.body);
      final message = responseData['message'];
      final data = responseData['data'];

      switch (response.statusCode) {
        case 200:
          try {
            await storage.write(
              key: 'token',
              value: data['token'], // Fixed: added ['token'] to access token
            );

            Navigator.pushReplacementNamed(
                context, '/dhome'); // Fixed: separate route for doctor
          } catch (e) {
            throw FormatException('Wrong format ${e.toString()}');
          }
          break;
        case 400:
          throw BadRequestException(
            message?.toString() ?? 'Invalid request',
          );
        case 401:
          throw UnauthorizedException(
            message?.toString() ?? 'Unauthorized!',
          );
        case 500:
          throw ServerException(
            message?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the exception to be handled by the calling function
      if (e is BadRequestException ||
          e is UnauthorizedException ||
          e is ServerException ||
          e is FormatException) {
        rethrow;
      }
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  //Register User
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/RegisterUser'), // Fixed: changed from RegisterDoctor to RegisterUser
        headers: {
          'Content-Type':
              'application/json', // Fixed: removed space in Content-Type
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'UserEmail': email,
          'UserPassword': password,
          'UserName': name,
        }),
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201: // Added 201 for created status
          return responseData; // Fixed: return responseData instead of decoding again
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid data',
          );
        case 401:
          throw UnauthorizedException(
            responseData['message']?.toString() ?? 'Unauthorized',
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the exception to be handled by the calling function
      if (e is BadRequestException ||
          e is UnauthorizedException ||
          e is ServerException) {
        rethrow;
      }
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  //Register Doctor
  Future<Map<String, dynamic>> registerDoctor({
    required String name,
    required String email,
    required String password,
    String? doctorImage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/RegisterDoctor'),
        headers: {
          'Content-Type':
              'application/json', // Fixed: removed space in Content-Type
          'Access-Control-Allow-Origin': '*',
        },
        body: jsonEncode({
          'UserEmail': email,
          'UserPassword': password,
          'UserName': name,
          'DoctorPict': doctorImage ?? '',
        }),
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
        case 201: // Added 201 for created status
          return responseData; // Fixed: return responseData instead of decoding again
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid data',
          );
        case 401:
          throw UnauthorizedException(
            responseData['message']?.toString() ?? 'Unauthorized',
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw the exception to be handled by the calling function
      if (e is BadRequestException ||
          e is UnauthorizedException ||
          e is ServerException) {
        rethrow;
      }
      throw Exception('Failed to register: ${e.toString()}');
    }
  }

  // Logout User
  Future<void> logout(String userId, BuildContext context) async {
    final storage = FlutterSecureStorage();

    try {
      // Get the stored token for authentication
      String? token = await storage.read(key: 'token');
      
      if (token == null) {
        throw UnauthorizedException('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Access-Control-Allow-Origin': '*',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          // Remove token from storage
          await storage.delete(key: 'token');
          
          // Navigate to login page
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/login', 
            (route) => false,
          );
          break;
        case 401:
          // Token might be expired, still remove it from storage
          await storage.delete(key: 'token');
          throw UnauthorizedException(
            responseData['message']?.toString() ?? 'Session expired',
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      // Always remove token from storage on logout attempt
      await storage.delete(key: 'token');
      
      // Re-throw the exception to be handled by the calling function
      if (e is UnauthorizedException || e is ServerException) {
        rethrow;
      }
      throw Exception('Failed to logout: ${e.toString()}');
    }
  }

  //  ------------------------ Profile -------------------------------------------

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
