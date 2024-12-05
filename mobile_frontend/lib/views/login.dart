import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mobile_frontend/utils/navigator.dart';
import 'package:mobile_frontend/widget/customButton.dart';
import 'package:mobile_frontend/widget/fieldbox.dart';

import '../utils/validator.dart'; // Import the register page

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: const Color.fromARGB(255, 150, 53, 220),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image(
                  width: 300,
                  image: AssetImage('assets/images/hospital-logo.png'),
                ),
              ),
              Gap(20),
              FieldBox(
                label: 'Email',
                validator: Validator.validateEmailAddress,
                onChanged: (value) {},
              ),
              Gap(20),
              FieldBox(
                label: 'Password',
                validator: Validator.validatePassword,
                obscureText: true,
                onChanged: (value) {},
              ),
              Gap(40),
              SubmitButton(
                onPressed: () {
                  toNavigate.gotoHome(context);
                },
                text: 'Login',
                color: Colors.deepPurple,
              ),
              Gap(20),
              NextButton(
                valueColor: 0xFF637AB7,
                routeName: '/register',
                nameButton: 'Register',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
