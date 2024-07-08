import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pbma_portal/pages/dashboard.dart';
import 'package:pbma_portal/pages/enrollment_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SharedPreferences.getInstance();
    
    await Firebase.initializeApp( 
     options: FirebaseOptions( 
    apiKey: "AIzaSyB8AL691SI-FMTEpUXazYRUYrTp5CG2KdE",
  authDomain: "pbmasportal.firebaseapp.com",
  projectId: "pbmasportal",
  storageBucket: "pbmasportal.appspot.com",
  messagingSenderId: "501913407280",
  appId: "1:501913407280:web:4d522e0a868fdac20b82f5"
     )
    );

runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PBMA Portal',
      home: EnrollmentForm(), //dashboard
    );
  }
}
