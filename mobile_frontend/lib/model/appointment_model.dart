class AppointmentBooking {
  final String hospitalId;
  final String assignId;
  final DateTime timeAppoint;
  final String reasonAppoint;

  AppointmentBooking({
    required this.hospitalId,
    required this.assignId,
    required this.timeAppoint,
    required this.reasonAppoint,
  });

  Map<String, dynamic> toJson() => {
    'timeAppoint': timeAppoint.toIso8601String(),
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
    return AppointmentResponse(
      status: json['status'] as int,
      message: json['message'] as String,
    );
  }
}

