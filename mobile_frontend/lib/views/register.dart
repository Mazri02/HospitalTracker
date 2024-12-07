import 'package:flutter/material.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/views/login.dart';
import 'package:mobile_frontend/widget/customButton.dart';

import '../utils/validator.dart';
import '../widget/fieldbox.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
              ),
              FieldBox(
                label: 'Email',
                controller: _emailController,
                validator: Validator.validateEmailAddress,
                onChanged: (value) {},
              ),
              FieldBox(
                label: 'Password',
                controller: _passwordController,
                validator: Validator.validatePassword,
                obscureText: true,
                onChanged: (value) {},
              ),
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
              SizedBox(height: 20),
              SubmitButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process data
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Data')),
                    );

                    toNavigate.gotoLogin(context);
                  }
                },
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
