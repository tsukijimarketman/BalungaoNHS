import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/student_utils/student_ui.dart';

class ChangePasswordMobile extends StatefulWidget {
  final String email;

  const ChangePasswordMobile({super.key, required this.email});

  @override
  _ChangePasswordMobileState createState() => _ChangePasswordMobileState();
}

class _ChangePasswordMobileState extends State<ChangePasswordMobile> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureTextNew = true;
  bool _obscureTextConfirm = true;
  bool _passwordMismatch = false;

  void _togglePasswordVisibilityNew() {
    setState(() {
      _obscureTextNew = !_obscureTextNew;
    });
  }

  void _togglePasswordVisibilityConfirm() {
    setState(() {
      _obscureTextConfirm = !_obscureTextConfirm;
    });
  }

  Future<void> _changePassword() async {
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showDialog('Empty Field',
          'Please enter both new password and confirm password.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _passwordMismatch = true;
      });
      return;
    }

    RegExp passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_-]).{8,}$',
    );

    if (!passwordRegex.hasMatch(newPassword)) {
      _showDialog('Weak Password',
          'Password must contain at least 8 characters, including uppercase letters, lowercase letters, numbers, and symbols.');
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);

        final uid = user.uid;
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: uid)
            .get();

        if (querySnapshot.docs.isEmpty) {
          _showDialog('Error', 'No document found with the provided UID.');
          return;
        }

        final document = querySnapshot.docs.first;
      final documentId = document.id;
      final firstName = document['first_name'] as String;
      final middleName = document['middle_name'] as String;
      final lastName = document['last_name'] as String;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({
          'passwordChanged': true,
        }).catchError((error) {
          print('Failed to update document: $error');
          _showDialog(
              'Error', 'Failed to update document: ${error.toString()}');
        });

        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentUI(),
        ),
      );
    }
  } catch (error) {
    _showDialog('Error', 'Failed to change password: ${error.toString()}');
  }
}

  void _showDialog(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

   // Exactly match SignInMobileView calculations
  double cardWidth = screenWidth < 600 
      ? screenWidth * 0.95  // Mobile
      : screenWidth < 900   
          ? screenWidth * 0.8  // Tablet
          : screenWidth * 0.6; // Desktop
  
  double cardHeight = screenHeight < 800 
      ? screenHeight * 0.85  // Shorter screens
      : screenHeight * 0.75; // Taller screens

  // Other calculations remain the same
  double logoSize = screenWidth < 600 
      ? screenWidth * 0.25
      : screenWidth < 900   
          ? screenWidth * 0.15
          : screenWidth * 0.12;
  
  logoSize = logoSize.clamp(50.0, 120.0);
  
  double inputFieldHeight = (screenHeight * 0.06).clamp(45.0, 60.0);
  double inputFieldWidth = cardWidth * 0.9;

  double titleFontSize = (screenWidth * 0.035).clamp(16.0, 24.0);
  double subtitleFontSize = (screenWidth * 0.025).clamp(14.0, 18.0);
  double buttonFontSize = (screenWidth * 0.025).clamp(14.0, 18.0);

    return Center(
      child:  AnimatedSwitcher(
        duration: Duration(milliseconds: 550),
        child: Container(
      width: cardWidth,
      height: cardHeight,
      constraints: BoxConstraints(
        maxWidth: 800,
        maxHeight: 900,
      ),
        child:  Card(
                    elevation: 5,  // Added to match SignInMobileView
shape: RoundedRectangleBorder(  // Added to match SignInMobileView
            borderRadius: BorderRadius.circular(8),
          ),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/balungaonhs.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    width: inputFieldWidth,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Change Password',
                      style: TextStyle(fontSize: titleFontSize),
                    ),
                  ),
                  Container(
                    width: inputFieldWidth,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Before you proceed please kindly change your password',
                      style: TextStyle(fontSize: subtitleFontSize),
                    ),
                  ),
                 SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: inputFieldHeight,
                    width: inputFieldWidth,
                    child: CupertinoTextField(
                      controller: _newPasswordController,
                      placeholder: 'Password',
                      obscureText: _obscureTextNew,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.shade300,
                      ),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(Icons.lock_outline),
                      ),
                      suffix: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureTextNew = !_obscureTextNew;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: Icon(
                            _obscureTextNew
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                                  SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: inputFieldHeight,
                    width: inputFieldWidth,
                    child: CupertinoTextField(
                      controller: _confirmPasswordController,
                      placeholder: 'Password',
                      obscureText: _obscureTextConfirm,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.grey.shade300,
                      ),
                      prefix: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Icon(Icons.lock_outline),
                      ),
                      suffix: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureTextConfirm = !_obscureTextConfirm;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10.0),
                          child: Icon(
                            _obscureTextConfirm
                                ? Icons.visibility
                                : Icons.visibility_off,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                    SizedBox(height: screenHeight * 0.02),
                  Container(
                    height: inputFieldHeight,
                    width: inputFieldWidth,
                    child: ElevatedButton(
                      style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.deepPurpleAccent),
                                    elevation:
                                        MaterialStateProperty.all<double>(5),
                                    shape:
                                        MaterialStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                      onPressed: _changePassword,
                      child: Text('Change Password',
                                  style: TextStyle(
                          fontSize: buttonFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),),
                    ),
                  ),
                  if (_passwordMismatch)
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.02),
                      child: Text(
                        'Passwords do not match',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
    );
  }
}
