class Appointment {
  final int appointmentId;
  final int userId;
  final int assignId;
  final String? reviews;
  final double? ratings;
  final String status;
  final DateTime assignDate;
  final String reasonVisit;

  Appointment({
    required this.appointmentId,
    required this.userId,
    required this.assignId,
    this.reviews,
    this.ratings,
    required this.status,
    required this.assignDate,
    required this.reasonVisit,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      appointmentId: json['AppoinmentID'] as int,
      userId: json['UserID'] as int,
      assignId: json['AssignID'] as int,
      reviews: json['Reviews']?.toString(),
      ratings: json['Ratings'] != null
          ? double.tryParse(json['Ratings'].toString())
          : null,
      status: json['Status'] as String,
      assignDate: DateTime.parse(json['AssignDate'] as String),
      reasonVisit: json['ReasonVisit'] as String,
    );
  }
}

class AppointmentBooking {
  final String hospitalId;
  final String assignId;
  final String timeAppoint;
  final String reasonAppoint;

  AppointmentBooking({
    required this.hospitalId,
    required this.assignId,
    required this.timeAppoint,
    required this.reasonAppoint,
  });

  Map<String, dynamic> toJson() => {
        'timeAppoint': timeAppoint,
        'reasonAppoint': reasonAppoint,
      };
}

class AppointmentResponse {
  final int status;
  final String message;

  AppointmentResponse({
    required this.status,
    required this.message,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Debug parsing

      return AppointmentResponse(
        status: json['status'] as int? ?? 0, // Default to 0 if null
        message:
            json['message'] as String? ?? '', // Default to empty string if null
      );
    } catch (e) {
      throw FormatException(
          'Failed to parse AppointmentResponse: ${e.toString()}');
    }
  }

  Map<String, dynamic> toJson() {
    try {
      final json = {
        'status': status,
        'message': message,
      };
      return json;
    } catch (e) {
      throw FormatException('Failed to convert AppointmentResponse to JSON');
    }
  }

  @override
  String toString() {
    return 'AppointmentResponse(status: $status, message: "$message")';
  }
}
