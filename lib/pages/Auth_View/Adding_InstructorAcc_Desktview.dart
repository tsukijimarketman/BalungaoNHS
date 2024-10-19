import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddInstructorDialog extends StatefulWidget {
  final VoidCallback closeAddInstructors;

  AddInstructorDialog({
    super.key,
    required this.closeAddInstructors
  });

  @override
  _AddInstructorDialogState createState() => _AddInstructorDialogState();
}

class _AddInstructorDialogState extends State<AddInstructorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); 

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _firstNameController.text;
      final middleName = _middleNameController.text;
      final lastName = _lastNameController.text;
      final subjectName = _subjectNameController.text;
      final subjectCode = _subjectCodeController.text;
      final email = _emailController.text;
      final password = _passwordController.text; 

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
          String uid = userCredential.user?.uid ?? '';
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'first_name': firstName,
          'middle_name': middleName,
          'last_name': lastName,
          'subject_Name': subjectName,
          'subject_Code': subjectCode,
          'email_Address': email,
          'accountType': 'instructor',
          'Status': 'active',
          'uid': uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instructor account added successfully!')),
        );
        widget.closeAddInstructors();

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding instructor: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Instructor Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a first name' : null,
            ),
            TextFormField(
              controller: _middleNameController,
              decoration: InputDecoration(labelText: 'Middle Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a middle name' : null,
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a last name' : null,
            ),
            TextFormField(
              controller: _subjectNameController,
              decoration: InputDecoration(labelText: 'Subject Name'),
            ),
            TextFormField(
              controller: _subjectCodeController,
              decoration: InputDecoration(labelText: 'Subject Code'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email Address'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter an email address' : null,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter a password' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.closeAddInstructors,
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('Save'),
        ),
      ],
    );
  }
}
