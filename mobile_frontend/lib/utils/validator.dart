import 'package:flutter/material.dart';

class Validator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    // Standard email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateCompanyEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please insert email address';
    }

    // Regex for company emails with custom domains
    // Excludes common public email domains
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(?!gmail\.com|yahoo\.com|hotmail\.com|outlook\.com|protonmail\.com|icloud\.com|aol\.com|zoho\.com|mail\.com)[a-zA-Z0-9-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(value)) {
      return 'Please use your company email address';
    }

    return null;
  }

  static String? validateRegularEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please insert email address';
    }

    // Regex for common email providers (gmail, yahoo, hotmail/outlook, protonmail, icloud, etc.)
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@(gmail|yahoo|hotmail|outlook|protonmail|icloud|aol|zoho|mail)\.(com|net|org|co\.\w{2}|me|info|edu)$',
      caseSensitive: false,
    );

    if (!regex.hasMatch(value)) {
      return 'Please use a regular email provider (e.g., Gmail, Yahoo, Hotmail)';
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
