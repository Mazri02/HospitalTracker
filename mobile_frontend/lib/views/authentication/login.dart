import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/widget/customButton.dart';
import 'package:mobile_frontend/widget/fieldbox.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/validator.dart';
import 'package:mobile_frontend/services/api_service.dart';
import 'package:mobile_frontend/views/users/home.dart';

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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response['status'] == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Login successful')),
        );

        // Navigate to home screen with user data
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userData: response['data'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Login failed')),
        );
      }
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                    SizedBox(height: 40),
                    FieldBox(
                      label: 'Email',
                      controller: _emailController,
                      validator: Validator.validateEmail,
                      onChanged: (value) {},
                      textCapitalization: TextCapitalization.none,

                      //IF IN MOBILE THAN USE THIS
                      // keyboardType: TextInputType.emailAddress,
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
                        ? CircularProgressIndicator()
                        : SubmitButton(
                            onPressed: _login,
                            text: 'Login',
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
}
