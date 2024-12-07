import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class Acknowledgement extends StatelessWidget {
  const Acknowledgement({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 249, 244, 236),
      appBar: AppBar(
        title: Text(
          "Acknowldegement",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 150, 53, 220),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'First of All...',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Gap(10),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text:
                          "We extend our heartfelt gratitude to our lecturer, whose unwavering guidance and insightful advice have been instrumental in shaping this project. Your dedication to imparting knowledge and your patience in addressing our queries have been a source of inspiration. Your support and constructive feedback throughout the journey have greatly enhanced the quality of our work, and for that, we are deeply thankful.\n\n",
                    ),
                    TextSpan(
                      text:
                          "To our families, we owe a debt of gratitude for their unconditional love and encouragement. Your support, both moral and emotional, has been our foundation during challenging times. Your understanding and belief in our abilities have motivated us to persevere and strive for excellence. Without your unwavering backing, this endeavor would not have been possible. \n\n",
                    ),
                    TextSpan(
                      text:
                          "We would also like to thank our teammates, whose collaborative efforts and shared determination have brought this project to fruition. Your hard work, innovative ideas, and ability to overcome obstacles together have been invaluable. This experience has strengthened not only our project but also our bond as a team, and it has been an honor to work alongside such talented individuals.\n\n",
                    ),
                    TextSpan(
                      text:
                          "Our friends have been a constant source of positivity and encouragement throughout this journey. Whether it was through their words of motivation or their willingness to lend a helping hand, their support has been deeply appreciated. Thank you for being there during both the highs and lows, reminding us to take breaks and celebrate our progress.\n\n",
                    ),
                    TextSpan(
                      text:
                          "Lastly, we acknowledge ourselves for the dedication, resilience, and growth demonstrated throughout this endeavor. This project has been a challenging yet rewarding experience, pushing us beyond our comfort zones and teaching us valuable lessons. We are proud of the effort and commitment we have invested in this journey, and we look forward to applying what we have learned in future endeavors.\n\n",
                    ),
                    TextSpan(
                      text:
                          "Thank you all for being an essential part of this achievement.",
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
