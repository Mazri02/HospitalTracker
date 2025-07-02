import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_frontend/controller/api_client_http.dart';
import 'package:mobile_frontend/model/appointment_model.dart';
import 'package:mobile_frontend/model/hospital_model.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
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

    // Filter out hospitals with invalid coordinates
    final validHospitals = _filteredHospitals.where((hospital) {
      final lat = hospital.hospitalLang;
      final lng = hospital.hospitalLong;
      return lat != null &&
          lng != null &&
          lat >= -90 &&
          lat <= 90 &&
          lng >= -180 &&
          lng <= 180;
    }).toList();

    setState(() {
      _markers = [
        // Current location marker
        Marker(
          point: _currentLocation!,
          builder: (BuildContext context) => const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 30.0,
          ),
        ),
        // Hospital markers (only valid ones)
        ...validHospitals
            .map((hospital) => Marker(
                  point: LatLng(hospital.hospitalLang!, hospital.hospitalLong!),
                  builder: (BuildContext context) => GestureDetector(
                    onTap: () => _showHospitalDetails(hospital),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: 1.5,
                          child: const Icon(Icons.location_pin,
                              color: Colors.red, size: 15.0),
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
                                  blurRadius: 2),
                            ],
                          ),
                          child: Text(
                            hospital.hospitalName ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                hospital.hospitalName!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                hospital.hospitalAddress!
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
                        final distance = _currentLocation != null &&
                                hospital.hospitalLang != null &&
                                hospital.hospitalLong != null &&
                                hospital.hospitalLang! >= -90 &&
                                hospital.hospitalLang! <= 90 &&
                                hospital.hospitalLong! >= -180 &&
                                hospital.hospitalLong! <= 180
                            ? _calculateDistance(
                                _currentLocation!,
                                LatLng(hospital.hospitalLang!,
                                    hospital.hospitalLong!))
                            : null;

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
                                      hospital.hospitalName ?? 'N/A',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    Text(
                                      hospital.hospitalAddress ?? 'N/A',
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 14),
                                        Text(
                                          '${distance?.toStringAsFixed(1) ?? '0.0'} km',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        const Spacer(),
                                        Row(
                                          children: [
                                            const Icon(Icons.star,
                                                size: 14, color: Colors.amber),
                                            Text(
                                              hospital.ratings
                                                      ?.toStringAsFixed(1) ??
                                                  'N/A',
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

  //Appointment Part
  List<Appointment> _userAppointments = [];
  bool _loadingAppointments = false;
  String? _appointmentsError;

  // Add state variables for loading and detailed hospital data
  bool _isLoading = true;
  Hospital? _detailedHospital;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHospitalDetails();
    _loadUserAppointments();
  }

  //Add appointment review method
  Future<void> _loadUserAppointments() async {
    try {
      setState(() {
        _loadingAppointments = true;
        _appointmentsError = null;
      });

      final appointments = await ApiClient()
          .readAppointmentsReview(widget.hospital.hospitalID.toString());

      setState(() {
        // Filter appointments for this hospital only
        _userAppointments =
            appointments.where((appt) => appt.reviews != null).toList();
        _loadingAppointments = false;
      });
    } catch (e) {
      setState(() {
        _appointmentsError = e.toString();
        _loadingAppointments = false;
      });
      debugPrint('Error loading appointments: $e');
    }
  }

  // Add method to load detailed hospital data
  Future<void> _loadHospitalDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final apiClient = ApiClient();
      final detailedHospital = await apiClient.viewHospitalById(
        widget.hospital.hospitalID.toString(),
      );

      setState(() {
        _detailedHospital = detailedHospital;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        // Fallback to the original hospital data if API call fails
        _detailedHospital = widget.hospital;
      });
    }
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
  Widget build(BuildContext context) {
    // Use detailed hospital data if available, otherwise use the original
    final currentHospital = _detailedHospital ?? widget.hospital;

    final LatLng? hospitalLocation = currentHospital.hospitalLang != null &&
            currentHospital.hospitalLong != null &&
            currentHospital.hospitalLang! >= -90 &&
            currentHospital.hospitalLang! <= 90 &&
            currentHospital.hospitalLong! >= -180 &&
            currentHospital.hospitalLong! <= 180
        ? LatLng(currentHospital.hospitalLang!, currentHospital.hospitalLong!)
        : null;

    debugPrint('this is location' + hospitalLocation.toString());

    final double? distance = hospitalLocation != null
        ? _calculateDistance(widget.currentLocation, hospitalLocation)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentHospital.hospitalName ?? 'N/A'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHospitalDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading hospital details...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Error message if any
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        border: Border.all(color: Colors.orange.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Using cached data',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                                Text(
                                  'Could not load latest hospital details',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Map showing location
                  SizedBox(
                    height: 200,
                    child: hospitalLocation != null
                        ? FlutterMap(
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
                                        Icons.location_pin,
                                        color: Colors.red,
                                        size: 27.0,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          )
                        : const Center(
                            child: Text('Invalid hospital location')),
                  ),

                  // Hospital information card
                  Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child: Image.network(
                                  dotenv.env['BASE_URL']! +
                                      '/${currentHospital.hospitalPict}', // Use the constructed URL
                                  headers: {
                                    'Content-Type':
                                        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
                                  },
                                  fit: BoxFit.cover,
                                  width: 75,
                                  height: 75,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child; // Image is fully loaded
                                    }
                                    return Center(
                                      // Center the progress indicator
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!,
                                      ),
                                    );
                                  },
                                  errorBuilder: (BuildContext context,
                                      Object error, StackTrace? stackTrace) {
                                    debugPrint(
                                        'Image loading error: $error'); // Print error to console
                                    return const Icon(
                                        Icons
                                            .broken_image, // Show a broken image icon on error
                                        color: Colors.red,
                                        size: 20);
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currentHospital.hospitalName ?? 'N/A',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      currentHospital.hospitalAddress ?? 'N/A',
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
                                          ' ${currentHospital.ratings?.toStringAsFixed(1) ?? 'N/A'}  (${currentHospital.totalReviews ?? 0} reviews)',
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
                                          distance != null
                                              ? '${distance.toStringAsFixed(1)} km away'
                                              : 'Distance unavailable',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Doctor information (if available from detailed API)
                          if (currentHospital.doctorID != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      ClipOval(
                                        child: Image.network(
                                          dotenv.env['BASE_URL']! +
                                              '/${currentHospital.doctorPict}', // Use the constructed URL
                                          headers: {
                                            'Content-Type':
                                                'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
                                          }, // Pass the authentication headers
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                          loadingBuilder: (BuildContext context,
                                              Widget child,
                                              ImageChunkEvent?
                                                  loadingProgress) {
                                            if (loadingProgress == null) {
                                              return child; // Image is fully loaded
                                            }
                                            return Center(
                                              // Center the progress indicator
                                              child: CircularProgressIndicator(
                                                value: loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!,
                                              ),
                                            );
                                          },
                                          errorBuilder: (BuildContext context,
                                              Object error,
                                              StackTrace? stackTrace) {
                                            debugPrint(
                                                'Image loading error: $error'); // Print error to console
                                            return const Icon(
                                                Icons
                                                    .broken_image, // Show a broken image icon on error
                                                color: Colors.red,
                                                size: 20);
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentHospital.doctorName
                                                  .toString(),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const Text(
                                              'Available for consultation',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
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
                                    currentHospital.totalAppointments
                                            ?.toString() ??
                                        '0',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const Text('Appointments'),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    currentHospital.totalReviews?.toString() ??
                                        '0',
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
                                    currentHospital.ratings
                                            ?.toStringAsFixed(1) ??
                                        'N/A',
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

                          const Text(
                            'Patient Review',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          _buildAppointmentsSection(),

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
                                  textCapitalization:
                                      TextCapitalization.sentences,
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
                                            suffixIcon:
                                                Icon(Icons.calendar_today),
                                          ),
                                          child: Text(
                                            DateFormat('EEE, MMM d, y')
                                                .format(selectedDueDate),
                                            style:
                                                const TextStyle(fontSize: 16),
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
      bottomNavigationBar: _isLoading
          ? null
          : BottomAppBar(
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

        // Use detailed hospital data if available, otherwise use the original
        final currentHospital = _detailedHospital ?? widget.hospital;
        debugPrint('this is ' + currentHospital.assign.toString());
        debugPrint('this is ' + currentHospital.hospitalID.toString());

        // Create appointment booking object
        final appointmentBooking = AppointmentBooking(
          hospitalId: currentHospital.doctorID.toString(),
          assignId: currentHospital.assign?.toString() ??
              'null', // Default assign ID if null
          timeAppoint: selectedDueDate.toString(),
          reasonAppoint: _reasonVisitController.text,
        );

        // Call API to book appointment
        final apiClient = ApiClient();

        debugPrint(appointmentBooking.toString());

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
                'Your appointment at ${currentHospital.hospitalName} has been scheduled for ${DateFormat('MMM dd, yyyy').format(selectedDueDate)}.',
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
        debugPrint('This is response' + e.toString());
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

  @override
  void dispose() {
    _reasonVisitController.dispose();
    super.dispose();
  }

  Widget _buildAppointmentsSection() {
    if (_loadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appointmentsError != null) {
      return Center(
        child: Text(
          'Failed to load appointments: $_appointmentsError',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_userAppointments.isEmpty) {
      return Center(
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            vertical: 8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.feedback,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 8),
                const Text(
                  'No Review Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Your Appointments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ..._userAppointments
            .map((appointment) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (appointment.reviews != null) ...[
                          const Divider(height: 16),
                          const Text('Your Review:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(appointment.reviews!),
                          if (appointment.ratings != null)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 16, color: Colors.amber),
                                Text(
                                    ' ${appointment.ratings!.toStringAsFixed(1)}/5'),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
