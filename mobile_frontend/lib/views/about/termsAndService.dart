import 'package:flutter/material.dart';

class TermsAndService extends StatelessWidget {
  const TermsAndService({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        title: const Text(
          "Terms And Service",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text:
                          "Welcome to Hospital Tracker! This mobile application is designed to assist users in locating hospitals, tracking visits, and accessing health-related information. By downloading and using our app, you agree to adhere to the following terms and conditions. This document serves as a guide to ensure that both you, the user, and we, the providers, maintain a clear understanding of rights, responsibilities, and limitations while using Hospital Tracker.\n\n",
                    ),
                    TextSpan(
                      text:
                          "First and foremost, user eligibility is a key requirement. By using this application, you confirm that you are at least 18 years old and capable of entering legally binding agreements. Hospital Tracker is intended for responsible usage, and we encourage parents or guardians to supervise minors who may need to access health-related information. Furthermore, users are expected to utilize the application only for its intended purposes, such as finding hospitals, tracking medical appointments, and accessing health-related resources. \n\n",
                    ),
                    TextSpan(
                      text:
                          "The intellectual property of Hospital Tracker is one of our core values. All text, graphics, logos, designs, and functionalities within the application are the sole property of Future Technologies Corporation or our licensors. As such, copying, reproducing, or distributing the content without permission is strictly prohibited. Users are granted a non-exclusive, non-transferable license to use the app for personal purposes only. Unauthorized attempts to hack, reverse engineer, or misuse the app will result in termination of access and potential legal action. Your hard work, innovative ideas, and ability to overcome obstacles together have been invaluable. This experience has strengthened not only our project but also our bond as a team, and it has been an honor to work alongside such talented individuals.\n\n",
                    ),
                    TextSpan(
                      text:
                          "When using Hospital Tracker, you agree to comply with all applicable laws and regulations. It is strictly forbidden to use the application for fraudulent or illegal activities. While we strive to provide accurate and up-to-date information, it is important to note that the app's content should be used as a reference and not as a substitute for professional medical advice. Always consult qualified healthcare professionals for medical issues, as Hospital Tracker does not assume liability for decisions made based on its information.\n\n",
                    ),
                    TextSpan(
                      text:
                          "Lastly, we respect your privacy and are committed to protecting your data. By using the app, you consent to the collection and processing of information as outlined in our Privacy Policy. This includes tracking your app usage to improve functionality and tailor services to your needs. However, your personal data will never be sold or shared with third parties without your consent. We encourage you to review the Privacy Policy regularly to stay informed about how your data is handled.\n\n",
                    ),
                    TextSpan(
                      text:
                          "By agreeing to these terms, you join us in ensuring that Hospital Tracker remains a safe, efficient, and helpful tool for its users. Should you have questions, concerns, or feedback regarding these terms, feel free to contact us at futuretechnologies@proton.com.my. Thank you for choosing Hospital Tracker, and we wish you a seamless experience as you navigate your healthcare journey!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
