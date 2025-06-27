import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_frontend/controller/api_client_http.dart';
import 'package:mobile_frontend/model/appointment_model.dart';
import 'package:mobile_frontend/model/hospital_model.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class HospitalMapsScreen extends StatefulWidget {
  const HospitalMapsScreen({Key? key}) : super(key: key);

  @override
  State<HospitalMapsScreen> createState() => _HospitalMapsScreenState();
}

class _HospitalMapsScreenState extends State<HospitalMapsScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<Marker> _markers = [];
  List<Hospital> _hospitals = [];
  List<Hospital> _filteredHospitals = [];
  bool _isLoading = true;
  String? _error;

  // Current location - will be updated from GPS
  LatLng? _currentLocation;
  bool _isLocationLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _getCurrentLocation(),
      _loadHospitals(),
    ]);
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled';
          _isLocationLoading = false;
          // Fallback to Kuala Lumpur coordinates
          _currentLocation = LatLng(3.139, 101.6869);
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permissions are denied';
            _isLocationLoading = false;
            // Fallback to Kuala Lumpur coordinates
            _currentLocation = LatLng(3.139, 101.6869);
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permissions are permanently denied';
          _isLocationLoading = false;
          // Fallback to Kuala Lumpur coordinates
          _currentLocation = LatLng(3.139, 101.6869);
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLocationLoading = false;
      });

      _updateMarkers();
    } catch (e) {
      setState(() {
        _error = 'Failed to get current location: ${e.toString()}';
        _isLocationLoading = false;
        // Fallback to Kuala Lumpur coordinates
        _currentLocation = LatLng(3.139, 101.6869);
      });
      _updateMarkers();
    }
  }

  Future<void> _loadHospitals() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final apiClient = ApiClient();
      final hospitals = await apiClient.readAllHospital();

      setState(() {
        _hospitals = hospitals;
        _filteredHospitals = List.from(hospitals);
        _isLoading = false;
      });

      _updateMarkers();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    setState(() {
      _markers = [
        // Current location marker
        Marker(
          point: _currentLocation!,
          builder: (BuildContext context) {
            return const Icon(
              Icons.my_location,
              color: Colors.blue,
              size: 30.0,
            );
          },
        ),
        // Hospital markers
        ..._filteredHospitals
            .map((hospital) => Marker(
                  point: LatLng(hospital.hospitalLang, hospital.hospitalLong),
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () => _showHospitalDetails(hospital),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                            size: 30.0,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              hospital.hospitalName,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ))
            .toList(),
      ];
    });
  }

  void _showHospitalDetails(Hospital hospital) {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not available')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HospitalDetailView(
          hospital: hospital,
          currentLocation: _currentLocation!,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _searchHospitals(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredHospitals = List.from(_hospitals);
      } else {
        _filteredHospitals = _hospitals
            .where((hospital) =>
                hospital.hospitalName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                hospital.hospitalAddress
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
    _updateMarkers();
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    double a = (1 - cos(dLat)) / 2 +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            (1 - cos(dLon)) /
            2;

    return earthRadius * 2 * asin(sqrt(a));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Hospitals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHospitals,
          ),
          if (_currentLocation != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController.move(_currentLocation!, 13.0);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for hospitals...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchHospitals('');
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: _searchHospitals,
            ),
          ),

          // Error message
          if (_error != null)
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _initializeData(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),

          // Map
          if (!_isLoading)
            Expanded(
              child: _currentLocation == null
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Getting your location...'),
                        ],
                      ),
                    )
                  : FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        center: _currentLocation!,
                        zoom: 13.0,
                        interactiveFlags:
                            InteractiveFlag.all & ~InteractiveFlag.rotate,
                        onTap: (_, point) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.hospital.finder.app',
                        ),
                        MarkerLayer(markers: _markers),
                      ],
                    ),
            ),

          // List of hospitals
          if (!_isLoading)
            Container(
              height: 120,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 5,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: _filteredHospitals.isEmpty
                  ? const Center(
                      child: Text('No hospitals found'),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filteredHospitals.length,
                      itemBuilder: (context, index) {
                        final hospital = _filteredHospitals[index];
                        final distance = _currentLocation != null
                            ? _calculateDistance(
                                _currentLocation!,
                                LatLng(hospital.hospitalLang,
                                    hospital.hospitalLong))
                            : 0.0;

                        return Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            elevation: 2,
                            child: InkWell(
                              onTap: () => _showHospitalDetails(hospital),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      hospital.hospitalName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    Text(
                                      hospital.hospitalAddress,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14),
                                        Text(
                                          '${distance.toStringAsFixed(1)} km',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                size: 14, color: Colors.amber),
                                            Text(
                                              hospital.ratings
                                                  .toStringAsFixed(1),
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

class HospitalDetailView extends StatefulWidget {
  final Hospital hospital;
  final LatLng currentLocation;

  const HospitalDetailView({
    Key? key,
    required this.hospital,
    required this.currentLocation,
  }) : super(key: key);

  @override
  State<HospitalDetailView> createState() => _HospitalDetailViewState();
}

class _HospitalDetailViewState extends State<HospitalDetailView> {
  final TextEditingController _reasonVisitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDueDate = DateTime.now().add(const Duration(days: 1));

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // km
    double dLat = _degreesToRadians(point2.latitude - point1.latitude);
    double dLon = _degreesToRadians(point2.longitude - point1.longitude);

    double a = (1 - cos(dLat)) / 2 +
        cos(_degreesToRadians(point1.latitude)) *
            cos(_degreesToRadians(point2.latitude)) *
            (1 - cos(dLon)) /
            2;

    return earthRadius * 2 * asin(sqrt(a));
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng hospitalLocation =
        LatLng(widget.hospital.hospitalLang, widget.hospital.hospitalLong);
    final double distance =
        _calculateDistance(widget.currentLocation, hospitalLocation);

    return Scaffold(
      appBar: AppBar(title: Text(widget.hospital.hospitalName)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map showing location
            SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  center: hospitalLocation,
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.hospital.finder.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: hospitalLocation,
                        builder: (BuildContext context) {
                          return const Icon(
                            Icons.local_hospital,
                            color: Colors.red,
                            size: 40.0,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Hospital information card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red.shade100,
                          child: const Icon(Icons.local_hospital,
                              color: Colors.red, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.hospital.hospitalName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.hospital.hospitalAddress,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      size: 18, color: Colors.amber),
                                  Text(
                                    ' ${widget.hospital.ratings.toStringAsFixed(1)} (${widget.hospital.totalReviews} reviews)',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 16, color: Colors.grey),
                                  Text(
                                    ' ${distance.toStringAsFixed(1)} km away',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Statistics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              widget.hospital.totalAppointments.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Text('Total Appointments'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              widget.hospital.totalReviews.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const Text('Reviews'),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              widget.hospital.ratings.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            const Text('Rating'),
                          ],
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // Forms section
                    const Text(
                      'Make Appointment',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // Expanded reason visit field
                          TextFormField(
                            controller: _reasonVisitController,
                            maxLines: 3,
                            minLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Reason of Visit*',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                              hintText:
                                  'Describe your symptoms or reason for visit...',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please describe your reason for visit';
                              }
                              if (value.length < 20) {
                                return 'Please provide more details (at least 20 characters)';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.sentences,
                          ),
                          const SizedBox(height: 16),

                          // Date field
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: selectedDueDate,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2030),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        selectedDueDate = picked;
                                      });
                                    }
                                  },
                                  child: InputDecorator(
                                    decoration: const InputDecoration(
                                      labelText: 'Appointment Date',
                                      border: OutlineInputBorder(),
                                      suffixIcon: Icon(Icons.calendar_today),
                                    ),
                                    child: Text(
                                      DateFormat('EEE, MMM d, y')
                                          .format(selectedDueDate),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _submitAppointment();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Book Appointment'),
          ),
        ),
      ),
    );
  }

  void _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Create appointment booking object
        final appointmentBooking = AppointmentBooking(
          hospitalId: widget.hospital.hospitalID.toString(),
          assignId: widget.hospital.assign?.toString() ??
              '1', // Default assign ID if null
          timeAppoint: selectedDueDate,
          reasonAppoint: _reasonVisitController.text,
        );

        // Call API to book appointment
        final apiClient = ApiClient();

        final response =
            await apiClient.bookAppointment(booking: appointmentBooking);

        // Close loading dialog
        if (mounted) Navigator.of(context).pop();

        // Check response status
        if (response.status == 200) {
          // Success dialog
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.bottomSlide,
            title: 'Appointment Booked!',
            desc:
                'Your appointment at ${widget.hospital.hospitalName} has been scheduled for ${DateFormat('MMM dd, yyyy').format(selectedDueDate)}.',
            btnOkOnPress: () {
              Navigator.of(context).pop(); // Close hospital detail view
            },
          ).show();

          // Clear form
          _reasonVisitController.clear();
        } else {
          // Show error from API response
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Booking Failed',
            desc: response.message,
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        // Close loading dialog if still mounted
        if (mounted) Navigator.of(context).pop();

        // Show error dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.bottomSlide,
          title: 'Booking Failed',
          desc: 'Failed to book appointment: ${e.toString()}',
          btnOkOnPress: () {},
        ).show();
      }
    }
  }
}
