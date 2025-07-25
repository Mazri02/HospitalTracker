import 'package:flutter/material.dart';
import 'package:mobile_frontend/views/about/about.dart';
import 'package:mobile_frontend/views/doctor/d_home.dart';
import 'package:mobile_frontend/views/doctor/mapsInsert.dart';
import 'package:mobile_frontend/views/users/home.dart';
import 'package:mobile_frontend/views/users/maps.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mobile_frontend/views/users/news.dart';
import 'package:provider/provider.dart';
// import 'package:mobile_frontend/views/register.dart';

import 'views/authentication/login.dart';
import 'views/authentication/register.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => NewsController()),
        ],
        child: LoginPage(),
      ),
      initialRoute: '/',
      routes: {
        //login
        '/login': (context) => LoginPage(),

        //register
        '/register': (context) => RegisterPage(),

        //main screen
        '/home': (context) => HomeScreen(userData: {}),
        '/dhome': (context) => DHomeScreen(userData: {}),

        //news
        '/news': (context) => News(),

        //maps
        '/maps': (context) => MapsForm(),
        '/hospitalmaps': (context) => HospitalMapsScreen(),

        //about
        '/about': (context) => AboutPage(),
      },
    );
  }
}
