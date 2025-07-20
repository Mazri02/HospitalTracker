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
        if (mounted) {
          setState(() {
            _error = 'Location services are disabled';
            _isLocationLoading = false;
            // Fallback to Kuala Lumpur coordinates
            _currentLocation = LatLng(3.139, 101.6869);
          });
        }
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _error = 'Location permissions are denied';
              _isLocationLoading = false;
              // Fallback to Kuala Lumpur coordinates
              _currentLocation = LatLng(3.139, 101.6869);
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _error = 'Location permissions are permanently denied';
            _isLocationLoading = false;
            // Fallback to Kuala Lumpur coordinates
            _currentLocation = LatLng(3.139, 101.6869);
          });
        }
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLocationLoading = false;
        });
      }

      _updateMarkers();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to get current location: ${e.toString()}';
          _isLocationLoading = false;
          // Fallback to Kuala Lumpur coordinates
          _currentLocation = LatLng(3.139, 101.6869);
        });
      }
      _updateMarkers();
    }
  }

  Future<void> _loadHospitals() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }
      final apiClient = ApiClient();
      final hospitals = await apiClient.readAllHospital();

      if (mounted) {
        setState(() {
          _hospitals = hospitals;
          _filteredHospitals = List.from(hospitals);
          _isLoading = false;
        });
      }

      _updateMarkers();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
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

    if (mounted) {
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
    if (mounted) {
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
    }
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

  // Review submission variables
  final TextEditingController _reviewController = TextEditingController();
  final _reviewFormKey = GlobalKey<FormState>();
  int _selectedRating = 0;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _loadHospitalDetails();
    _loadUserAppointments();
  }

  //Add appointment review method
  Future<void> _loadUserAppointments() async {
    try {
      if (mounted) {
        setState(() {
          _loadingAppointments = true;
          _appointmentsError = null;
        });
      }

      final appointments = await ApiClient()
          .readAppointmentsReview(widget.hospital.hospitalID.toString());

      if (mounted) {
        setState(() {
          // Store ALL appointments for this hospital (not just ones with reviews)
          _userAppointments = appointments;
          _loadingAppointments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appointmentsError = e.toString();
          _loadingAppointments = false;
        });
      }
      debugPrint('Error loading appointments: $e');
    }
  }

  // Add method to load detailed hospital data
  Future<void> _loadHospitalDetails() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final apiClient = ApiClient();
      final detailedHospital = await apiClient.viewHospitalById(
        widget.hospital.hospitalID.toString(),
      );

      if (mounted) {
        setState(() {
          _detailedHospital = detailedHospital;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          // Fallback to the original hospital data if API call fails
          _detailedHospital = widget.hospital;
        });
      }
    }
  }

  // Review submission methods
  void _showReviewDialog() {
    int tempRating = _selectedRating;
    final tempController = TextEditingController(text: _reviewController.text);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.rate_review, color: Colors.blue),
                SizedBox(width: 8),
                Text('Submit Review'),
              ],
            ),
            content: Form(
              key: _reviewFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Star Rating Selector
                  Text(
                    'Rate your experience:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            tempRating = index + 1;
                          });
                        },
                        child: Icon(
                          index < tempRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 8),
                  Text(
                    tempRating > 0 ? '$tempRating stars' : 'Select rating',
                    style: TextStyle(
                      fontSize: 14,
                      color: tempRating > 0 ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  
                  // Review Text Field
                  TextFormField(
                    controller: tempController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Write your review*',
                      hintText: 'Share your experience with this hospital...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.edit),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please write a review';
                      }
                      if (value.trim().length < 10) {
                        return 'Review must be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetReviewForm();
                },
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: (tempRating > 0 && tempController.text.trim().length >= 10) 
                    ? () async {
                        // Update the main state
                        if (mounted) {
                          setState(() {
                            _selectedRating = tempRating;
                            _reviewController.text = tempController.text;
                          });
                        }
                        
                        // Close dialog and submit
                        Navigator.pop(context);
                        await _submitReview();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: (tempRating > 0 && tempController.text.trim().length >= 10) 
                      ? Colors.blue 
                      : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmittingReview
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text('Submit Review'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _resetReviewForm() {
    _reviewController.clear();
    _selectedRating = 0;
    if (mounted) {
      setState(() {});
    }
  }

  // Helper method to validate review form
  bool _isReviewFormValid() {
    return _selectedRating > 0 && 
           _reviewController.text.trim().length >= 10;
  }

  // Helper method to check if user has completed appointments
  bool _hasCompletedAppointments() {
    debugPrint('Checking for completed appointments in ${_userAppointments.length} appointments:');
    for (final appointment in _userAppointments) {
      debugPrint('  Appointment ${appointment.appointmentId}: status = "${appointment.status}"');
    }
    
    final hasCompleted = _userAppointments.any((appointment) {
      final status = appointment.status?.toLowerCase();
      debugPrint('  Checking status "$status" for appointment ${appointment.appointmentId}');
      // Check for various possible status values that indicate completion
      final isCompleted = status == 'accept' || 
                         status == 'accepted' || 
                         status == 'completed' || 
                         status == 'approved' ||
                         status == 'confirmed' ||
                         status == 'done' ||
                         status == 'finished';
      debugPrint('  Is completed: $isCompleted');
      return isCompleted;
    });
    
    debugPrint('Has completed appointments: $hasCompleted');
    return hasCompleted;
  }

  Future<void> _submitReview() async {
    if (!_reviewFormKey.currentState!.validate() || _selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating and write a review'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmittingReview = true;
      });
    }

    try {
      // Get the actual user ID from storage
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: 'userId');
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please login to submit reviews'),
            backgroundColor: Colors.red,
          ),
        );
        if (mounted) {
          setState(() {
            _isSubmittingReview = false;
          });
        }
        return;
      }
      
      // Get the first appointment for this hospital to submit review
      debugPrint('Looking for appointments for hospital: ${widget.hospital.hospitalID} and user: $userId');
      
      final appointments = await ApiClient().selectAppointment(
        hospitalId: widget.hospital.hospitalID.toString(),
        userId: userId,
      );

      debugPrint('Found ${appointments.length} appointments for this hospital');
      if (appointments.isNotEmpty) {
        for (int i = 0; i < appointments.length; i++) {
          debugPrint('Appointment $i: ${appointments[i].toString()}');
        }
      }

      if (appointments.isEmpty) {
        // Show dialog asking user to book appointment first
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Appointments Found'),
            content: Text(
              'You need to book an appointment with this hospital before you can submit a review. '
              'Please book an appointment first and then come back to write your review.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) {
          setState(() {
            _isSubmittingReview = false;
          });
        }
        return;
      }

      // Check if any appointments have valid status for review
      final validStatuses = ['accept', 'accepted', 'completed', 'approved', 'confirmed', 'done', 'finished'];
      final hasValidAppointments = appointments.any((appointment) {
        final status = appointment.status?.toLowerCase();
        return validStatuses.contains(status);
      });

      if (!hasValidAppointments) {
        // Show dialog explaining that only completed appointments can be reviewed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Appointment Not Ready for Review'),
            content: Text(
              'You can only submit reviews for completed appointments. '
              'Your appointment is still pending or not yet approved. '
              'Please wait for it to be accepted or completed before submitting a review.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) {
          setState(() {
            _isSubmittingReview = false;
          });
        }
        return;
      }

      // Find completed appointments (status = "Accepted", "Completed", "Approved", etc.)
      debugPrint('Checking appointment statuses:');
      for (final appointment in appointments) {
        debugPrint('  Appointment ${appointment.appointmentId}: status = "${appointment.status}"');
      }
      
      final completedAppointments = appointments.where((appointment) {
        final status = appointment.status?.toLowerCase();
        debugPrint('  Checking status "$status" for appointment ${appointment.appointmentId}');
        // Check for various possible status values that indicate completion
        return status == 'accept' || 
               status == 'accepted' || 
               status == 'completed' || 
               status == 'approved' ||
               status == 'confirmed' ||
               status == 'done' ||
               status == 'finished';
      }).toList();

      debugPrint('Found ${completedAppointments.length} completed appointments');

      if (completedAppointments.isEmpty) {
        // Show dialog explaining that only completed appointments can be reviewed
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('No Completed Appointments'),
            content: Text(
              'You can only submit reviews for completed appointments. '
              'Your appointment is still pending. Please wait for it to be accepted or completed before submitting a review.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) {
          setState(() {
            _isSubmittingReview = false;
          });
        }
        return;
      }

      // Use the first completed appointment ID
      final appointmentId = completedAppointments.first.appointmentId.toString();

      final response = await ApiClient().submitReview(
        appointmentId: appointmentId,
        reviews: _reviewController.text.trim(),
        ratings: _selectedRating.toDouble(),
      );

      // Close dialog
      Navigator.pop(context);
      _resetReviewForm();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Review submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload appointments to show new review
      await _loadUserAppointments();

    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmittingReview = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Patient Review',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_userAppointments.isEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: Colors.orange[300]!),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                                      SizedBox(width: 4),
                                      Text(
                                        'Book appointment first',
                                        style: TextStyle(
                                          color: Colors.orange[700],
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else if (_hasCompletedAppointments())
                                ElevatedButton.icon(
                                  onPressed: _showReviewDialog,
                                  icon: Icon(Icons.rate_review, size: 16),
                                  label: Text('Write Review'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                )
                              else
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                                      SizedBox(width: 4),
                                      Text(
                                        'Wait for appointment approval',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
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
                                    helperText: 'Please provide detailed information (minimum 20 characters)',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please describe your reason for visit';
                                    }
                                    if (value.trim().length < 20) {
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
      floatingActionButton: _isLoading || _userAppointments.isEmpty || !_hasCompletedAppointments()
          ? null
          : FloatingActionButton.extended(
              onPressed: _showReviewDialog,
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              icon: Icon(Icons.rate_review),
              label: Text('Write Review'),
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
        // Check if selected date is not in the past
        if (selectedDueDate.isBefore(DateTime.now())) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Invalid Date',
            desc: 'Please select a future date for your appointment',
            btnOkOnPress: () {},
          ).show();
          return;
        }

        // Check if user is authenticated
        final storage = FlutterSecureStorage();
        final token = await storage.read(key: 'token');
        
        if (token == null) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Authentication Required',
            desc: 'Please login to book appointments',
            btnOkOnPress: () {},
          ).show();
          return;
        }

        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // Use detailed hospital data if available, otherwise use the original
        final currentHospital = _detailedHospital ?? widget.hospital;
        debugPrint('Hospital ID: ${currentHospital.hospitalID}');
        debugPrint('Assign ID: ${currentHospital.assign}');
        debugPrint('Hospital Name: ${currentHospital.hospitalName}');
        debugPrint('Selected Date: ${selectedDueDate}');
        debugPrint('Reason: ${_reasonVisitController.text.trim()}');

        // Validate hospital and assign data before booking
        debugPrint('Hospital data validation:');
        debugPrint('  Hospital ID: ${currentHospital.hospitalID}');
        debugPrint('  Hospital Name: ${currentHospital.hospitalName}');
        debugPrint('  Assign ID: ${currentHospital.assign}');
        debugPrint('  Doctor Name: ${currentHospital.doctorName}');
        
        if (currentHospital.hospitalID == null) {
          throw Exception('Invalid hospital ID. Cannot book appointment.');
        }
        
        if (currentHospital.assign == null) {
          throw Exception('No doctor assigned to this hospital. Cannot book appointment.');
        }
        
        // Validate that assign ID is a valid number
        final assignId = currentHospital.assign.toString();
        if (assignId.isEmpty || assignId == 'null') {
          throw Exception('Invalid doctor assignment. Cannot book appointment.');
        }

        // Format date properly for API - ensure it's a valid future date
        final now = DateTime.now();
        final selectedDate = selectedDueDate;
        
        // Ensure the date is in the future and has a reasonable time
        final adjustedDate = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          // Set to a reasonable time (e.g., 9 AM) instead of midnight
          9, // 9 AM
          0, // 0 minutes
        );
        
        // If the adjusted date is in the past, add one day
        final finalDate = adjustedDate.isBefore(now) ? adjustedDate.add(Duration(days: 1)) : adjustedDate;
        
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(finalDate);
        
        debugPrint('Original selected date: $selectedDueDate');
        debugPrint('Adjusted date: $finalDate');
        debugPrint('Formatted date for API: $formattedDate');

        // Create appointment booking object
        final appointmentBooking = AppointmentBooking(
          hospitalId: currentHospital.hospitalID.toString(),
          assignId: currentHospital.assign.toString(),
          timeAppoint: formattedDate,
          reasonAppoint: _reasonVisitController.text.trim(),
        );

        // Call API to book appointment
        final apiClient = ApiClient();

        debugPrint('Booking request: ${appointmentBooking.toJson()}');

        final response = await apiClient.bookAppointment(booking: appointmentBooking);

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Check response status
        if (response.status == 200) {
          // Success dialog
          if (mounted) {
            AwesomeDialog(
              context: context,
              dialogType: DialogType.success,
              animType: AnimType.bottomSlide,
              title: 'Appointment Booked!',
              desc:
                  'Your appointment at ${currentHospital.hospitalName} has been scheduled for ${DateFormat('MMM dd, yyyy').format(selectedDueDate)}.',
              btnOkOnPress: () {
                // Return with success flag to trigger refresh
                if (mounted) {
                  Navigator.of(context).pop('booking_success');
                }
              },
            ).show();
          }

          // Clear form
          _reasonVisitController.clear();
          if (mounted) {
            setState(() {
              selectedDueDate = DateTime.now().add(const Duration(days: 1));
            });
          }
        } else {
          // Show error from API response
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Booking Failed',
            desc: response.message.isNotEmpty ? response.message : 'Unknown error occurred',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        // Close loading dialog if still mounted
        if (mounted) {
          Navigator.of(context).pop();
        }
        debugPrint('Booking error: ${e.toString()}');
        
        // Show error dialog with more specific messages
        String errorMessage = 'Failed to book appointment';
        if (e.toString().contains('401')) {
          errorMessage = 'Please login to book appointments';
        } else if (e.toString().contains('404')) {
          errorMessage = 'Hospital or doctor not found';
        } else if (e.toString().contains('500')) {
          errorMessage = 'Server error. Please try again later';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Request timeout. Please check your connection';
        } else {
          errorMessage = 'Failed to book appointment: ${e.toString()}';
        }
        
        if (mounted) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.bottomSlide,
            title: 'Booking Failed',
            desc: errorMessage,
            btnOkOnPress: () {},
          ).show();
        }
      }
    }
  }

  @override
  void dispose() {
    _reasonVisitController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Widget _buildAppointmentsSection() {
    if (_loadingAppointments) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_appointmentsError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            SizedBox(height: 8),
            Text(
              'No appointments found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'You need to book an appointment first to write reviews',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
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
          'Your Reviews',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (_userAppointments.isEmpty)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.rate_review, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text(
                    'No reviews yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Book an appointment and share your experience!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ..._userAppointments
              .where((appointment) => appointment.reviews != null)
              .map((appointment) => Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.rate_review, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Your Review',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Spacer(),
                              if (appointment.ratings != null)
                                Row(
                                  children: [
                                    Icon(Icons.star, size: 16, color: Colors.amber),
                                    Text(
                                      ' ${appointment.ratings!.toStringAsFixed(1)}/5',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            appointment.reviews!,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
      ],
    );
  }
}
