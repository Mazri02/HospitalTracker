import 'package:flutter/material.dart';

class Hospital {
  final int? hospitalID;
  final String? hospitalName;
  final double? hospitalLang;
  final double? hospitalLong;
  final String? hospitalAddress;
  final int? totalAppointments;
  final int? totalReviews;
  final double? ratings;
  final dynamic assign;  // Changed from int? to dynamic to handle object
  final dynamic doctor;  // Changed to handle doctor object
  final int? doctorID;   // Keep for backward compatibility
  final dynamic doctorPict;
  final String? doctorName; // Keep for backward compatibility

  Hospital({
    this.hospitalID,
    this.hospitalName,
    this.hospitalLang,
    this.hospitalLong,
    this.hospitalAddress,
    this.totalAppointments,
    this.totalReviews,
    this.ratings,
    this.assign,
    this.doctor,
    this.doctorID,
    this.doctorPict,
    this.doctorName,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      hospitalID: tryParseInt(json['HospitalID']),
      hospitalName: json['HospitalName']?.toString(),
      hospitalLang: tryParseDouble(json['HospitalLang']),
      hospitalLong: tryParseDouble(json['HospitalLong']),
      hospitalAddress: json['HospitalAddress']?.toString(),
      totalAppointments: tryParseInt(json['Total_Appointments']),
      totalReviews: tryParseInt(json['Total_Reviews']),
      ratings: tryParseDouble(json['Ratings']),
      assign: json['assign'], // Keep as dynamic object
      doctor: json['doctor'], // Keep as dynamic object
      doctorID: tryParseInt(json['doctorID']) ?? 
                (json['doctor'] is Map ? tryParseInt(json['doctor']['doctorID']) ?? tryParseInt(json['doctor']['id']) : null),
      doctorPict: json['doctorPict'] ?? 
                  (json['doctor'] is Map ? json['doctor']['doctorPict'] : null),
      doctorName: json['doctorName']?.toString() ?? 
                  (json['doctor'] is Map ? json['doctor']['doctorName']?.toString() ?? json['doctor']['name']?.toString() : null),
    );
  }

  static int? tryParseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static double? tryParseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }
}

// Hospital with appointment status for homepage
class HospitalWithStatus {
  final Hospital hospital;
  final AppointmentStatus appointmentStatus;
  final String? appointmentId;

  HospitalWithStatus({
    required this.hospital,
    required this.appointmentStatus,
    this.appointmentId,
  });
}

enum AppointmentStatus {
  none, // No appointment - show "BOOK APPOINTMENT"
  pending, // Appointment pending - show "PENDING"
  approved, // Appointment approved - show "APPROVED"
  rejected, // Appointment rejected - show "BOOK APPOINTMENT"
}

extension AppointmentStatusExtension on AppointmentStatus {
  String get displayText {
    switch (this) {
      case AppointmentStatus.none:
      case AppointmentStatus.rejected:
        return "BOOK APPOINTMENT";
      case AppointmentStatus.pending:
        return "PENDING";
      case AppointmentStatus.approved:
        return "APPROVED";
    }
  }

  Color get buttonColor {
    switch (this) {
      case AppointmentStatus.none:
      case AppointmentStatus.rejected:
        return Colors.green;
      case AppointmentStatus.pending:
        return Colors.orange;
      case AppointmentStatus.approved:
        return Colors.blue;
    }
  }
}
