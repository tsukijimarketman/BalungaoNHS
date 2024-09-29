import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/enrollment_form.dart';

class TacMobileView extends StatefulWidget {
  final VoidCallback closeTAC;

  const TacMobileView({super.key, required this.closeTAC});

  @override
  State<TacMobileView> createState() => _TacMobileViewState();
}

class _TacMobileViewState extends State<TacMobileView> {
  bool _isChecked = false;

  void _onContinuePressed() {
    if (_isChecked) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                EnrollmentForm()),
      );
    } else {
      widget.closeTAC();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10)
        ),
        child: Card(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: widget.closeTAC,
                      icon: Icon(Icons.close_outlined)),
                ),
                Text(
                  'Terms and Conditions',
                  style: TextStyle(fontFamily: "B", fontSize: 25),
                ),SizedBox(height: 20),
              Padding(
  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
  child: RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 14, color: Colors.black),
      children: [
        TextSpan(
          text: '''
Welcome to ''',
        ),
        TextSpan(
          text: 'Prime Brilliant Minds Academy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: '''. By using the services provided through this portal, you agree to comply with the following terms and conditions. Please read them carefully as they contain important information about your rights and obligations as a student. 

When you create an account and enroll through the portal, you give consent for the school to collect and store personal information such as your name, address, contact information, and academic history etc. This information will be used solely for the purpose of managing your enrollment, academic progress, and other related administrative functions. By continuing to use the portal, you acknowledge that we may store and use your data to facilitate the educational services provided by the school.

Your personal data is essential for ensuring that the academic programs are tailored to your needs. This includes using your information for various school-related communications, such as notices about class schedules, assignments, grades, or other important school activities. Prime Brilliant Minds Academy may also use your data to help improve the quality of educational services offered, maintain accurate records, and ensure compliance with national educational standards.

We take the protection of your personal information seriously and employ various security measures to safeguard your data from unauthorized access or misuse. Our school portal uses encryption and other security protocols to maintain the confidentiality of your information. However, while we strive to protect your data, we cannot guarantee absolute security given the nature of the internet and digital storage. It is your responsibility to maintain the confidentiality of your login credentials and notify us immediately if you suspect any unauthorized access to your account.

By enrolling, you also agree to provide accurate and truthful information at all times. Misrepresentation of personal details or academic records can result in disciplinary action, including, but not limited to, suspension or expulsion from the portal or school. Furthermore, the use of the portal is for legitimate educational purposes only. Any misuse, including attempts to hack, tamper, or exploit the system, will be met with strict disciplinary action.

As a student, you agree to respect the integrity of the academic community. This means not engaging in activities that disrupt the educational process or harm the school’s reputation. Your behavior within the portal should reflect the standards and values of Prime Brilliant Minds Academy, which include respect, integrity, and responsibility.

These Terms and Conditions are subject to periodic updates. The school reserves the right to modify the terms as necessary to comply with new laws, regulations, or internal policy changes. Any significant updates will be communicated through the portal, and continued use of the system after such updates signifies your acceptance of the revised terms.

If you have any concerns or inquiries about how your data is being used or how these Terms affect you, please contact the school administration for further clarification.

Thank you for taking the time to read these Terms and Conditions. By clicking "I Accept," you acknowledge that you have read, understood, and agree to these terms, and that your data may be collected and used as described above.
''',
        ),
      ],
    ),
  ),
),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 5, 30, 5),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Colors.blueAccent,
                        checkColor: Colors.white,
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          'I agree to the terms and conditions',
                          style: TextStyle(fontFamily: "B", fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  width: screenWidth / 3,
                  height: screenHeight / 20,
                  child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Colors.deepPurpleAccent),
                        elevation: MaterialStateProperty.all<double>(5),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    onPressed: _onContinuePressed,
                    child: Text('Continue',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),),
                  ),
                ),
                SizedBox(height: screenHeight / 30,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
