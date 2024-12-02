import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pbma_portal/launcher.dart';
import 'package:pbma_portal/pages/admin_dashboard.dart';
import 'package:pbma_portal/reports/enrollment_report/enrollment_report.dart';
import 'package:pbma_portal/student_utils/student_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_web/url_launcher_web.dart'; 
import 'dart:async';  // Required for runZonedGuarded

Future<void> main() async {
  // Use runZonedGuarded at the top level
  runZonedGuarded(() async {
    // Ensure Flutter bindings are initialized in the same zone
    WidgetsFlutterBinding.ensureInitialized();

    // Perform async initialization tasks
    await SharedPreferences.getInstance();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyB8AL691SI-FMTEpUXazYRUYrTp5CG2KdE",
        authDomain: "pbmasportal.firebaseapp.com",
        projectId: "pbmasportal",
        storageBucket: "pbmasportal.appspot.com",
        messagingSenderId: "501913407280",
        appId: "1:501913407280:web:4d522e0a868fdac20b82f5",
      ),
    );

    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    // Run the app inside the same zone
    runApp(const MyApp());

  }, (error, stackTrace) {
    print('Caught error in zone: $error');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PBMA Portal',
      home:  StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              // User is signed in, fetch user data from Firestore
              return FutureBuilder<QuerySnapshot>(
  future: FirebaseFirestore.instance
      .collection('users')
      .where('uid', isEqualTo: snapshot.data!.uid) // Query by uid field
      .get(),
  builder: (context, userSnapshot) {
    if (userSnapshot.connectionState == ConnectionState.waiting) {
      return Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('LOADING...'),
              ],
              isRepeatingAnimation: true,
            ),
          ),
        );
    }

    if (userSnapshot.hasError) {
      return Center(child: Text('Error fetching user data'));
    }

    if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.docs.isNotEmpty) {
      final userData = userSnapshot.data!.docs.first.data() as Map<String, dynamic>;
      final accountType = userData['accountType'];

      // Navigate to the appropriate UI based on account type
      if (accountType == 'admin') {
        return AdminDashboard(); // Navigate to Admin Dashboard
      } else if (accountType == 'instructor') {
        return AdminDashboard(); // Navigate to Teacher UI
      } else if (accountType == 'student') {
        return StudentUI(); // Navigate to Student UI
      } else {
        return Center(child: Text('Unknown account type'));
      }
    }

    return Center(child: Text('User  document does not exist.'));
  },
);
            } else {
              // User is not signed in, navigate to the launcher
              return Launcher();
            }
          }
          return Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('LOADING...'),
              ],
              isRepeatingAnimation: true,
            ),
          ),
        );
        },
      ),
    );
  }
}