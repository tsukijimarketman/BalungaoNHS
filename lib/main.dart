import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pbma_portal/launcher.dart';
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
      home:  StudentUI(),  //Launcher
    );
  }
}
