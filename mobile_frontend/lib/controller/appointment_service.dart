import 'package:mobile_frontend/model/appointment_model.dart';


class AppointmentController {
  // Singleton pattern for AppointmentController
  static final AppointmentController _instance = AppointmentController._internal();

  factory AppointmentController() {
    return _instance;
  }

  AppointmentController._internal();

  // In-memory database for appointments (dummy data)
  List<Appointment> _appointments = [
    Appointment(
      appointmentId: 'A001',
      doctorId: 'D001',
      doctorName: 'Dr. John Smith',
      patientId: 'P001',
      patientName: 'Alice Johnson',
      task: 'General Check-up',
      description: 'Annual physical examination',
      dateTime: DateTime.now().add(const Duration(days: 1)),
      createdAt: DateTime.now(),
    ),
    Appointment(
      appointmentId: 'A002',
      doctorId: 'D002',
      doctorName: 'Dr. Emily Davis',
      patientId: 'P002',
      patientName: 'Bob Wilson',
      task: 'Dental Cleaning',
      description: 'Regular dental cleaning and check-up',
      dateTime: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now(),
    ),
    Appointment(
      appointmentId: 'A003',
      doctorId: 'D001',
      doctorName: 'Dr. John Smith',
      patientId: 'P003',
      patientName: 'Carol Martinez',
      task: 'Follow-up',
      description: 'Follow-up appointment for medication review',
      dateTime: DateTime.now().add(const Duration(days: 3)),
      createdAt: DateTime.now(),
    ),
    Appointment(
      appointmentId: 'A004',
      doctorId: 'D003',
      doctorName: 'Dr. Sarah Lee',
      patientId: 'P004',
      patientName: 'David Brown',
      task: 'Consultation',
      description: 'Initial consultation for knee pain',
      dateTime: DateTime.now().add(const Duration(days: 4)),
      createdAt: DateTime.now(),
    ),
    Appointment(
      appointmentId: 'A005',
      doctorId: 'D002',
      doctorName: 'Dr. Emily Davis',
      patientId: 'P005',
      patientName: 'Eva Thompson',
      task: 'X-Ray',
      description: 'Chest X-Ray for persistent cough',
      dateTime: DateTime.now().add(const Duration(days: 5)),
      createdAt: DateTime.now(),
    ),
  ];

  // CRUD Operations

  // Create - Add a new appointment
  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
  }

  // Read - Get all appointments
  List<Appointment> getAllAppointments() {
    return List.from(_appointments);
  }

  // Read - Get appointments by doctor ID
  List<Appointment> getAppointmentsByDoctorId(String doctorId) {
    return _appointments.where((appointment) => appointment.doctorId == doctorId).toList();
  }

  // Read - Get appointments by patient ID
  List<Appointment> getAppointmentsByPatientId(String patientId) {
    return _appointments.where((appointment) => appointment.patientId == patientId).toList();
  }

  // Read - Get appointment by ID
  Appointment? getAppointmentById(String appointmentId) {
    try {
      return _appointments.firstWhere((appointment) => appointment.appointmentId == appointmentId);
    } catch (e) {
      return null;
    }
  }

  // Update - Update an existing appointment
  bool updateAppointment(Appointment updatedAppointment) {
    final index = _appointments.indexWhere(
        (appointment) => appointment.appointmentId == updatedAppointment.appointmentId);
    
    if (index != -1) {
      _appointments[index] = updatedAppointment;
      return true;
    }
    return false;
  }

  // Delete - Delete an appointment by ID
  bool deleteAppointment(String appointmentId) {
    final initialLength = _appointments.length;
    _appointments.removeWhere((appointment) => appointment.appointmentId == appointmentId);
    return _appointments.length < initialLength;
  }

  // Generate a new appointment ID
  String generateAppointmentId() {
    if (_appointments.isEmpty) {
      return 'A001';
    }
    
    // Extract the numeric part of the last ID and increment it
    final lastId = _appointments.map((e) => e.appointmentId).toList()..sort();
    final lastNumber = int.parse(lastId.last.substring(1));
    return 'A${(lastNumber + 1).toString().padLeft(3, '0')}';
  }
}