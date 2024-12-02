import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pbma_portal/launcher.dart';
import 'package:pbma_portal/student_utils/student_ui.dart';

class ReEnrollForm extends StatefulWidget {
  const ReEnrollForm({super.key});

  @override
  State<ReEnrollForm> createState() => _ReEnrollFormState();
}

class _ReEnrollFormState extends State<ReEnrollForm> {
  final FocusNode _gradeLevelsFocusNode = FocusNode();
  final TextEditingController _gradeLevels = TextEditingController();
  String _selectedsemesters = '';

  Future<void> _updateEnrollment() async {
    if (_gradeLevels.text.isEmpty || _selectedsemesters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      // Sign out the user if they try to submit without filling all fields
      await FirebaseAuth.instance.signOut();
      print("User logged out successfully");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => Launcher()));
      return;
    }
    
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    print('User is not logged in.');
    return;
  }

  final semesterValue = 'Grade ${_gradeLevels.text} - ${_selectedsemesters}';
  final userUid = user.uid;

  try {
    // Query to find the document with the matching uid
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: userUid)
        .get();

    if (querySnapshot.docs.isEmpty) {
      print('No user document found for this UID.');
      return; // No document found
    }

    // Assuming there is only one document matching the UID
    final userDoc = querySnapshot.docs.first.reference;

    // Update the document with the new grade_level and semester
    await userDoc.update({
      'grade_level': _gradeLevels.text,
      'semester': semesterValue,
      'enrollment_status': 'reEnrollSubmitted'
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enrollment updated successfully!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => StudentUI()),
    );
  } catch (e) {
    // Handle any errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update enrollment: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: screenWidth / 2,
      height: screenHeight / 1.2,
        child: Padding(
          padding:  EdgeInsets.all(16.0), // Padding inside Card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Re-Enroll',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
               SizedBox(height: 24), // Space between title and input
              Container(
                width: 300,
                child: TextFormField(
                  controller: _gradeLevels,
                  focusNode: _gradeLevelsFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Grade Level',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 101, 100, 100),
                      fontSize: 16,
                    ),
                    suffixText: (_gradeLevelsFocusNode.hasFocus || _gradeLevels.text.isNotEmpty) ? '*' : '',
                    suffixStyle: TextStyle(color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your grade level';
                    }
                    return null;
                  },
                  onChanged: (text) {
                    setState(() {}); // Update to show/hide the asterisk dynamically
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
               SizedBox(height: 16), // Space between fields
              Container(
                width: 300,
                child: DropdownButtonFormField<String>(
                  value: _selectedsemesters.isEmpty ? null : _selectedsemesters,
                  decoration: InputDecoration(
                    labelText: 'Please select Semester',
                    labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  ),
                  items: ['1st Semester', '2nd Semester']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedsemesters = value!;
                    });
                  },
                ),
              ),
               SizedBox(height: 24), // Space before the button
              ElevatedButton(
                onPressed: _updateEnrollment,
                child: Text('Enroll'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
