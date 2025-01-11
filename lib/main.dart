// ignore_for_file: unused_import

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/pages/admin_dashboard.dart';
import 'package:balungao_nhs/reports/enrollment_report/enrollment_report.dart';
import 'package:balungao_nhs/student_utils/student_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_web/url_launcher_web.dart'; 
import 'dart:async';  // Required for runZonedGuarded
import 'package:supabase_flutter/supabase_flutter.dart';
 
Future<void> main() async {
  // Use runZonedGuarded at the top level
  runZonedGuarded(() async {
    // Ensure Flutter bindings are initialized in the same zone
    WidgetsFlutterBinding.ensureInitialized();

    await Supabase.initialize(
     url: 'https://zimpntwjohlskjsevpbe.supabase.co',
     anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InppbXBudHdqb2hsc2tqc2V2cGJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYzNDg4MjUsImV4cCI6MjA1MTkyNDgyNX0.tIjt_0qHqFglNokTTO-6XW2euRUzQUUi_PB8puncDj8',
   );

    // Perform async initialization tasks
    await SharedPreferences.getInstance();
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCN9fKKOi7P5WPzaZgUwUP_rSIO4ABJbco",
        authDomain: "balungaonhs-29b22.firebaseapp.com",
        projectId: "balungaonhs-29b22",
        storageBucket: "balungaonhs-29b22.firebasestorage.app",
        messagingSenderId: "1040305288347",
        appId: "1:1040305288347:web:35973ead46a7f342a4423e",
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
      title: 'Balungao NHS Portal',
      home: StreamBuilder<firebase_auth.User?>(
       stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),  // Update FirebaseAuth reference
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