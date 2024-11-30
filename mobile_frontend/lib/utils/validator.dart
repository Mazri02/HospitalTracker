import 'package:flutter/material.dart';

class Validator {
  static String? validateEmailAddress(String? value) {
    final context = GlobalKey<NavigatorState>().currentContext;
    if (value == null || value.isEmpty) {
      return 'Please insert email address';
    }
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(value)) {
      return 'Please follow email format ex: abc@gmail.com';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    final context = GlobalKey<NavigatorState>().currentContext;
    if (value == null || value.isEmpty) {
      return 'Please insert the password here';
    }
    if (value.length < 8) {
      return 'Please put the password length in 8 characters';
    }
    return null;
  }

  static String? validateText(String? value) {
    final context = GlobalKey<NavigatorState>().currentContext;
    if (value == null || value.isEmpty) {
      return 'The text is empty, please fill it'; // error message for empty field
    }
    return null; // return null for valid input
  }
}
