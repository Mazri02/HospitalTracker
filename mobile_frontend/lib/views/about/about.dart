import 'package:flutter/material.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/widget/largelisttile.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            LargeListTile(
              title: Text('Acknowledgement'),
              subtitle: Text('Credits to our partnership'),
              onTap: () {
                toNavigate.gotoAcknowledgement(context);
              },
            ),
            LargeListTile(
              title: Text('Credits'),
              subtitle: Text('Credits to our developer'),
              onTap: () {
                toNavigate.gotoCredits(context);
              },
            ),
            LargeListTile(
              title: Text('Terms and Service'),
              subtitle: Text('Read our terms and service'),
              onTap: () {
                toNavigate.gotoTermsAndService(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
