import 'package:flutter/material.dart';

class toNavigate {
  static void gotoLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/login");
  }
}
