import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile_frontend/controller/api_client_http.dart';
import 'package:mobile_frontend/services/api_service.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/views/about/about.dart';
import 'package:mobile_frontend/views/users/profile.dart';
import 'package:mobile_frontend/views/users/maps.dart';
import 'package:mobile_frontend/model/hospital_model.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../controller/service.dart';
import '../../widget/yes_no_dialog.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const HomeScreen({
    super.key,
    required this.userData,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String latitude = "Fetching...";
  String longitude = "Fetching...";
  String address = "Fetching address...";
  final LocationService _locationService = LocationService();
  final ApiClient _apiClient = ApiClient();

  List<Hospital> _hospitals = [];
  bool _isLoadingHospitals = true;
  String? _error;

  // Current location for hospital details navigation
  LatLng? _currentLocation;

  // Appointment status tracking
  Map<String, String> _appointmentStatuses = {};
  bool _isLoadingAppointments = false;

  // Carousel images using existing assets
  final List<String> _carouselImages = [
    'assets/images/hospital-logo.png',
    'assets/images/doctor.jpeg',
    'assets/images/uitm.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchLocation(),
      _loadHospitals(),
    ]);
    
    // Load appointment statuses after hospitals are loaded
    await _loadAppointmentStatuses();
  }

  Future<void> _loadHospitals() async {
    try {
      setState(() {
        _isLoadingHospitals = true;
        _error = null;
      });

      final hospitals = await _apiClient.readAllHospital();
      
      // Debug: Check if hospitals have doctor data
      if (hospitals.isNotEmpty) {
        final firstHospital = hospitals.first;
        debugPrint('First hospital from API:');
        debugPrint('  Hospital ID: ${firstHospital.hospitalID}');
        debugPrint('  Hospital Name: ${firstHospital.hospitalName}');
        debugPrint('  Doctor Name: ${firstHospital.doctorName}');
        debugPrint('  Doctor ID: ${firstHospital.doctorID}');
        debugPrint('  Assign ID: ${firstHospital.assign}');
      }

      setState(() {
        _hospitals = hospitals;
        _isLoadingHospitals = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingHospitals = false;
      });
    }
  }

  Future<void> _loadAppointmentStatuses() async {
    if (_hospitals.isEmpty) return;

    setState(() {
      _isLoadingAppointments = true;
    });

    try {
      // Get user ID from secure storage
      final storage = FlutterSecureStorage();
      final userId = await storage.read(key: 'userId');
      
      debugPrint('Loading appointment statuses for user ID: $userId');
      
      if (userId == null) {
        debugPrint('No user ID found, skipping appointment status loading');
        setState(() {
          _isLoadingAppointments = false;
        });
        return;
      }

      // Also try getting user ID from widget data as fallback
      final widgetUserId = widget.userData['UserID']?.toString();
      debugPrint('Widget user ID: $widgetUserId');
      
      // Use widget user ID if storage user ID is null
      final finalUserId = userId ?? widgetUserId;
      if (finalUserId == null) {
        debugPrint('No user ID available from any source');
        setState(() {
          _isLoadingAppointments = false;
        });
        return;
      }

      // Load appointment statuses for each hospital
      Map<String, String> statuses = {};
      
      for (final hospital in _hospitals) {
        try {
          final appointments = await _apiClient.selectAppointment(
            hospitalId: hospital.hospitalID.toString(),
            userId: finalUserId,
          );
          
          debugPrint('Hospital ${hospital.hospitalID}: Found ${appointments.length} appointments');
          
          if (appointments.isNotEmpty) {
            // Get the most recent appointment status
            final latestAppointment = appointments.first;
            final status = latestAppointment.status;
            statuses[hospital.hospitalID.toString()] = status;
            debugPrint('Hospital ${hospital.hospitalID}: Status = ${status}');
            debugPrint('Hospital ${hospital.hospitalID}: Full appointment data = ${latestAppointment.toString()}');
          }
        } catch (e) {
          // If there's an error loading appointments for this hospital, skip it
          debugPrint('Error loading appointments for hospital ${hospital.hospitalID}: $e');
        }
      }

      setState(() {
        _appointmentStatuses = statuses;
        _isLoadingAppointments = false;
      });
    } catch (e) {
      debugPrint('Error loading appointment statuses: $e');
      setState(() {
        _isLoadingAppointments = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final continueLogout = await showYesNoDialog(
      context: context,
      title: 'Log out',
      message: 'Are you sure you want to logout?',
    );

    final apiService = ApiService();

    if (continueLogout == true) {
      try {
        await apiService.logout(context);
        debugPrint('login success');
      } catch (e) {
        debugPrint('Logout failed: $e');
      }
      toNavigate.gotoLogin(context);
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
    ).then((result) {
      // Handle return value from hospital details page
      if (result == 'booking_success') {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment booked successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Immediately update the status for this specific hospital
        setState(() {
          _appointmentStatuses[hospital.hospitalID.toString()] = 'pending';
        });
        
        debugPrint('Updated appointment status for hospital ${hospital.hospitalID}: pending');
        
        // Also refresh all appointment statuses in background with a small delay
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            _loadAppointmentStatuses();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      body: Column(
        children: [
          // Main content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadHospitals();
                await _loadAppointmentStatuses();
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Banner
                    _buildWelcomeBanner(screenSize),

                    Gap(20),

                    // Carousel for Ads/News
                    _buildCarousel(),

                    Gap(20),

                    // Current Location Section
                    _buildCurrentLocation(),

                    Gap(20),

                                      // Hospital List
                  _buildHospitalList(),

                  // Debug: Force refresh button (remove in production)
                  if (_isLoadingAppointments)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'Loading appointment statuses...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  
                  // Debug: Force refresh button for testing
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          debugPrint('Force refreshing appointment statuses...');
                          _loadAppointmentStatuses();
                        },
                        child: Text('Refresh Appointment Statuses'),
                      ),
                    ),
                  ),

                  // Add bottom padding for sticky navigation
                  Gap(100),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Sticky Navigation
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWelcomeBanner(Size screenSize) {
    return Container(
      width: screenSize.width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 150, 53, 220),
            const Color.fromARGB(255, 120, 43, 190),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome to Hospital Tracker!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(4),
                      Text(
                        "Hello, ${widget.userData['UserName'] ?? 'User'}",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Gap(4),
                      Text(
                        "Find and explore nearby hospitals",
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _handleLogout,
                  icon: Icon(
                    Icons.logout,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Health News & Updates",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Gap(12),
          CarouselSlider(
            options: CarouselOptions(
              height: 180,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 4),
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items: _carouselImages.map((imagePath) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.image,
                                      size: 50, color: Colors.grey[600]),
                                  Text('Health News',
                                      style:
                                          TextStyle(color: Colors.grey[600])),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentLocation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Current Location",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Gap(12),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 220, 180),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red, size: 30),
                Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Coordinates: $latitude, $longitude',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Gap(4),
                      Text(
                        'Address: $address',
                        style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 150, 53, 220),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () async {
                      await _fetchLocation();
                      setState(() {});
                    },
                    icon: const Icon(Icons.gps_fixed),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nearby Hospitals",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Gap(12),
          if (_isLoadingHospitals)
            Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text('Error: $_error'))
          else if (_hospitals.isEmpty)
            Center(child: Text('No hospitals found'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _hospitals.length,
              itemBuilder: (context, index) {
                return _buildHospitalCard(_hospitals[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(Hospital hospital) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHospitalDetails(hospital),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Hospital Picture (circular)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 150, 53, 220),
                        Color.fromARGB(255, 120, 43, 190),
                      ],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.transparent,
                    backgroundImage:
                        AssetImage('assets/images/hospital-logo.png'),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: hospital.hospitalName != null
                        ? null
                        : Icon(Icons.local_hospital, color: Colors.white, size: 24),
                  ),
                ),

                Gap(16),

                // Hospital Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hospital Name
                      Text(
                        hospital.hospitalName ?? 'Unknown Hospital',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(2),
                      // Doctor Name
                      Text(
                        'Dr. ${hospital.doctorName ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      Gap(6),
                      // Address
                      Text(
                        hospital.hospitalAddress ?? 'Address not available',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Gap(4),
                      // Rating and Reviews
                      if (hospital.ratings != null) ...[
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 14),
                            Gap(2),
                            Text(
                              '${hospital.ratings!.toStringAsFixed(1)}',
                              style: TextStyle(
                                fontSize: 11, 
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Gap(4),
                            Text(
                              '(${hospital.totalReviews ?? 0} reviews)',
                              style: TextStyle(
                                fontSize: 10, 
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                Gap(12),

                // Appointment Button
                _buildAppointmentButton(hospital),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.person,
            label: 'Profile',
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilePage(userData: widget.userData),
                ),
              );
              if (result != null && mounted) {
                setState(() {
                  widget.userData['UserName'] = result['UserName'];
                  widget.userData['UserEmail'] = result['UserEmail'];
                });
              }
            },
          ),
          _buildNavItem(
            icon: Icons.map,
            label: 'Maps',
            onTap: () => Navigator.pushNamed(context, '/hospitalmaps'),
          ),
          _buildNavItem(
            icon: Icons.info,
            label: 'About',
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
          _buildNavItem(
            icon: Icons.logout,
            label: 'Logout',
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color.fromARGB(255, 150, 53, 220), size: 24),
            Gap(4),
            Text(
              label,
              style: TextStyle(
                color: Color.fromARGB(255, 150, 53, 220),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentButton(Hospital hospital) {
    final hospitalId = hospital.hospitalID.toString();
    final appointmentStatus = _appointmentStatuses[hospitalId];
    
    debugPrint('Building button for hospital $hospitalId: status = $appointmentStatus');
    debugPrint('All appointment statuses: $_appointmentStatuses');
    
    if (_isLoadingAppointments) {
      return SizedBox(
        width: 60,
        height: 30,
        child: Center(
          child: SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ),
      );
    }

    if (appointmentStatus != null) {
      // User has an appointment - show status
      Color buttonColor;
      String buttonText;
      
      switch (appointmentStatus.toLowerCase()) {
        case 'pending':
        case 'pending':
          buttonColor = Colors.orange;
          buttonText = 'PENDING';
          break;
        case 'accept':
        case 'accepted':
        case 'approved':
          buttonColor = Colors.green;
          buttonText = 'ACCEPTED';
          break;
        case 'reject':
        case 'rejected':
        case 'declined':
          buttonColor = Colors.red;
          buttonText = 'REJECTED';
          break;
        case 'booked':
        case 'confirmed':
          buttonColor = Colors.blue;
          buttonText = 'BOOKED';
          break;
        default:
          buttonColor = Colors.grey;
          buttonText = appointmentStatus.toUpperCase();
          debugPrint('Unknown appointment status: $appointmentStatus');
      }

      return Container(
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showHospitalDetails(hospital),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      // No appointment - show book now button
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 150, 53, 220),
              Color.fromARGB(255, 120, 43, 190),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(255, 150, 53, 220).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showHospitalDetails(hospital),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'BOOK NOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _fetchLocation() async {
    try {
      print("Fetching location...");
      Position position = await _locationService.getCurrentPosition();
      print("Position: $position");
      String addr = await _locationService.getAddressFromLatLng(
          position.latitude, position.longitude);
      print("Address: $addr");

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        address = addr;
        // Set LatLng current location for hospital details navigation
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        address = e.toString();
        // Fallback to Kuala Lumpur coordinates if location fetch fails
        _currentLocation = LatLng(3.139, 101.6869);
      });
    }
  }
}
