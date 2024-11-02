import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddInstructorDialog extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeAddInstructors;

  AddInstructorDialog({
    super.key,
    required this.closeAddInstructors,
    required this.screenWidth,
    required this.screenHeight,
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
    return GestureDetector(
      onTap: widget.closeAddInstructors,
      child: Stack(
        children: [          
          Center(
            child: GestureDetector(
              onTap: (){},
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: widget.screenWidth / 2,
                height: widget.screenHeight / 1.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: widget.closeAddInstructors,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child: Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Add Instructor Account',style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                      SizedBox(height: 8),
                       Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter a first name' : null,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _middleNameController,
                              decoration: InputDecoration(
                              labelText: 'Middle Name',
                              border: OutlineInputBorder(),
                              ),
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter a middle name' : null,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder(),),
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter a last name' : null,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _subjectNameController,
                              decoration: InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder(),),
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _subjectCodeController,
                              decoration: InputDecoration(labelText: 'Subject Code', border: OutlineInputBorder(),),
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _adviserStatus,
                              decoration: InputDecoration(labelText: 'Adviser Status', border: OutlineInputBorder(),),
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
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'Email Address', border: OutlineInputBorder(),),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter an email address' : null,
                            ),
                            SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder(),),
                              obscureText: true,
                              validator: (value) => value?.isEmpty ?? true ? 'Please enter a password' : null,
                            ),
                          ],
                        ),
                      ),
                                            SizedBox(height: 20),

                        Container(
                          width: widget.screenWidth * 1,
                          height: widget.screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                elevation: 5, // Elevation level for shadow depth
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                              ),
                              ),
                              child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 14,),),
                            ),
                        ),
                      ],
                              ),
                  ),
                ),
              ),
            ),
        ]
      ),
    );
  }
}
