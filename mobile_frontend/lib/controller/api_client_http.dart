import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_frontend/model/appointment_model.dart';
import 'package:mobile_frontend/model/hospital_model.dart';

class ApiClient {
  static String baseUrl = '${dotenv.env['APP_HOST']}/api';
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    // Add any other headers like authorization if needed
    // 'Authorization': 'Bearer your_token',
  };

  static String authToken = 'xxxjkkkwk';

  // READ ALL HOSPITAL
  static Future<List<Hospital>> readAllHospital() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/AllHospital'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 15));

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          try {
            final List<dynamic> hospitalsJson = json.decode(response.body);
            if (hospitalsJson.isEmpty) {
              print('Hospital data is Empty');
              return []; // Return empty list instead of null
            }
            return hospitalsJson
                .map((json) => Hospital.fromJson(json))
                .toList();
          } catch (e) {
            throw FormatException('Wrong on format ${e.toString()}');
          }
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid hospital data',
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
          throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch hospitals: ${e.toString()}');
    }
  }

  //VIEW HOSPITAL BY ID
  static Future<dynamic> viewHospitalById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/AllHospital'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final responseData = json.decode(response.body);

      switch (response.statusCode) {
        case 200:
          return Hospital.fromJson(json.decode(response.body));
        case 400:
          throw BadRequestException(
            responseData['message']?.toString() ?? 'Invalid hospital data',
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
      throw Exception('Failed to fetch hospitals: ${e.toString()}');
    }
  }

  //BOOK APPOINMENT
  static Future<AppointmentResponse> bookAppointment({
    required AppointmentBooking booking,
  }) async {
    try {
      final uri = Uri.parse(
          '$baseUrl/BookAppointment/${booking.hospitalId}/${booking.assignId}');

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

      final responseData = json.decode(response.body) as Map<String, dynamic>;

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
