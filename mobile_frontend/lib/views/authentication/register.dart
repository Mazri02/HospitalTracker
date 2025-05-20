import 'package:flutter/material.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/widget/customButton.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_frontend/widget/customchoicechip.dart';
import 'dart:convert';
import '../../utils/validator.dart';
import '../../widget/fieldbox.dart';
import 'package:mobile_frontend/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  String? rolesType = 'Users';

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _apiService.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Registration successful')),
        );
        toNavigate.gotoLogin(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Registration failed')),
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
      appBar: AppBar(
        title: Text('Register New Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              FieldBox(
                label: 'Name',
                controller: _nameController,
                validator: Validator.validateText,
                onChanged: (value) {},
                textCapitalization: TextCapitalization.words,
              ),
              SizedBox(height: 20),
              FieldBox(
                label: 'Email',
                controller: _emailController,
                validator: rolesType == 'Users'
                    ? Validator.validateRegularEmail
                    : Validator.validateCompanyEmail,
                onChanged: (value) {},
                textCapitalization: TextCapitalization.none,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20),
              FieldBox(
                label: 'Password',
                controller: _passwordController,
                validator: Validator.validatePassword,
                obscureText: true,
                onChanged: (value) {},
              ),
              SizedBox(height: 20),
              FieldBox(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                obscureText: true,
                onChanged: (value) {},
              ),
              CustomSelectedChoiceChip(
                  items: ['Users', 'Doctor'],
                  onChanged: (value) {
                    setState(() {
                      rolesType = value ?? 'Users';
                    });
                    print('Selected: $value');
                  },
                  title: 'Are you?',
                  types: ['Users', 'Doctor']),
              SizedBox(height: 40),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SubmitButton(
                      onPressed: _register,
                      text: 'Register',
                      color: Colors.purple,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
