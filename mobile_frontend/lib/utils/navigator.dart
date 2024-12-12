import 'package:flutter/material.dart';
import 'package:mobile_frontend/views/about/acknowledgement.dart';

import '../views/about/credits.dart';
import '../views/about/termsAndService.dart';
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

  static void gotoAcknowledgement(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Acknowledgement()));
  }

  static void gotoCredits(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Credits()));
  }

  static void gotoTermsAndService(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TermsAndService()));
  }

  //Need to update
  static void gotoProfile(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Container()));
  }
}
