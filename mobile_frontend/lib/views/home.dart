import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/views/about/about.dart';
import 'package:mobile_frontend/views/mapsInsert.dart';
import 'package:mobile_frontend/views/profile.dart';
import 'package:mobile_frontend/widget/adbox.dart';
import 'package:mobile_frontend/widget/balancedgridmenu.dart';
import 'package:mobile_frontend/widget/largelisttile.dart';
import '../controller/service.dart';
import '../widget/yes_no_dialog.dart';
// import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String latitude = "Fetching...";
  String longitude = "Fetching...";
  String address = "Fetching address...";
  final LocationService _locationService = LocationService();

  late final token;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<Widget> GetHospital() async {
    final csrf = await http.get(Uri.parse('http://localhost:8000/csrf-token'));
    final WidgetBuilder nextScreens;

    if (csrf.statusCode == 200) {
      final data = json.decode(csrf.body);
      token = data['csrf_token'];
    } else {
      throw Exception('Failed to load CSRF token');
    }

    final res = await http.post(
      Uri.parse('http://localhost:8000/api/ViewAllLocation'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'X-CSRF-TOKEN': token,
      },
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      List<Widget> widgets = [];

      for (int i = 0; i < data.length; i++) {
        widgets.add(
          LargeListTile(
            leading: Icon(Icons.location_city),
            title: Text(data[i]["HospitalAddress"]),
            subtitle: Text('Hospital Name: ' + data[i]["HospitalName"] + ''),
            overline: Text('Latitude: ' +
                data[i]["HospitalLang"].toString() +
                ', Longitude: ' +
                data[i]["HospitalLong"].toString() +
                ''),
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
            backgroundColor: Color.fromARGB(255, 255, 220, 180),
          ),
        );
      }

      return Column(children: widgets);
    } else {
      return Center(child: Text("No data available"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        backgroundColor: const Color.fromARGB(255, 249, 244, 236),
        elevation: 0.0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(50),
            topLeft: Radius.zero,
            topRight: Radius.zero,
          ),
          child: Container(
            color: const Color.fromARGB(255, 150, 53, 220),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome {Username},",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Gap(10),
                  Text(
                    "Hospital Tracker Application",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdBox(
                height: 200,
                width: MediaQuery.of(context).size.width,
                // height: 200,
                // width: 450,
              ),
              Gap(40),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Color.fromARGB(255, 255, 220, 180),
                ),
                child: BalancedGridView(
                  columnCount: 4,
                  children: [
                    MenuCardSmallTile(
                      imageLink: 'assets/icons/profile.png',
                      label: 'Profile',
                      nextScreen: (context) => ProfilePage(),
                    ),
                    MenuCardSmallTile(
                      imageLink: 'assets/icons/mapinsert.png',
                      label: 'Maps Insert',
                      nextScreen: (context) => MapsForm(edit: true),
                    ),
                    MenuCardSmallTile(
                      imageLink: 'assets/icons/aboutproject.png',
                      label: 'About',
                      nextScreen: (context) => AboutPage(),
                    ),
                    MenuCardSmallTile(
                      imageLink: 'assets/icons/logout.png',
                      label: 'Logout',
                      nextScreen: (context) => Container(),
                      logout: true,
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
                  style: TextStyle(fontSize: 12),
                ),
                bottom: Text(
                  'Address: $address',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 150, 53, 220),
                  child: IconButton(
                    color: Colors.white,
                    onPressed: () async {
                      await _fetchLocation(); // Ensure it's awaited
                      setState(() {}); // Refresh UI if needed
                    },
                    icon: const Icon(Icons.gps_fixed),
                  ),
                ),
                backgroundColor: Color.fromARGB(255, 255, 220, 180),
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
                      return CircularProgressIndicator(); // While waiting for the future to complete
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // If there is an error
                    } else {
                      return snapshot.data!; // Display the resulting widget
                    }
                  })
            ],
          ),
        ),
      ),
    );
  }

// // Nak dapatkan location address.
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
    required this.nextScreen,
    this.logout = false,
    this.backgroundColor = Colors.transparent,
  }) : super(key: key);

  final String imageLink;
  final String label;
  final WidgetBuilder nextScreen;
  final Color? backgroundColor;
  final bool? logout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: () async {
          if (logout == true) {
            final continueLogout = await showYesNoDialog(
              context: context,
              title: 'Log out',
              message: 'Are you sure you want to logout?',
            );
            if (continueLogout == true) {
              // await auth.signOut(context);
              toNavigate.gotoLogin(context);
            }
          } else {
            Navigator.push(context, MaterialPageRoute(builder: nextScreen));
          }
        },
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
