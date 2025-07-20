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
      // First get the list of hospitals (without doctor data)
      final response = await http.get(
        Uri.parse('$baseUrl/AllHospital'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 15));
      
      print('=== BASIC HOSPITAL LIST ===');
      print('Response Status Code: ${response.statusCode}');
      final responseData = json.decode(response.body);

      if (responseData is! List || responseData.isEmpty) {
        debugPrint('No hospitals found or invalid response');
        return [];
      }

      print('Found ${responseData.length} hospitals, now getting detailed data...');
      
      // Now get detailed data for each hospital using ViewHospital API
      List<Hospital> detailedHospitals = [];
      
      for (int i = 0; i < responseData.length; i++) {
        final hospitalId = responseData[i]['HospitalID'];
        if (hospitalId != null) {
          try {
            print('Getting details for hospital ID: $hospitalId');
            final detailedHospital = await viewHospitalById(hospitalId.toString());
            detailedHospitals.add(detailedHospital);
            print('Successfully got details for hospital: ${detailedHospital.hospitalName}');
            print('Doctor name: ${detailedHospital.doctorName}');
          } catch (e) {
            print('Error getting details for hospital $hospitalId: $e');
            // Add the basic hospital data if detailed fetch fails
            try {
              detailedHospitals.add(Hospital.fromJson(responseData[i]));
            } catch (parseError) {
              print('Error parsing basic hospital data: $parseError');
            }
          }
        }
      }
      
      print('=== FINAL HOSPITAL DATA ===');
      for (int i = 0; i < detailedHospitals.length; i++) {
        final hospital = detailedHospitals[i];
        print('Hospital $i: ${hospital.hospitalName} - Doctor: ${hospital.doctorName}');
      }
      print('=============================');
      
      return detailedHospitals;
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
    var userId = await storage.read(key: 'userId');
    debugPrint('Fetching appointments for hospital $hospitalId and user $userId');

    try {
      // First try to get user-specific appointments for this hospital
      final response = await http.get(
        Uri.parse('$baseUrl/SelectAppointment/$hospitalId/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ).timeout(const Duration(seconds: 10));

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
          // If no user-specific appointments, return empty list
          debugPrint('No appointments found for user at this hospital');
          return [];
        default:
          throw Exception(
              'Failed to load appointments: ${responseData['message']}');
      }
    } catch (e) {
      debugPrint('Error reading appointments: $e');
      // Return empty list instead of throwing error to prevent UI crashes
      return [];
    }
  }

  //BOOK APPOINMENT
  Future<AppointmentResponse> bookAppointment({
    required AppointmentBooking booking,
  }) async {
    var authToken = await storage.read(key: 'token');

    try {
      // Try different endpoint formats
      Uri uri;
      
      // Get user ID from storage
      final userId = await storage.read(key: 'userId');
      print('User ID from storage: $userId');
      
      // Format 1: /api/BookAppointment/{userId}/{assignId} (CORRECT FORMAT)
      uri = Uri.parse('$baseUrl/BookAppointment/$userId/${booking.assignId}');
      
      print('Trying endpoint format: $uri');
      print('Note: Using userId ($userId) instead of hospitalId (${booking.hospitalId})');
      
      // Also test alternative endpoint formats
      final alternativeEndpoints = [
        '$baseUrl/BookAppointment',
        '$baseUrl/Appointment/Book',
        '$baseUrl/Appointment/Create',
        '$baseUrl/BookAppointment/$userId',
      ];
      
      print('Alternative endpoints to try if main fails:');
      for (final endpoint in alternativeEndpoints) {
        print('  - $endpoint');
      }
      
      // Test if endpoint exists with a simple GET request
      try {
        final testResponse = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 5));
        
        print('Endpoint test - Status: ${testResponse.statusCode}');
        if (testResponse.statusCode == 405) {
          print('Endpoint exists but method not allowed (expected for GET)');
        } else if (testResponse.statusCode == 404) {
          print('WARNING: Endpoint not found!');
        }
      } catch (e) {
        print('Endpoint test failed: $e');
      }
      
      // Test if other API endpoints are working
      try {
        final testHospitalResponse = await http.get(
          Uri.parse('$baseUrl/AllHospital'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ).timeout(const Duration(seconds: 5));
        
        print('AllHospital endpoint test - Status: ${testHospitalResponse.statusCode}');
        if (testHospitalResponse.statusCode == 200) {
          print('Other API endpoints are working fine');
        } else {
          print('WARNING: Other API endpoints also failing!');
        }
      } catch (e) {
        print('AllHospital endpoint test failed: $e');
      }

      print('=== API BOOKING REQUEST ===');
      print('Base URL: $baseUrl');
      print('Full Booking URL: $uri');
      print('Hospital ID: ${booking.hospitalId}');
      print('Assign ID: ${booking.assignId}');
      print('Booking JSON: ${json.encode(booking.toJson())}');
      print('Auth Token: ${authToken?.substring(0, 20)}...'); // Show only first 20 chars for security
      print('==========================');

      // Try different request formats
      http.Response response;
      
      // Method 1: POST with JSON body
      try {
        print('Trying POST with JSON body...');
        response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: json.encode(booking.toJson()),
            )
            .timeout(const Duration(seconds: 10));
        
        print('POST with JSON body successful');
      } catch (e) {
        print('POST with JSON body failed: $e');
        
        // Method 2: POST with form data
        try {
          print('Trying POST with form data...');
          response = await http
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded',
                  'Authorization': 'Bearer $authToken',
                },
                body: Uri(queryParameters: {
                  'timeAppoint': booking.timeAppoint,
                  'reasonAppoint': booking.reasonAppoint,
                }).query,
              )
              .timeout(const Duration(seconds: 10));
          
          print('POST with form data successful');
        } catch (e2) {
          print('POST with form data failed: $e2');
          
          // Method 3: PUT with JSON body
          print('Trying PUT with JSON body...');
          response = await http
              .put(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authToken',
                },
                body: json.encode(booking.toJson()),
              )
              .timeout(const Duration(seconds: 10));
          
          print('PUT with JSON body successful');
        }
      }
      
      // Method 4: POST with URL parameters (if all above fail)
      if (response.statusCode == 500) {
        print('All methods returned 500, trying POST with URL parameters...');
        final uriWithParams = Uri.parse('$baseUrl/BookAppointment/${booking.hospitalId}/${booking.assignId}').replace(
          queryParameters: {
            'timeAppoint': booking.timeAppoint,
            'reasonAppoint': booking.reasonAppoint,
          },
        );
        
        response = await http
            .post(
              uriWithParams,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
            )
            .timeout(const Duration(seconds: 10));
        
        print('POST with URL parameters completed');
      }
      
      // Method 5: Try with user ID in body (if still 500)
      if (response.statusCode == 500) {
        print('Still getting 500, trying with user ID in body...');
        
        // Get user ID from token or storage
        final userId = await storage.read(key: 'userId');
        print('User ID from storage: $userId');
        
        final bookingWithUserId = {
          ...booking.toJson(),
          'userId': userId,
        };
        
        response = await http
            .post(
              uri,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $authToken',
              },
              body: json.encode(bookingWithUserId),
            )
            .timeout(const Duration(seconds: 10));
        
        print('POST with user ID completed');
      }
      
      // Method 6: Try alternative endpoints (if still 500)
      if (response.statusCode == 500) {
        print('Still getting 500, trying alternative endpoints...');
        
        for (final endpoint in alternativeEndpoints) {
          print('Trying endpoint: $endpoint');
          
          try {
            final altResponse = await http
                .post(
                  Uri.parse(endpoint),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $authToken',
                  },
                  body: json.encode(booking.toJson()),
                )
                .timeout(const Duration(seconds: 5));
            
            print('Alternative endpoint $endpoint - Status: ${altResponse.statusCode}');
            
            if (altResponse.statusCode != 500) {
              print('SUCCESS: Alternative endpoint worked!');
              response = altResponse;
              break;
            }
          } catch (e) {
            print('Alternative endpoint $endpoint failed: $e');
          }
        }
      }
      
      // Method 7: Try different request formats with the working endpoint
      if (response.statusCode == 404) {
        print('Got 404, trying different request formats with /api/BookAppointment...');
        
        final workingEndpoint = '$baseUrl/BookAppointment';
        
        // Try with hospital and assign IDs in body
        try {
          print('Trying with hospital and assign IDs in body...');
          final requestBody = {
            'hospitalId': booking.hospitalId,
            'assignId': booking.assignId,
            'timeAppoint': booking.timeAppoint,
            'reasonAppoint': booking.reasonAppoint,
          };
          
          final altResponse = await http
              .post(
                Uri.parse(workingEndpoint),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $authToken',
                },
                body: json.encode(requestBody),
              )
              .timeout(const Duration(seconds: 5));
          
          print('With IDs in body - Status: ${altResponse.statusCode}');
          
          if (altResponse.statusCode == 200) {
            print('SUCCESS: This format worked!');
            response = altResponse;
          } else {
            // Try with different field names
            print('Trying with different field names...');
            final requestBodyAlt = {
              'hospital_id': booking.hospitalId,
              'assign_id': booking.assignId,
              'appointment_time': booking.timeAppoint,
              'reason': booking.reasonAppoint,
            };
            
            final altResponse2 = await http
                .post(
                  Uri.parse(workingEndpoint),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $authToken',
                  },
                  body: json.encode(requestBodyAlt),
                )
                .timeout(const Duration(seconds: 5));
            
            print('With different field names - Status: ${altResponse2.statusCode}');
            
            if (altResponse2.statusCode == 200) {
              print('SUCCESS: Different field names worked!');
              response = altResponse2;
            }
          }
        } catch (e) {
          print('With IDs in body failed: $e');
        }
      }

      print('=== API BOOKING RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Raw Response Body: ${response.body}');
      
      // If it's HTML, try to extract useful error info
      if (response.body.trim().startsWith('<!DOCTYPE') || response.body.trim().startsWith('<html')) {
        print('=== HTML ERROR ANALYSIS ===');
        if (response.body.contains('Fatal error')) {
          print('FATAL ERROR DETECTED');
        }
        if (response.body.contains('Parse error')) {
          print('PARSE ERROR DETECTED');
        }
        if (response.body.contains('Database')) {
          print('DATABASE ERROR DETECTED');
        }
        if (response.body.contains('Table')) {
          print('TABLE ERROR DETECTED');
        }
        print('==========================');
      }
      print('============================');

      // Check if response is HTML (error page)
      if (response.body.trim().startsWith('<!DOCTYPE') || 
          response.body.trim().startsWith('<html')) {
        // Try to extract error message from HTML
        String errorMessage = 'Server returned HTML error page instead of JSON. Status: ${response.statusCode}.';
        
        // Look for common error patterns in HTML
        if (response.body.contains('Fatal error') || response.body.contains('Parse error')) {
          errorMessage += ' PHP error detected.';
        }
        if (response.body.contains('Database connection failed')) {
          errorMessage += ' Database connection issue.';
        }
        if (response.body.contains('Table') && response.body.contains('doesn\'t exist')) {
          errorMessage += ' Database table missing.';
        }
        
        throw Exception(errorMessage);
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
