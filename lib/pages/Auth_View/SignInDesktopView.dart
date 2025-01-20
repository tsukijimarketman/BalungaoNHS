// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/Auth_View/ForceChangePassDesktopView.dart';
import 'package:balungao_nhs/pages/Auth_View/Forgot_Pass_desktopview.dart';
import 'package:balungao_nhs/pages/admin_dashboard.dart';
import 'package:balungao_nhs/student_utils/Re-EnrolledForm.dart';
import 'package:balungao_nhs/student_utils/student_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInDesktop extends StatefulWidget {
  final VoidCallback closeSignInCardCallback;

  const SignInDesktop({super.key, required this.closeSignInCardCallback});

  @override
  State<SignInDesktop> createState() => _SignInDesktopState();
}

class _SignInDesktopState extends State<SignInDesktop> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showForgotPass = false;
  bool _showChangePassword = false;
  bool _showReEnrollView = false;

  void toggleForgotPass() {
    setState(() {
      _showForgotPass = !_showForgotPass;
    });
      print("Toggle TAC card: $_showForgotPass");
  }

  void closeForgotPass() {
    setState(() {
      _showForgotPass = false;
    });
  }

  void toggleChangePassword() {
    setState(() {
      _showChangePassword = !_showChangePassword;
    });
  }

  void toggleReEnroll() {
    setState(() {
      _showReEnrollView = !_showReEnrollView;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  void _togglePasswordVisibility(bool isPressed) {
    setState(() {
      _obscureText = !isPressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Current view: ${_showForgotPass ? "Forgot Password" : _showChangePassword ? "Change Password" : _showReEnrollView ? "ReEnroll" : "Sign In"}');

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double cardWidth = screenWidth * 0.4;  // 40% of screen width
  double cardHeight = screenHeight * 0.85; // 85% of screen height
  double inputWidth = cardWidth * 0.85;    // 85% of card width
  

    return Stack(
      children: [
      Center(
        child: Container(
          width: cardWidth,
          height: cardHeight,
          constraints: BoxConstraints(
            minWidth: 400,  // Minimum width for very small screens
            maxWidth: 800,  // Maximum width for very large screens
            minHeight: 600, // Minimum height
            maxHeight: 900, // Maximum height
          ),
          child: Card(
                      child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,

                        children: [
                          Container(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: widget.closeSignInCardCallback,
                                icon: Icon(Icons.close_outlined)),
                          ),
                          Flexible(
                  flex: 2,
                  child: Image.asset(
                    'assets/balungaonhs.png',
                    fit: BoxFit.contain,
                  ),
                ),
                
                SizedBox(height: cardHeight * 0.02),
                      // ... existing code ...

// Welcome text
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: cardWidth * 0.075, // Reduced from 0.1 to 0.075 for better scaling
  ),
  child: Container(
    width: inputWidth,
    child: Text(
      'Welcome Back!',
      style: TextStyle(
        fontSize: cardWidth * 0.045, // Slightly reduced for better proportion
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.left,
    ),
  ),
),

// ... rest of the code ...
                SizedBox(height: cardHeight * 0.02),
                          Container(
                            width: inputWidth,
                  height: cardHeight * 0.08,
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
                                SizedBox(height: cardHeight * 0.02),
                          Container(
                             width: inputWidth,
                  height: cardHeight * 0.08,
                            child: CupertinoTextField(
                              controller: _passwordController,
                              placeholder: 'Password',
                              obscureText: _obscureText,
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
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Container(
                                  margin: EdgeInsets.only(right: 10.0),
                                  child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                           Container(
                  width: inputWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                          ),
                          Text(
                            'Remember Me',
                            style: TextStyle(
                              fontSize: cardWidth * 0.03,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: toggleForgotPass,
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: cardWidth * 0.03,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: cardHeight * 0.02),

                          Container(
                            width: inputWidth,
                  height: cardHeight * 0.06,
                            child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Color(0xFF002f24)),
                                  elevation:
                                      MaterialStateProperty.all<double>(5),
                                  shape:
                                      MaterialStateProperty.all<OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  _checkEmailandPasswords();
                                },
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                        fontSize: cardWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )),
                          ),
                                          SizedBox(height: cardHeight * 0.02),

                        ],
                        
                      ),
                    ),
        ),
      ),
      if (_showForgotPass || _showChangePassword || _showReEnrollView)
        Center(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 550),
            child: _showForgotPass
                ? ForgotPassDesktopview(
                    key: ValueKey('forgotPassView'),
                    closeforgotpassCallback: toggleForgotPass,
                  )
                : _showChangePassword
                    ? ChangePasswordDesktop(
                        key: ValueKey('changePasswordScreen'),
                        email: _emailController.text.trim(),
                      )
                    : _showReEnrollView
                        ? ReEnrollForm(
                            key: ValueKey('ReEnrollView'),
                          )
                        : SizedBox.shrink(),
          ),
        ),
    ],
  );
}

  void _checkEmailandPasswords() {
    String input = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (password.isEmpty || input.isEmpty) {
      _showDialog('Empty Fields', 'Please fill in both fields.');
      return;
    }

    RegExp passwordRegex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_-]).{8,}$',
    );

    if (!passwordRegex.hasMatch(password)) {
      _showDialog('Weak Password',
          'Password must contain at least 8 characters, including uppercase letters, lowercase letters, numbers, and symbols.');
      return;
    }

    RegExp emailRegex = RegExp(r"^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]");

    if (emailRegex.hasMatch(input)) {
      _signInWithEmail(input, password);
    } else if (input.contains('-BNHS-')) {
      _signInWithStudentId(input, password);
    } else {
      _showDialog('Invalid Input', 'Please enter a valid email or student ID.');
    }
  }

  Future<void> _signInWithStudentId(String studentId, String password) async {
    try {
      final QuerySnapshot userDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('student_id', isEqualTo: studentId)
          .get();

      if (userDocs.docs.isNotEmpty) {
        final email = userDocs.docs.first['email_Address'] as String?;
        if (email != null) {
          await _signInWithEmail(email, password);
        } else {
          _showDialog(
              'Login Failed', 'No email associated with this student ID.');
        }
      } else {
        _showDialog('Login Failed', 'Student ID not found.');
      }
    } catch (error) {
      _showDialog('Login Failed', 'An error occurred: ${error.toString()}');
    }
  }

  Future<void> _signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final QuerySnapshot userDocs = await FirebaseFirestore.instance
            .collection('users')
            .where('email_Address', isEqualTo: email)
            .get();

        if (userDocs.docs.isNotEmpty) {
          final userData = userDocs.docs.first.data() as Map<String, dynamic>?;

          if (userData?['Status'] == 'inactive') {
          _showDialog('Account Disabled', 'Your account has been disabled. Please contact support.');
          return;
        }

          final accountType = (userDocs.docs.first.data()
              as Map<String, dynamic>?)?['accountType'];
          final passwordChanged = userData?['passwordChanged'] ?? false;
          final enrollmentStatus = userData?['enrollment_status'];

          if (accountType == "admin") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else if (accountType == "instructor") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AdminDashboard(),
              ),
            );
          } else if (accountType == "student") {
            if (!passwordChanged) {
            setState(() {
              _showChangePassword = true;
            });
          } else if (enrollmentStatus == 're-enrolled') {
            if (enrollmentStatus == 're-enrolled') {
            setState(() {
              _showReEnrollView = true;
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentUI()),
            );
          }
           } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StudentUI()),
            );
          
          }
        } else {
          _showDialog('Login Failed', 'Account type is not recognized.');
        }
      } else {
        _showDialog('User Not Found', 'User document not found.');
      }

        _saveRememberMe(true, email);
      }
    } catch (error) {
      String errorMessage = 'An error occurred. Please try again later.';

      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Invalid password.';
            break;
          default:
            errorMessage = 'Authentication error: ${error.message}';
        }
      } else {
        errorMessage = 'Unexpected error: ${error.toString()}';
      }

      _showDialog('Login Failed', errorMessage);
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

  void _loadRememberMe() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    if (_rememberMe) {
      List<String>? rememberedEmails = prefs.getStringList('rememberedEmails');
      if (rememberedEmails != null && rememberedEmails.isNotEmpty) {
        _emailController.text = rememberedEmails.last;
      }
    }
  }

  void _saveRememberMe(bool value, [String? email]) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _rememberMe = value;
    if (_rememberMe) {
      List<String> rememberedEmails =
          prefs.getStringList('rememberedEmails') ?? [];
      if (!rememberedEmails.contains(email)) {
        rememberedEmails.add(email!);
        prefs.setStringList('rememberedEmails', rememberedEmails);
      }
    } else {
      prefs.remove('rememberedEmails');
    }
    prefs.setBool('rememberMe', _rememberMe);
  }
}
