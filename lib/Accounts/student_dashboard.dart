import 'package:flutter/material.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('This is Student Dashboard', style: TextStyle(fontSize: 30, color: Colors.red),),
    );
  }
}