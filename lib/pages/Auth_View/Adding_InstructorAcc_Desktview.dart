import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddInstructorDialog extends StatefulWidget {
  final VoidCallback closeAddInstructors;

  AddInstructorDialog({
    super.key,
    required this.closeAddInstructors,
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

  String _adviserStatus = '--'; // Default value for adviser status
  String? _selectedSection; // To store the selected section
  List<String> _sections = []; // To store section names

  @override
  void initState() {
    super.initState();
    _fetchSections(); // Fetch sections when the dialog is initialized
  }

  Future<void> _fetchSections() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('sections').get();
      final sections = snapshot.docs.map((doc) => doc['section_name'] as String).toList(); // Assuming each section document has a 'name' field
      setState(() {
        _sections = sections; // Update sections list
      });
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sections: $e')),
      );
    }
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_adviserStatus == '--') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a valid adviser status (Yes or No).')),
        );
        return; // Exit the method if adviser status is invalid
      }

      final firstName = _firstNameController.text;
      final middleName = _middleNameController.text;
      final lastName = _lastNameController.text;
      final subjectName = _subjectNameController.text;
      final subjectCode = _subjectCodeController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      String handledSectionValue;

    // Set handled section based on adviser status
    if (_adviserStatus == 'yes') {
      handledSectionValue = _selectedSection ?? 'N/A'; // Use selected section or 'N/A' if none selected
    } else {
      handledSectionValue = 'N/A'; // Default to 'N/A' if adviser status is 'no'
    }

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
          'adviser': _adviserStatus, // Save adviser status
          'handled_section': handledSectionValue, // Save selected section if applicable
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
            DropdownButtonFormField<String>(
              value: _adviserStatus,
              decoration: InputDecoration(labelText: 'Adviser Status'),
              items: [
                DropdownMenuItem(value: '--', child: Text('--')),
                DropdownMenuItem(value: 'yes', child: Text('Yes')),
                DropdownMenuItem(value: 'no', child: Text('No')),
              ],
              onChanged: (value) {
                setState(() {
                  _adviserStatus = value ?? '--';
                  _selectedSection = null; // Reset selected section when adviser status changes
                });
              },
              validator: (value) => value == null ? 'Please select adviser status' : null,
            ),
            if (_adviserStatus == 'yes') ...[
              DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: InputDecoration(labelText: 'Select Section'),
                items: _sections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSection = value; // Update selected section
                  });
                },
                validator: (value) => value == null ? 'Please select a section' : null,
              ),
            ],
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
