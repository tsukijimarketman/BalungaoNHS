// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/Auth_View/ForceChangePassDesktopView.dart';
import 'package:balungao_nhs/pages/Auth_View/ForceChangePassMobileView.dart';
import 'package:balungao_nhs/pages/Auth_View/Forgot_Pass_Mobileview.dart';
import 'package:balungao_nhs/pages/Auth_View/Forgot_Pass_desktopview.dart';
import 'package:balungao_nhs/pages/admin_dashboard.dart';
import 'package:balungao_nhs/student_utils/Re-EnrolledForm.dart';
import 'package:balungao_nhs/student_utils/student_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInMobile extends StatefulWidget {
  final VoidCallback closeSignInCardCallback;

  const SignInMobile({super.key, required this.closeSignInCardCallback});

  @override
  State<SignInMobile> createState() => _SignInMobileState();
}

class _SignInMobileState extends State<SignInMobile> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _showForgotPass = false;
  bool _showChangePassword = false;
  bool _showReEnroll = false;

  void toggleForgotPass() {
    setState(() {
      _showForgotPass = !_showForgotPass;
    });
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
      _showReEnroll = !_showReEnroll;
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
    print(
        'Current view: ${_showForgotPass ? "Forgot Password" : _showChangePassword ? "Change Password" : _showReEnroll ? "ReEnroll" : "Sign In"}');

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // More refined responsive calculations
    double cardWidth = screenWidth < 600
        ? screenWidth * 0.95 // Mobile
        : screenWidth < 900
            ? screenWidth * 0.8 // Tablet
            : screenWidth * 0.6; // Desktop

    double cardHeight = screenHeight < 800
        ? screenHeight * 0.85 // Shorter screens
        : screenHeight * 0.75; // Taller screens

    // Adjusted logo size with maximum constraints
    double logoSize = screenWidth < 600
        ? screenWidth * 0.25 // Mobile
        : screenWidth < 900
            ? screenWidth * 0.15 // Tablet
            : screenWidth * 0.12; // Desktop

    // Add maximum size constraint for logo
    logoSize =
        logoSize.clamp(50.0, 120.0); // Prevents logo from getting too large

    // Adjusted input field dimensions
    double inputFieldHeight =
        (screenHeight * 0.06).clamp(45.0, 60.0); // Min 45px, Max 60px
    double inputFieldWidth = cardWidth * 0.9; // Slightly wider fields

    // Adjusted font sizes
    double titleFontSize = (screenWidth * 0.035).clamp(16.0, 24.0);
    double buttonFontSize = (screenWidth * 0.025).clamp(14.0, 18.0);

    return Stack(
      children: [
        Center(
          child: Container(
            width: cardWidth,
            height: cardHeight,
            constraints: BoxConstraints(
              maxWidth: 800, // Maximum card width
              maxHeight: 900, // Maximum card height
            ),
            child: Card(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding:
                      EdgeInsets.all(screenWidth * 0.03), // Responsive padding
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: widget.closeSignInCardCallback,
                          icon: Icon(Icons.close_outlined),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Image.asset('assets/balungaonhs.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        width: inputFieldWidth,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Welcome Back!',
                          style: TextStyle(
                            fontSize: titleFontSize,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
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
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        height: inputFieldHeight,
                        width: inputFieldWidth,
                        child: CupertinoTextField(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.grey.shade300),
                          controller: _passwordController,
                          prefix: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Icon(Icons.lock_outline),
                          ),
                          placeholder: 'Password',
                          obscureText: _obscureText,
                          suffix: Container(
                            margin: EdgeInsets.only(right: 10.0),
                            child: GestureDetector(
                              onTapDown: (_) => _togglePasswordVisibility(true),
                              onTapUp: (_) => _togglePasswordVisibility(false),
                              onTapCancel: () =>
                                  _togglePasswordVisibility(false),
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
                        width: inputFieldWidth,
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
                                Text('Remember Me'),
                              ],
                            ),
                            TextButton(
                              onPressed: toggleForgotPass,
                              child: Text('Forgot Password?'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Container(
                        height: inputFieldHeight,
                        width: inputFieldWidth,
                        child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Color(0xFF002f24)),
                              elevation: MaterialStateProperty.all<double>(5),
                              shape: MaterialStateProperty.all<OutlinedBorder>(
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
                                  fontSize: buttonFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (_showForgotPass || _showChangePassword || _showReEnroll)
          Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 550),
              child: _showForgotPass
                  ? ForgotPassMobileview(
                      key: ValueKey('forgotPassView'),
                      closeforgotpassCallback: toggleForgotPass,
                    )
                  : _showChangePassword
                      ? ChangePasswordMobile(
                          key: ValueKey('changePasswordScreen'),
                          email: _emailController.text.trim(),
                        )
                      : _showReEnroll
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
            _showDialog('Account Disabled',
                'Your account has been disabled. Please contact support.');
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
                  _showReEnroll = true;
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
