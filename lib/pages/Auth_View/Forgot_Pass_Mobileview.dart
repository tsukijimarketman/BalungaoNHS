import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/mobile_view.dart';

class ForgotPassMobileview extends StatefulWidget {
  final VoidCallback closeforgotpassCallback;
  const ForgotPassMobileview(
      {super.key, required this.closeforgotpassCallback});

  @override
  State<ForgotPassMobileview> createState() => _ForgotPassMobileviewState();
}

class _ForgotPassMobileviewState extends State<ForgotPassMobileview> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text('Password reset Link Sent! Check your Email'),
            );
          });
      Future.delayed(Duration(seconds: 3), () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MobileView()));
      });
    } on FirebaseAuthException catch (e) {
      print(e);
      showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              content: Text(e.message.toString()),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Close',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
     // More refined responsive calculations
  double cardWidth = screenWidth < 600 
      ? screenWidth * 0.95  // Mobile
      : screenWidth < 900   
          ? screenWidth * 0.8  // Tablet
          : screenWidth * 0.6; // Desktop
  
  double cardHeight = screenHeight < 800 
      ? screenHeight * 0.85  // Shorter screens
      : screenHeight * 0.75; // Taller screens
  
  // Adjusted logo size with maximum constraints
  double logoSize = screenWidth < 600 
      ? screenWidth * 0.25  // Mobile
      : screenWidth < 900   
          ? screenWidth * 0.15  // Tablet
          : screenWidth * 0.12;  // Desktop
  
  // Add maximum size constraint for logo
  logoSize = logoSize.clamp(50.0, 120.0); // Prevents logo from getting too large
  
  // Adjusted input field dimensions
  double inputFieldHeight = (screenHeight * 0.06).clamp(45.0, 60.0); // Min 45px, Max 60px
  double inputFieldWidth = cardWidth * 0.9;  // Slightly wider fields

  // Adjusted font sizes
  double titleFontSize = (screenWidth * 0.035).clamp(16.0, 24.0);
  double buttonFontSize = (screenWidth * 0.025).clamp(14.0, 18.0);

    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: 900,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
            child: Column(
              children: [
                Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: widget.closeforgotpassCallback,
                  icon: Icon(Icons.close_outlined),
                ),
              ),
                Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Image.asset(
                  'assets/PBMA.png',
                   width: logoSize,
                          height: logoSize,
                          fit: BoxFit.contain
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

                Container(
                                  width: inputFieldWidth,

                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 52.0),
                    child: Text(
                      'Password Recovery',
                      style: TextStyle(
                    fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                ),
                              SizedBox(height: screenHeight * 0.02),

                Container(
                                  width: inputFieldWidth,

                alignment: Alignment.centerLeft,
                  child: Text(
                    'Please the Email Address you Provided on Enrollment Form',
                    style: TextStyle(
                    fontSize: titleFontSize,
                    ),
                  ),
                ),
                              SizedBox(height: screenHeight * 0.03),

                Container(
                    height: inputFieldHeight,
                width: inputFieldWidth,
                  child: CupertinoTextField(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.shade300),
                    controller: _emailController,
                    prefix: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Icon(Icons.email_outlined),
                    ),
                    placeholder: 'Email',
                  ),
                ),
                              SizedBox(height: screenHeight * 0.03),

                Container(
                   height: inputFieldHeight,
                width: inputFieldWidth,
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
                      onPressed: passwordReset,
                      child: Text(
                        'Reset Password',
                        style: TextStyle(
                      fontSize: buttonFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
