import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/widget/customButton.dart';
import 'package:mobile_frontend/widget/fieldbox.dart';
import '../../utils/validator.dart';
import 'package:mobile_frontend/services/api_service.dart';

enum UserRole { patient, doctor }

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
  UserRole _selectedRole = UserRole.patient;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<String?> _convertImageToBase64() async {
    if (_selectedImage == null) return null;

    try {
      final bytes = await _selectedImage!.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response;

      if (_selectedRole == UserRole.patient) {
        response = await _apiService.registerUser(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        // Convert image to base64 if selected
        String? imageBase64;
        if (_selectedImage != null) {
          imageBase64 = await _convertImageToBase64();
        }

        response = await _apiService.registerDoctor(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          doctorImage: imageBase64,
        );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Registration successful'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to login
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      // Handle different types of exceptions
      String errorMessage = 'Registration failed';

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
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        foregroundColor: Colors.white,
      ),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Role Selection
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Register as:',
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
                                        _selectedImage =
                                            null; // Clear image when switching roles
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

                      SizedBox(height: 30),

                      // Doctor Image Upload (only for doctors)
                      if (_selectedRole == UserRole.doctor) ...[
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(60),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(58),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],

                      FieldBox(
                        label: 'Full Name',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                        onChanged: (value) {},
                        textCapitalization: TextCapitalization.words,
                      ),
                      SizedBox(height: 20),
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
                      SizedBox(height: 20),
                      FieldBox(
                        label: 'Confirm Password',
                        controller: _confirmPasswordController,
                        validator: _validateConfirmPassword,
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
                              onPressed: _register,
                              text:
                                  'Register as ${_selectedRole == UserRole.patient ? "Patient" : "Doctor"}',
                              color: Colors.deepPurple,
                            ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: Text(
                          'Already have an account? Login here',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
