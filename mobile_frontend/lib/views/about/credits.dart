import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Credits extends StatefulWidget {
  const Credits({super.key});

  @override
  State<Credits> createState() => _CreditsState();
}

class _CreditsState extends State<Credits> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        title: const Text(
          "Credits",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: const Center(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Our Foundation: ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Image(
                  image: AssetImage('assets/images/uitm-logo.png'),
                  height: 200,
                  width: 250,
                ),
                Text(
                  'Our Supervisor: ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Gap(10),
                Image(
                  image: AssetImage('assets/images/sir.png'),
                  height: 200,
                  width: 250,
                ),
                Text('Shahadan bin Saad'),
                Gap(30),
                Text(
                  'Our Developers: ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Gap(10),
                Image(
                  image: AssetImage('assets/images/azri.jpg'),
                  height: 200,
                  width: 250,
                ),
                Text('Muhammad Azri bin Mokhzani'),
                Text('M3CDCS2515C'),
                Text('2023444886'),
                Gap(30),
                Image(
                  image: AssetImage('assets/images/isk.png'),
                  height: 200,
                  width: 250,
                ),
                Gap(10),
                Text('Muhammad Alif Iskandar bin Mad Sihad'),
                Text('M3CDCS2515C'),
                Text('2023479398'),
                Gap(30),
                Image(
                  image: AssetImage('assets/images/raziq.png'),
                  height: 200,
                  width: 250,
                ),
                Gap(10),
                Text('Ahmad Raziq bin Roslil Khitam'),
                Text('M3CDCS2515C'),
                Text('2023680042'),
                Gap(30),
                Image(
                  image: AssetImage('assets/images/pian.png'),
                  height: 200,
                  width: 250,
                ),
                Gap(10),
                Text('Muhd Suffian Bin Mahathir'),
                Text('M3CDCS2515C'),
                Text('2023473736'),
                Gap(10),
                Text(
                  'Credits, Our Repository and Learn More Project: https://github.com/Mazri02/HospitalTracker ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
