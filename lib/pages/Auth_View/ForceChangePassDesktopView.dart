import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/student_utils/student_ui.dart';

class ChangePasswordDesktop extends StatefulWidget {
  final String email;

  const ChangePasswordDesktop({super.key, required this.email});

  @override
  _ChangePasswordDesktopState createState() => _ChangePasswordDesktopState();
}

class _ChangePasswordDesktopState extends State<ChangePasswordDesktop> {
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

        Navigator.pushReplacement(
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

    double cardWidth = screenWidth * 0.4;  // 40% of screen width
    double cardHeight = screenHeight * 0.85; // 85% of screen height
    double inputWidth = cardWidth * 0.85;    // 85% of card width

    return Center(
      child: Container(
        width: cardWidth,
        height: cardHeight,
        constraints: BoxConstraints(
          minWidth: 400,  // Minimum width for very small screens
          maxWidth: 800,  // Maximum width for very large screens
          minHeight: 600, // Minimum height
          maxHeight: 900, // Maximum height
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 550),
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                                                  SizedBox(height: cardHeight * 0.02),

                   Flexible(
                flex: 2,
                child: Image.asset(
                  'assets/PBMA.png',
                  fit: BoxFit.contain,
                ),
              ),
                                SizedBox(height: cardHeight * 0.02),

                  Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.075,
                ),
                child: Container(
                  width: inputWidth,
                  child: Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: cardWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
                   Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: cardWidth * 0.075,
                ),
                child: Container(
                  width: inputWidth,
                  child: Text(
                    'Before you proceed please kindly change your password',
                    style: TextStyle(
                      fontSize: cardWidth * 0.03,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),

              SizedBox(height: cardHeight * 0.04),

                  Container(
                width: inputWidth,
                height: cardHeight * 0.08,
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
                           SizedBox(height: cardHeight * 0.02),

                        Container(
                width: inputWidth,
                height: cardHeight * 0.08,
                    child: CupertinoTextField(
                      controller: _confirmPasswordController,
                      placeholder: 'Confirm Password',
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
                         SizedBox(height: cardHeight * 0.04),
    Container(
                width: inputWidth,
                height: cardHeight * 0.06,
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
                      fontSize: cardWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),),
                    ),
                  ),
                  if (_passwordMismatch)
                    Padding(
                  padding: EdgeInsets.symmetric(vertical: cardHeight * 0.02),
                      child: Text(
                        'Passwords do not match',
                        style: TextStyle(color: Colors.red,                       fontSize: cardWidth * 0.03,
),
                      ),
                    ),
                                                    SizedBox(height: cardHeight * 0.02),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
