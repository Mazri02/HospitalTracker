import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/views/doctor/d_home.dart';
import 'package:mobile_frontend/widget/customButton.dart';
import 'package:mobile_frontend/widget/fieldbox.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/validator.dart';
import 'package:mobile_frontend/services/api_service.dart';
import 'package:mobile_frontend/views/users/home.dart';

enum UserRole { patient, doctor }

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  UserRole _selectedRole = UserRole.patient;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_selectedRole == UserRole.patient) {
        await _apiService.loginAsUser(
          _emailController.text,
          _passwordController.text,
          context,
        );
      } else {
        await _apiService.loginAsDoctor(
          _emailController.text,
          _passwordController.text,
          context,
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login successful')),
      );
    } catch (e) {
      // Handle different types of exceptions
      String errorMessage = 'Login failed';

      if (e is BadRequestException) {
        errorMessage = e.message;
      } else if (e is UnauthorizedException) {
        errorMessage = e.message;
      } else if (e is ServerException) {
        errorMessage = e.message;
      } else if (e is FormatException) {
        errorMessage = 'Data format error';
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Form(
              key: _formKey,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 150, 53, 220),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          width: 300,
                          image: AssetImage('assets/images/hospital-logo.png'),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    // Role Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Login as:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<UserRole>(
                                    title: Text(
                                      'Patient',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: UserRole.patient,
                                    groupValue: _selectedRole,
                                    onChanged: (UserRole? value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                    activeColor: Colors.white,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<UserRole>(
                                    title: Text(
                                      'Doctor',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    value: UserRole.doctor,
                                    groupValue: _selectedRole,
                                    onChanged: (UserRole? value) {
                                      setState(() {
                                        _selectedRole = value!;
                                      });
                                    },
                                    activeColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    FieldBox(
                      label: 'Email',
                      controller: _emailController,
                      validator: Validator.validateEmail,
                      onChanged: (value) {},
                      textCapitalization: TextCapitalization.none,
                    ),
                    SizedBox(height: 20),
                    FieldBox(
                      label: 'Password',
                      controller: _passwordController,
                      validator: Validator.validatePassword,
                      obscureText: true,
                      onChanged: (value) {},
                    ),
                    SizedBox(height: 40),
                    _isLoading
                        ? CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : SubmitButton(
                            onPressed: _login,
                            text:
                                'Login as ${_selectedRole == UserRole.patient ? "Patient" : "Doctor"}',
                            color: Colors.deepPurple,
                          ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: NextButton(
                        valueColor: 0xFF637AB7,
                        routeName: '/register',
                        nameButton: 'Register',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
