import 'package:flutter/material.dart';
import 'package:mobile_frontend/controller/appointment_service.dart';
import 'package:mobile_frontend/model/appointment_model.dart';

class DAppointment extends StatefulWidget {
  const DAppointment({Key? key}) : super(key: key);

  @override
  State<DAppointment> createState() => _DAppointmentState();
}

class _DAppointmentState extends State<DAppointment> {
  @override
  Widget build(BuildContext context) {
    return const AppointmentListView();
  }
}

class AppointmentListView extends StatefulWidget {
  const AppointmentListView({Key? key}) : super(key: key);

  @override
  State<AppointmentListView> createState() => _AppointmentListViewState();
}

class _AppointmentListViewState extends State<AppointmentListView> {
  final AppointmentController _controller = AppointmentController();
  late List<Appointment> _appointments;

  @override
  void initState() {
    super.initState();
    _appointments = _controller.getAllAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      _appointments = _controller.getAllAppointments();
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        backgroundColor: Colors.blue,
      ),
      body: _appointments.isEmpty
          ? const Center(child: Text('No appointments available'))
          : ListView.builder(
              itemCount: _appointments.length,
              itemBuilder: (context, index) {
                final appointment = _appointments[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(
                        '${appointment.task} - ${appointment.patientName}'),
                    subtitle: Text(
                      'Doctor: ${appointment.doctorName}\nDateTime: ${_formatDateTime(appointment.dateTime)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AppointmentFormView(
                                  appointment: appointment,
                                  isEditing: true,
                                ),
                              ),
                            );
                            if (result == true) {
                              _refreshAppointments();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                appointment.appointmentId);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentDetailView(
                            appointmentId: appointment.appointmentId,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppointmentFormView(
                isEditing: false,
              ),
            ),
          );
          if (result == true) {
            _refreshAppointments();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(String appointmentId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Appointment'),
          content:
              const Text('Are you sure you want to delete this appointment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                _controller.deleteAppointment(appointmentId);
                Navigator.of(context).pop();
                _refreshAppointments();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Appointment deleted successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class AppointmentDetailView extends StatelessWidget {
  final String appointmentId;
  final AppointmentController _controller = AppointmentController();

  AppointmentDetailView({Key? key, required this.appointmentId})
      : super(key: key);

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appointment = _controller.getAppointmentById(appointmentId);

    if (appointment == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Not Found'),
          backgroundColor: Colors.red,
        ),
        body: const Center(
          child: Text('The requested appointment does not exist.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Appointment Information', [
              _buildDetailRow('ID', appointment.appointmentId),
              _buildDetailRow('Task', appointment.task),
              _buildDetailRow(
                  'Date & Time', _formatDateTime(appointment.dateTime)),
              _buildDetailRow(
                  'Created At', _formatDateTime(appointment.createdAt)),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Doctor Information', [
              _buildDetailRow('Doctor ID', appointment.doctorId),
              _buildDetailRow('Doctor Name', appointment.doctorName),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Patient Information', [
              _buildDetailRow('Patient ID', appointment.patientId),
              _buildDetailRow('Patient Name', appointment.patientName),
            ]),
            const SizedBox(height: 16),
            _buildInfoCard('Description', [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  appointment.description,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentFormView extends StatefulWidget {
  final Appointment? appointment;
  final bool isEditing;

  const AppointmentFormView({
    Key? key,
    this.appointment,
    required this.isEditing,
  }) : super(key: key);

  @override
  State<AppointmentFormView> createState() => _AppointmentFormViewState();
}

class _AppointmentFormViewState extends State<AppointmentFormView> {
  final _formKey = GlobalKey<FormState>();
  final AppointmentController _controller = AppointmentController();

  late TextEditingController _doctorIdController;
  late TextEditingController _doctorNameController;
  late TextEditingController _patientIdController;
  late TextEditingController _patientNameController;
  late TextEditingController _taskController;
  late TextEditingController _descriptionController;

  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.appointment != null) {
      _doctorIdController =
          TextEditingController(text: widget.appointment!.doctorId);
      _doctorNameController =
          TextEditingController(text: widget.appointment!.doctorName);
      _patientIdController =
          TextEditingController(text: widget.appointment!.patientId);
      _patientNameController =
          TextEditingController(text: widget.appointment!.patientName);
      _taskController = TextEditingController(text: widget.appointment!.task);
      _descriptionController =
          TextEditingController(text: widget.appointment!.description);
      _selectedDateTime = widget.appointment!.dateTime;
    } else {
      _doctorIdController = TextEditingController();
      _doctorNameController = TextEditingController();
      _patientIdController = TextEditingController();
      _patientNameController = TextEditingController();
      _taskController = TextEditingController();
      _descriptionController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _doctorIdController.dispose();
    _doctorNameController.dispose();
    _patientIdController.dispose();
    _patientNameController.dispose();
    _taskController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveAppointment() {
    if (_formKey.currentState!.validate()) {
      if (widget.isEditing && widget.appointment != null) {
        // Update existing appointment
        final updatedAppointment = Appointment(
          appointmentId: widget.appointment!.appointmentId,
          doctorId: _doctorIdController.text,
          doctorName: _doctorNameController.text,
          patientId: _patientIdController.text,
          patientName: _patientNameController.text,
          task: _taskController.text,
          description: _descriptionController.text,
          dateTime: _selectedDateTime,
          createdAt: widget.appointment!.createdAt,
        );

        _controller.updateAppointment(updatedAppointment);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment updated successfully')),
        );
      } else {
        // Create new appointment
        final newAppointment = Appointment(
          appointmentId: _controller.generateAppointmentId(),
          doctorId: _doctorIdController.text,
          doctorName: _doctorNameController.text,
          patientId: _patientIdController.text,
          patientName: _patientNameController.text,
          task: _taskController.text,
          description: _descriptionController.text,
          dateTime: _selectedDateTime,
          createdAt: DateTime.now(),
        );

        _controller.addAppointment(newAppointment);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment created successfully')),
        );
      }

      Navigator.pop(context, true);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.isEditing ? 'Edit Appointment' : 'Create Appointment'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Information
                Text(
                  'Doctor Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _doctorIdController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _doctorNameController,
                  decoration: const InputDecoration(
                    labelText: 'Doctor Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Patient Information
                Text(
                  'Patient Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _patientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Patient ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _patientNameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Appointment Details
                Text(
                  'Appointment Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Task',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter appointment task';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter appointment description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date and Time Selector
                InkWell(
                  onTap: () => _selectDateTime(context),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date & Time',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDateTime(_selectedDateTime)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      widget.isEditing
                          ? 'Update Appointment'
                          : 'Create Appointment',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
