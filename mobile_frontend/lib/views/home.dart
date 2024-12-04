import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/utils/permission.dart';
import 'package:mobile_frontend/widget/balancedgridmenu.dart';
import 'package:mobile_frontend/widget/largelisttile.dart';

import '../widget/yes_no_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Permission permission = Permission();
  String locationMessage = 'Location not fetched yet';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 250, 245),
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.12,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        flexibleSpace: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(50),
            topLeft: Radius.zero,
            topRight: Radius.zero,
          ),
          child: Container(
            color: const Color.fromARGB(255, 221, 199, 237),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Muhammad Alif Iskandar,",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Gap(10),
                  Text(
                    "Hospital Tracker Application",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
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
              BalancedGridView(
                columnCount: 3,
                children: [
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/profile.png',
                    label: 'Profile',
                    nextScreen: (context) => Container(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/profile.png',
                    label: 'Maps Insert',
                    nextScreen: (context) => Container(),
                  ),
                  MenuCardSmallTile(
                    imageLink: 'assets/icons/logout.png',
                    label: 'Logout',
                    nextScreen: (context) => Container(),
                    logout: true,
                  ),
                ],
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
                subtitle: const Text('Location Name: {location}'),
                overline: Text(locationMessage),
                trailing: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 221, 199, 237),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _checkLocationPermission();
                      });
                    },
                    icon: const Icon(Icons.gps_fixed),
                  ),
                ),
              ),
              const Gap(20),
              const Text(
                "Hospital Nearby List: ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
              ),
              const Gap(20),
              LargeListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Hospital Location'),
                subtitle: const Text('Hospital Name: {location}'),
                overline:
                    const Text('Latitude: {latitude}, Longitude: {longitude}'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkLocationPermission() async {
    bool hasPermission = await permission.requestPermission();

    if (hasPermission) {
      var locationData = await permission.getLocation();
      if (locationData == null) {
        setState(() {
          locationMessage =
              'Latitude: ${locationData?.latitude}, Longitude: ${locationData?.longitude}';
        });
      } else {
        setState(() {
          locationMessage = 'Unable to fetch location.';
        });
      }
    } else {
      setState(
        () {
          locationMessage = 'Location permission denied.';
        },
      );
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
