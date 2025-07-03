import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_frontend/model/appointment_model.dart';
import 'package:mobile_frontend/model/hospital_model.dart';

class ApiClient {
  static String baseUrl = '${dotenv.env['BASE_URL']}/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    // Add any other headers like authorization if needed
    // 'Authorization': 'Bearer your_token',
  };

  final storage = FlutterSecureStorage();

  // GET USER DETAIL
  Future<Map<String, dynamic>> getUserData({
    required String userId,
    required String userType, // 'patient' or 'doctor'
    required BuildContext context,
  }) async {
    final storage = FlutterSecureStorage();
    final uri = Uri.parse('$baseUrl/GetUserData/$userId/$userType');

    debugPrint('API Endpoint: $uri');

    try {
      // 1. Get stored token
      final token = await storage.read(key: 'token');
      if (token == null)
        throw UnauthorizedException('No authentication token found');

      // 2. Make authenticated GET request
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Status code: ${response.statusCode}');
      debugPrint('Raw response: ${response.body}');

      if (response.body.isEmpty) {
        throw Exception('Empty response from server');
      }

      final responseData = json.decode(response.body);

      // 3. Handle response
      if (response.statusCode == 200) {
        // Validate required fields
        if (responseData['data'] == null) {
          throw FormatException('Missing "data" in response');
        }

        return responseData['data']; // Return user data object
      } else {
        final errorMessage = responseData['error'] ??
            responseData['message'] ??
            'Failed to fetch user data (${response.statusCode})';

        switch (response.statusCode) {
          case 401:
            throw UnauthorizedException(errorMessage);
          case 404:
            throw Exception('User not found');
          case 500:
            throw ServerException(errorMessage);
          default:
            throw Exception(errorMessage);
        }
      }
    } catch (e) {
      debugPrint('GetUserData error: $e');
      rethrow;
    }
  }

  // READ ALL HOSPITAL
  Future<List<Hospital>> readAllHospital() async {
    var authToken = await storage.read(key: 'token');
    debugPrint('Auth Token: $authToken');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/AllHospital'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 15));
      print('=== HOSPITAL API RESPONSE ===');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      final responseData = json.decode(response.body);

      // Debug: Print first hospital data if available
      if (responseData is List && responseData.isNotEmpty) {
        print('First hospital raw data: ${responseData[0]}');
      }
      print('=============================');
      switch (response.statusCode) {
        case 200:
          try {
            // Check if responseData is already a List
            if (responseData is! List) {
              debugPrint('Expected List but got ${responseData.runtimeType}');
              throw const FormatException('Expected array of hospitals');
            }

            if (responseData.isEmpty) {
              debugPrint('Hospital data is Empty');
              return [];
            }

            List<Hospital> hospitals = responseData.map((hospitalJson) {
              try {
                return Hospital.fromJson(hospitalJson);
              } catch (e) {
                debugPrint('Error parsing hospital entry: $hospitalJson');
                throw FormatException('Failed to parse hospital data: $e');
              }
            }).toList();

            debugPrint('Successfully parsed ${hospitals.length} hospitals');
            return hospitals;
          } catch (e) {
            debugPrint('Detailed parsing error: ${e.toString()}');
            if (e is FormatException) {
              rethrow; // Keep FormatException as is
            }
            throw FormatException('Data parsing failed: ${e.toString()}');
          }
        case 400:
          debugPrint('Bad Request: ${responseData['message']}');
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid hospital data',
          );
        case 401:
          debugPrint('Unauthorized: ${responseData['message']}');
          throw UnauthorizedException(
            responseData['message']?.toString() ??
                'Please login to book appointments',
          );
        case 500:
          debugPrint('Server Error: ${responseData['message']}');
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          debugPrint('Unexpected status code: ${response.statusCode}');
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('General Exception: ${e.toString()}');
      throw Exception('Failed to fetch hospitals: ${e.toString()}');
    }
  }

//VIEW HOSPITAL BY ID
  Future<Hospital> viewHospitalById(String id) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/ViewHospital/$id');
      debugPrint('Uri view hospital' + uri.toString());
      final response = await http.get(
        uri,
        headers: {
          'Content-Type':
              'application/json,text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          // Check if responseData is a list or single object
          if (responseData is List && responseData.isNotEmpty) {
            // If it's a list, take the first hospital
            return Hospital.fromJson(responseData.first);
          } else if (responseData is Map<String, dynamic>) {
            // If it's a single object, parse it directly
            return Hospital.fromJson(responseData);
          } else {
            throw FormatException('Invalid hospital data format');
          }
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid hospital data',
          );
        case 401:
          throw UnauthorizedException(
            responseData['message']?.toString() ??
                'Please login to view hospital details',
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception(
            'Unexpected status code: ${response.statusCode}',
          );
      }
    } catch (e) {
      throw Exception('Failed to fetch hospital details: ${e.toString()}');
    }
  }

// READ REVIEWS FOR USER'S APPOINTMENTS
  Future<List<Appointment>> readAppointmentsReview(String hospitalId) async {
    var authToken = await storage.read(key: 'token');
    debugPrint('Fetching appointments for user $hospitalId');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/AllAppointment/$hospitalId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('Appointments response: ${response.statusCode}');
      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          if (responseData is List) {
            return responseData
                .map((json) => Appointment.fromJson(json))
                .toList();
          }
          throw FormatException(
              'Expected array but got ${responseData.runtimeType}');
        case 404:
          return []; // Return empty list if no appointments found
        default:
          throw Exception(
              'Failed to load appointments: ${responseData['message']}');
      }
    } catch (e) {
      debugPrint('Error reading appointments: $e');
      throw Exception('Failed to fetch appointments: ${e.toString()}');
    }
  }

  //BOOK APPOINMENT
  Future<AppointmentResponse> bookAppointment({
    required AppointmentBooking booking,
  }) async {
    var authToken = await storage.read(key: 'token');

    try {
      final uri = Uri.parse(
          '$baseUrl/BookAppointment/${booking.hospitalId}/${booking.assignId}');

      print('=== API BOOKING REQUEST ===');
      print('Base URL: $baseUrl');
      print('Full Booking URL: $uri');
      print('Hospital ID: ${booking.hospitalId}');
      print('Assign ID: ${booking.assignId}');
      print('Booking JSON: ${json.encode(booking.toJson())}');
      print('Auth Token: ${authToken?.substring(0, 20)}...'); // Show only first 20 chars for security
      print('==========================');

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
            body: json.encode(booking.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      print('=== API BOOKING RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');
      print('============================');

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') || 
          response.body.trim().startsWith('<html')) {
        throw Exception(
          'Server returned HTML error page instead of JSON. '
          'Status: ${response.statusCode}. '
          'This usually means the API endpoint doesn\'t exist or there\'s a server error.'
        );
      }

      // Check if response body is empty
      if (response.body.trim().isEmpty) {
        throw Exception(
          'Server returned empty response. Status: ${response.statusCode}'
        );
      }

      // Try to decode JSON
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        throw Exception(
          'Failed to parse JSON response. Status: ${response.statusCode}. '
          'Response: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}'
        );
      }

      switch (response.statusCode) {
        case 200:
          return AppointmentResponse.fromJson(responseData);
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid booking data',
          );
        case 401:
          throw UnauthorizedException(
            responseData['message']?.toString() ??
                'Please login to book appointments',
          );
        case 404:
          throw Exception(
            'Booking endpoint not found. Please check if the API endpoint exists.'
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception(
            'Unexpected status code: ${response.statusCode}. Response: ${responseData['message'] ?? "No message"}',
          );
      }
    } catch (e) {
      debugPrint('BookAppointment Error: $e');
      throw Exception('Failed to book appointment: ${e.toString()}');
    }
  }

  // EDIT USER
  Future<Map<String, dynamic>> editUser({
    required String userId,
    required String userType,
    required String userName,
    required String userEmail,
    String? userPassword,
  }) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/EditUser/$userId/$userType');
      Map<String, dynamic> body = {
        'UserName': userName,
        'UserEmail': userEmail,
      };
      if (userPassword != null && userPassword.isNotEmpty) {
        body['UserPassword'] = userPassword;
      }

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData;
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid user data',
          );
        case 401:
          throw UnauthorizedException(
            responseData['message']?.toString() ?? 'Unauthorized access',
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to edit user: ${e.toString()}');
    }
  }

  // DELETE USER
  Future<String> deleteUser({
    required String userId,
    required String userType,
  }) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/DeleteUser/$userId/$userType');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData['data']?.toString() ?? 'Delete Successful';
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid request',
          );
        case 401:
          throw UnauthorizedException(
            responseData['message']?.toString() ?? 'Unauthorized access',
          );
        case 500:
          throw ServerException(
            responseData['message']?.toString() ?? 'Internal server error',
          );
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  // ALL APPOINTMENT FOR HOSPITAL
  Future<List<Appointment>> allAppointment(String hospitalId) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/AllAppointment/$hospitalId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          if (responseData is List) {
            return responseData
                .map((json) => Appointment.fromJson(json))
                .toList();
          }
          throw FormatException(
              'Expected array but got ${responseData.runtimeType}');
        case 404:
          return [];
        case 401:
          throw UnauthorizedException('Unauthorized access');
        case 500:
          throw ServerException('Internal server error');
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch appointments: ${e.toString()}');
    }
  }

  // SELECT APPOINTMENT
  Future<List<Appointment>> selectAppointment({
    required String hospitalId,
    required String userId,
  }) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/SelectAppointment/$hospitalId/$userId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          if (responseData is List) {
            return responseData
                .map((json) => Appointment.fromJson(json))
                .toList();
          }
          throw FormatException(
              'Expected array but got ${responseData.runtimeType}');
        case 404:
          return [];
        case 401:
          throw UnauthorizedException('Unauthorized access');
        case 500:
          throw ServerException('Internal server error');
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch appointment: ${e.toString()}');
    }
  }

  // CANCEL APPOINTMENT
  Future<String> cancelAppointment(String appointmentId) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/CancelAppointment/$appointmentId');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData['message']?.toString() ?? 'Cancel Successful';
        case 400:
          throw BadRequestException('Invalid appointment ID');
        case 401:
          throw UnauthorizedException('Unauthorized access');
        case 500:
          throw ServerException('Internal server error');
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to cancel appointment: ${e.toString()}');
    }
  }

  // UPDATE APPOINTMENT STATUS
  Future<String> updateAppointment({
    required String appointmentId,
    required String status,
  }) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri =
          Uri.parse('$baseUrl/UpdateAppointment/$appointmentId/$status');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData['data']?.toString() ?? 'Update Successful';
        case 400:
          throw BadRequestException('Invalid request');
        case 401:
          throw UnauthorizedException('Unauthorized access');
        case 500:
          throw ServerException('Internal server error');
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update appointment: ${e.toString()}');
    }
  }

  // SUBMIT REVIEW
  Future<Map<String, dynamic>> submitReview({
    required String appointmentId,
    required String reviews,
    required double ratings,
  }) async {
    var authToken = await storage.read(key: 'token');
    try {
      final uri = Uri.parse('$baseUrl/SubmitReview/$appointmentId');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'reviews': reviews,
          'ratings': ratings,
        }),
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return responseData;
        case 400:
          throw BadRequestException('Invalid review data');
        case 401:
          throw UnauthorizedException('Unauthorized access');
        case 500:
          throw ServerException('Internal server error');
        default:
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to submit review: ${e.toString()}');
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
