import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/student_utils/student_ui.dart';

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
    if (_gradeLevels.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
            SizedBox(width: 10),
            Text('Please fill in all fields'),
          ],
        )),
      );
      // Sign out the user if they try to submit without filling all fields
      await FirebaseAuth.instance.signOut();
      print("User logged out successfully");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => Launcher(scrollToFooter: false,)));
      return;
    }
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('User is not logged in.');
      return;
    }

    final gradeLevel = _gradeLevels.text;
    final semesterValue = _selectedsemesters.isNotEmpty ? 'Grade $gradeLevel - $_selectedsemesters' : null;
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

      // Update the document with the new grade_level and possibly semester
      if (semesterValue != null) {
        await userDoc.update({
          'grade_level': gradeLevel,
          'semester': semesterValue,
          'enrollment_status': 'reEnrollSubmitted'
        });
      } else {
        await userDoc.update({
          'grade_level': gradeLevel,
          'enrollment_status': 'reEnrollSubmitted'
        });
      }

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
            SizedBox(width: 10),
            Text('Enrollment updated successfully!'),
          ],
        )),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => StudentUI()),
      );
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to update enrollment: $e'),
          ],
        )),
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
          padding: EdgeInsets.all(16.0), // Padding inside Card
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
                child: DropdownButtonFormField<String>(
                  value: _gradeLevels.text.isEmpty ? null : _gradeLevels.text,
                  decoration: InputDecoration(
                    labelText: 'Grade Level',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 101, 100, 100),
                      fontSize: 16,
                    ),
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
                  items: ['7', '8', '9', '10', '11', '12']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _gradeLevels.text = value!;
                      if (value == '7' || value == '8' || value == '9' || value == '10') {
                        _selectedsemesters = '';
                      }
                    });
                  },
                ),
              ),
               SizedBox(height: 16), // Space between fields
              if (_gradeLevels.text == '11' || _gradeLevels.text == '12')
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
