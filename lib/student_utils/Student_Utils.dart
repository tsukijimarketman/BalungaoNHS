import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<String> generateStudentID() async {
  final currentYear = DateTime.now().year.toString();
  final collection = FirebaseFirestore.instance.collection('users');
  final querySnapshot = await collection.orderBy('student_id', descending: true).limit(1).get();

  if (querySnapshot.docs.isEmpty) {
    return '${currentYear}-PBMA-0001';
  }

  final lastDoc = querySnapshot.docs.first;
  final lastID = lastDoc['student_id'] as String;

  final lastNumber = int.parse(lastID.split('-').last);
  final nextNumber = lastNumber + 1;

  return '${currentYear}-PBMA-${nextNumber.toString().padLeft(4, '0')}';
}

Future<void> createFirebaseUser(String email) async {
  final password = 'ilovePBMA_123'; // Default Password ng Student

  if (email.isEmpty) {
    print('Error: The provided email is empty.');
    return;
  }

  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    print('User created with ID: ${userCredential.user!.uid}');


  } catch (e) {
    print('Failed to create user: $e');
  }
}

Future<void> approveStudent(String studentDocId) async {
  final studentDoc = await FirebaseFirestore.instance.collection('users').doc(studentDocId).get();
  final studentData = studentDoc.data() as Map<String, dynamic>;
  final email = studentData['email_Address'] as String? ?? '';

  if (email.isEmpty) {
    print('Error: No email address provided for student ID: $studentDocId');
    return;
  }

  final studentId = await generateStudentID();

  await createFirebaseUser(email);

  await FirebaseFirestore.instance.collection('users').doc(studentDocId).update({
    'student_id': studentId,
    'enrollment_status': 'approved',
    'accountType': 'student',
  }).then((_) {
    print('Student approved and updated successfully.');
  }).catchError((error) {
    print('Failed to update student: $error');
  });
}

