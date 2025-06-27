import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_frontend/services/api_service.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/views/doctor/mapsInsert.dart';
import 'package:mobile_frontend/views/users/profile.dart';
import 'package:mobile_frontend/widget/adbox.dart';
import 'package:mobile_frontend/widget/balancedgridmenu.dart';
import 'package:mobile_frontend/widget/largelisttile.dart';
import '../../controller/service.dart';
import '../../widget/yes_no_dialog.dart';
import 'package:dio/dio.dart';

class DHomeScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const DHomeScreen({
    super.key,
    required this.userData,
  });

  @override
  State<DHomeScreen> createState() => _DHomeScreenState();
}

class _DHomeScreenState extends State<DHomeScreen> {
  String latitude = "Fetching...";
  String longitude = "Fetching...";
  String address = "Fetching address...";
  final LocationService _locationService = LocationService();
  final ipAddress = dotenv.env['BASE_URL']; // Tukar IP Sendiri Time Present

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<Widget> GetHospital() async {
    final response = await Dio().get(
      '$ipAddress/csrf-token',
      options: Options(headers: {
        'withCredentials': 'true',
      }),
    );

    var token;

    if (response.statusCode == 200) {
      var data = response.data;
      token = data['csrf_token'];
    } else {
      throw Exception('Failed to load CSRF token');
    }

    final res = await Dio().get(
      '$ipAddress/api/ViewAllLocation',
      options: Options(headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-TOKEN': token,
        'Accept': 'application/json',
      }),
    );

    if (res.statusCode == 200) {
      final data = res.data;
      List<Widget> widgets = [];

      for (int i = 0; i < data.length; i++) {
        widgets.add(
          LargeListTile(
            leading: const Icon(Icons.location_city),
            title: Text(data[i]["HospitalAddress"]),
            subtitle: Text('Hospital Name: ' + data[i]["HospitalName"]),
            overline: Text('Latitude: ' +
                data[i]["HospitalLang"].toString() +
                ', Longitude: ' +
                data[i]["HospitalLong"].toString()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return MapsForm(
                      hospitalLang: data[i]["HospitalLang"],
                      hospitalID: data[i]["LocationID"],
                      hospitalLong: data[i]["HospitalLong"],
                      hospitalAddress: data[i]["HospitalAddress"],
                      hospitalName: data[i]["HospitalName"],
                      edit: false,
                    );
                  },
                ),
              );
            },
            backgroundColor: const Color.fromARGB(255, 255, 220, 180),
          ),
        );
      }

      return Column(children: widgets);
    } else {
      return const Center(child: Text("No data available"));
    }
  }

  Future<void> _handleLogout() async {
    final continueLogout = await showYesNoDialog(
      context: context,
      title: 'Log out',
      message: 'Are you sure you want to logout?',
    );

    if (continueLogout == true) {
      final apiService = ApiService();
      try {
        // await apiService.logout(userId, context);
      } catch (e) {
        // Handle error
        print('Logout failed: $e');
      }
      // Use the navigation utility instead
      toNavigate.gotoLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Container(
                width: screenSize.width,
                height: screenSize.height * 0.20,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 150, 53, 220),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: LargeListTile(
                    title: const Text(
                      "Welcome Doctor!,",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      "HOSPITAL TRACKER APPLICATION,",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                    bottom: Text(
                      "HELLO, ${widget.userData['UserName'] ?? 'User'}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: _handleLogout,
                      icon: const Icon(Icons.logout),
                    ),
                  ),
                ),
              ),
            ]),
            const Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdBox(
                    height: 200,
                    width: screenSize.width,
                    // height: 200,
                    // width: 450,
                  ),
                  const Gap(40),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 255, 220, 180),
                    ),
                    child: BalancedGridView(
                      columnCount: 4,
                      children: [
                        MenuCardSmallTile(
                          imageLink: 'assets/icons/profile.png',
                          label: 'Profile',
                          builder: (context) =>
                              ProfilePage(userData: widget.userData),
                          onTap: () async {
                            // Wait for result from ProfilePage
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProfilePage(userData: widget.userData),
                              ),
                            );

                            // Update userData if profile was edited
                            if (result != null && mounted) {
                              setState(() {
                                widget.userData['UserName'] =
                                    result['UserName'];
                                widget.userData['UserEmail'] =
                                    result['UserEmail'];
                              });
                            }
                          },
                        ),
                        MenuCardSmallTile(
                          imageLink: 'assets/icons/mapinsert.png',
                          label: 'Maps Insert',
                          builder: (context) => const MapsForm(edit: true),
                          onTap: () {
                            Navigator.pushNamed(context, '/maps');
                          },
                        ),
                        MenuCardSmallTile(
                          imageLink: 'assets/icons/aboutproject.png',
                          label: 'About',
                          onTap: () {
                            Navigator.pushNamed(context, '/about');
                          },
                        ),
                        MenuCardSmallTile(
                          imageLink: 'assets/icons/logout.png',
                          label: 'Logout',
                          builder: (context) => Container(),
                          onTap: _handleLogout,
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),
                  const Text(
                    "Your Current Location: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                  ),
                  const Gap(20),
                  LargeListTile(
                    leading: const Icon(Icons.map),
                    title: const Text('Your Location'),
                    subtitle: Text(
                      'Latitude: $latitude , Longitude: $longitude',
                      style: const TextStyle(fontSize: 12),
                    ),
                    bottom: Text(
                      'Address: $address',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 150, 53, 220),
                      child: IconButton(
                        color: Colors.white,
                        onPressed: () async {
                          await _fetchLocation(); // Ensure it's awaited
                          setState(() {}); // Refresh UI if needed
                        },
                        icon: const Icon(Icons.gps_fixed),
                      ),
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 220, 180),
                  ),
                  const Gap(20),
                  const Text(
                    "Hospital Nearby List: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
                  ),
                  const Gap(20),
                  FutureBuilder(
                    future: GetHospital(),
                    builder: (BuildContext ctx, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator(); // While waiting for the future to complete
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // If there is an error
                      } else {
                        return snapshot.data!; // Display the resulting widget
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      });
    } catch (e) {
      print("Error fetching location: $e");
      setState(() {
        address = e.toString();
      });
    }
  }
}

class MenuCardSmallTile extends StatelessWidget {
  const MenuCardSmallTile({
    Key? key,
    required this.imageLink,
    required this.label,
    this.builder,
    this.onTap,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final String imageLink;
  final String label;
  final WidgetBuilder? builder;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(imageLink),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: textTheme.labelMedium!.copyWith(
                  color: Colors.blue[900],
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
