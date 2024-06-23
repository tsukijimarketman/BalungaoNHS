// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/admin_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _obscureText = true;
  bool _rememberMe = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
    return Center(
      child: Container(
        width: 700,
        height: 500,
        child: Card(
          elevation: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 50),
                  child: Image.asset(
                    'assets/PBMA.png',
                    width: 130,
                    height: 130,
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Container(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: 600,
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
              SizedBox(
                height: 10,
              ),
              Container(
                height: 50,
                width: 600,
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
                      onTapCancel: () => _togglePasswordVisibility(false),
                      child: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 50.0),
                    child: Checkbox(
                      activeColor: Colors.blueAccent,
                      checkColor: Colors.white,
                      value: _rememberMe,
                      onChanged: (value) {
                        setState(() {
                          _rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  Text('Remember Me'),
                  SizedBox(
                    width: 350,
                  ),
                  TextButton(onPressed: () {}, child: Text('Forgot Password?'))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 40,
                width: 600,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all<Color>(
                          Colors.deepPurpleAccent),
                      elevation: WidgetStateProperty.all<double>(5),
                      shape: WidgetStateProperty.all<OutlinedBorder>(
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _checkEmailandPasswords() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    if (password.isEmpty || email.isEmpty) {
      _showDialog('Empty Fields', 'Please fill in both fields.');
      return;
    }

    RegExp regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_-]).{8,}$',
    );

    if (!regex.hasMatch(password)) {
      _showDialog('Weak Password',
          'Password must contain at least 8 characters, including uppercase letters, lowercase letters, numbers, and symbols.');
      return;
    }
    RegExp emailRegex = RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]");

    if (!emailRegex.hasMatch(email)) {
      _showDialog('Invalid Mobile Number or Email',
          'Please Enter Valid Mobile Number or Email');
      return;
    }
    _signIn();
  }

  Future<void> _signIn() async {
    try {
      final String email = _emailController.text.trim();
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
        _saveRememberMe(true, email);
      } else {
        _showDialog('User Not Found', 'User document not found.');
      }
    } catch (error) {
      String errorMessage = 'An error occurred. Please try again later.';
      if (error is FirebaseAuthException) {
        if (error.code == 'user-not-found') {
          errorMessage = 'No user found with this email.';
        } else if (error.code == 'wrong-password') {
          errorMessage = 'Invalid password.';
        }
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
        _emailController.text =
            rememberedEmails.last; // Set the first remembered email
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
        rememberedEmails
            .add(email!); // Add the email to the list of remembered emails
        prefs.setStringList('rememberedEmails', rememberedEmails);
      }
    } else {
      // Handle the case when Remember Me is unchecked
      prefs.remove('rememberedEmails');
    }
    prefs.setBool('rememberMe', _rememberMe);
  }
}
