import 'package:flutter/material.dart';

import '../views/register.dart';
// import 'package:mobile_frontend/views/register.dart';

class toNavigate {
  static void gotoLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/login");
  }

  static void gotoHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/home");
  }

  static void gotoRegister(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => RegisterPage()));
  }

  //Need to update
  static void gotoProfile(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Container()));
  }
}
