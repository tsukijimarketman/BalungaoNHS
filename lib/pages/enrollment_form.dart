import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/home_address.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/junior_high_school.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/parent_information.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/senior_high_school.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/student_information.dart';

class EnrollmentForm extends StatefulWidget {
  @override
  State<EnrollmentForm> createState() => _EnrollmentFormState();
}

class _EnrollmentFormState extends State<EnrollmentForm> {
  // Define the _formKey
  final _formKey = GlobalKey<FormState>();

  Map<String, dynamic> _studentData = {};
  Map<String, dynamic> _homeAddressData = {};
  Map<String, dynamic> _juniorHSData = {};
  Map<String, dynamic> _parentInfoData = {};
  Map<String, dynamic> _seniorHSData = {};

  void _updateStudentData(Map<String, dynamic> data) {
    setState(() {
      _studentData = {..._studentData, ...data};
    });
  }

  void _updateHomeAddressData(Map<String, dynamic> data) {
    setState(() {
      _homeAddressData = data;
    });
  }

  void _updateJuniorHSData(Map<String, dynamic> data) {
    setState(() {
      _juniorHSData = data;
    });
  }

  void _updateParentInfo(Map<String, dynamic> data) {
    setState(() {
      _parentInfoData = data;
    });
  }

  void _updateSeniorHS(Map<String, dynamic> data) {
    setState(() {
      _seniorHSData = data;
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final combinedData = {
        ..._studentData, 
        ..._homeAddressData, 
        ..._juniorHSData, 
        ..._parentInfoData, 
        ..._seniorHSData, 
        'enrollment_status': 'pending'
        };

      FirebaseFirestore.instance.collection('users').add(combinedData).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data Saved Successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Save Data: $error')),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // Get the screen size
    final Size screenSize = MediaQuery.of(context).size;

    // Calculate responsive widths
    double formFieldWidth = screenSize.width > 600 ? 300 : screenSize.width * 0.9;
    double spacing = 50.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Go Back to Dashboard'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        
        child: Form(
          key: _formKey, // Use the _formKey here
          child: ListView(
            children: [
              StudentInformation(spacing:spacing, onDataChanged: _updateStudentData,),

              SizedBox(height: 30),
              HomeAddress(spacing:spacing, onDataChanged: _updateStudentData,),

              SizedBox(height: 30),
              ParentInformation(spacing:spacing, onDataChanged: _updateStudentData,),

              SizedBox(height: 30),
              JuniorHighSchool(onDataChanged: _updateStudentData,),

              SizedBox(height: 30),
              SeniorHighSchool(spacing:spacing, onDataChanged: _updateStudentData,),

              SizedBox(height: 30),
              Center(
              child: TextButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                  style: ButtonStyle(
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.green;
                      }
                      return Colors.blue;
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}