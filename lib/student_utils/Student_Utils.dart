import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> getCurrentCurriculum() async {
  try {
    final configSnapshot = await FirebaseFirestore.instance
        .collection('configurations')
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (configSnapshot.docs.isNotEmpty) {
      return configSnapshot.docs.first.data()['school_year'] ?? 'Unknown';
    }
    return 'Unknown';
  } catch (e) {
    print('Error getting current curriculum: $e');
    return 'Unknown';
  }
}

Future<String> generateStudentID() async {
  final currentYear = DateTime.now().year.toString();
  final collection = FirebaseFirestore.instance.collection('users');
  final querySnapshot =
      await collection.orderBy('student_id', descending: true).limit(1).get();

  if (querySnapshot.docs.isEmpty) {
    return '${currentYear}-BNHS-0001';
  }

  final lastDoc = querySnapshot.docs.first;
  final lastID = lastDoc['student_id'] as String;
  final lastNumber = int.parse(lastID.split('-').last);
  final nextNumber = lastNumber + 1;

  return '${currentYear}-BNHS-${nextNumber.toString().padLeft(4, '0')}';
}

Future<void> approveStudent(String studentDocId) async {
  try {
    final studentDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(studentDocId)
        .get();
    final studentData = studentDoc.data() as Map<String, dynamic>;
    final email = studentData['email_Address'] as String? ?? '';

    if (email.isEmpty) {
      print('Error: No email address provided for student ID: $studentDocId');
      return;
    }

    final studentId = await generateStudentID();
    final curriculum = await getCurrentCurriculum();

    // Get the current Firebase options
    final options = Firebase.app().options;
    
    // Create a unique name for the temporary app
    final tempAppName = 'tempApp-${DateTime.now().millisecondsSinceEpoch}';

    // Initialize the temporary app with explicit options
    final tempApp = await Firebase.initializeApp(
      name: tempAppName,
      options: FirebaseOptions(
        apiKey: options.apiKey,
        appId: options.appId,
        messagingSenderId: options.messagingSenderId,
        projectId: options.projectId,
        authDomain: options.authDomain,
        storageBucket: options.storageBucket,
      ),
    );

    try {
      // Create auth instance from temporary app
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
      
      // Create student account
      final userCredential = await tempAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: 'iloveBNHS_123',
      );

      final uid = userCredential.user?.uid;
      if (uid == null) {
        throw Exception('Failed to create user: No UID generated');
      }

      // Update Firestore document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentDocId)
          .update({
        'student_id': studentId,
        'enrollment_status': 'approved',
        'accountType': 'student',
        'uid': uid,
        'Status': 'active',
        'passwordChanged': false,
        'school_year': curriculum,
      });

      // Clean up
      await tempAuth.signOut();
      
      print('Student approved and Firebase Auth user created successfully.');
      
      // Send email using EmailJS
      await sendEnrollmentEmail(email.trim());
      
    } finally {
      // Ensure cleanup happens
      try {
        await tempApp.delete();
      } catch (deleteError) {
        print('Error deleting temporary app: $deleteError');
      }
    }
    
  } catch (e) {
    print('Failed to create user or update document: $e');
    // You might want to show an error message to the user here
  }
}

Future<void> sendEnrollmentEmail(String email) async {
  const serviceID = 'service_co92dqo';
  const templateID = 'template_219e208';
  const publicKey = '2wzHcnT-yPVfgQhcv';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'service_id': serviceID,
      'template_id': templateID,
      'user_id': publicKey,
      'template_params': {
        'email': email,
        'message':
            'Congratulations! Your enrollment has been processed. Welcome to the Balungao National High School.\n\n'
                'Here is your student account for the student portal:\n'
                'Username: $email\n'
                'Password: iloveBNHS_123 (Please change this after logging in for the first time)',
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Enrollment email sent successfully');
  } else {
    print('Failed to send email: ${response.body}');
  }
}
