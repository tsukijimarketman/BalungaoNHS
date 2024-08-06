import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  final String firstName;
  final String middleName;
  final String lastName;

  const StudentDashboard({
    Key? key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome, $firstName $middleName $lastName!',
              style: TextStyle(fontSize: 30, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
