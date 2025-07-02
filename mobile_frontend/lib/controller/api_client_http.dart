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
      debugPrint('Response Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      final responseData = json.decode(response.body);
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

      debugPrint(uri.toString());

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

      final responseData = json.decode(response.body);

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
      throw Exception('Failed to book appointment: ${e.toString()}');
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
