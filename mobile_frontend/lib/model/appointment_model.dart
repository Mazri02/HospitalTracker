class Appointment {
  final String appointmentId;
  final String doctorId;
  final String doctorName;
  final String patientId;
  final String patientName;
  final String task;
  final String description;
  final DateTime dateTime;
  final DateTime createdAt;

  Appointment({
    required this.appointmentId,
    required this.doctorId,
    required this.doctorName,
    required this.patientId,
    required this.patientName,
    required this.task,
    required this.description,
    required this.dateTime,
    required this.createdAt,
  });

  // Convert Appointment object to a Map
  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'patientId': patientId,
      'patientName': patientName,
      'task': task,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create an Appointment object from a Map
  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      appointmentId: map['appointmentId'],
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      patientId: map['patientId'],
      patientName: map['patientName'],
      task: map['task'],
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Create a copy of this Appointment with specified attributes changed
  Appointment copyWith({
    String? appointmentId,
    String? doctorId,
    String? doctorName,
    String? patientId,
    String? patientName,
    String? task,
    String? description,
    DateTime? dateTime,
    DateTime? createdAt,
  }) {
    return Appointment(
      appointmentId: appointmentId ?? this.appointmentId,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      task: task ?? this.task,
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}