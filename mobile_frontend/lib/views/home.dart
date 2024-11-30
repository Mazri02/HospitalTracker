import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_frontend/widget/balancedgridmenu.dart';
import 'package:mobile_frontend/widget/largelisttile.dart';

import '../widget/yes_no_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("Welcome {User}, to the Hospital Tracker"),
              const Gap(20),
              LargeListTile(
                leading: const Icon(Icons.map),
                title: const Text('Your Location'),
                subtitle: const Text('Location Name: {location}'),
                overline:
                    const Text('Latitude: {latitude}, Longitude: {longitude}'),
                onTap: () async {
                  // aku nak isi permission ability dari smartphone untuk cari longitude latitude.
                  setState(() {});
                },
              ),
              const Gap(20),
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
