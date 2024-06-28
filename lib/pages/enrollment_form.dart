import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/home_address.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/junior_high_school.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/parent_information.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/senior_high_school.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/student_information.dart';

class EnrollmentForm extends StatelessWidget {
  // Define the _formKey
  final _formKey = GlobalKey<FormState>();

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
              StudentInformation(spacing:spacing),

              SizedBox(height: 30),
              HomeAddress(spacing:spacing),

              SizedBox(height: 30),
              ParentInformation(spacing:spacing),

              SizedBox(height: 30),
              JuniorHighSchool(),

              SizedBox(height: 30),
              SeniorHighSchool(),

              SizedBox(height: 30),
              Center(
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In a real app,
                    // you would often call a server or save the information in a database.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Processing Data')),
                    );
                  }
                },
                child: Text('Submit'),
                style: ButtonStyle(
                  foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                    if (states.contains(MaterialState.pressed)) {
                      return Colors.green; // Change text color when pressed
                    }
                    return Colors.blue; // Default text color
                  }),
                ),
              ),
            )

            ],
          ),
        ),
      ),
    );
  }

    
}