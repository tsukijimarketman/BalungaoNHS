import 'package:flutter/material.dart';

class StudentDetails extends StatelessWidget {
  final Map<String, dynamic> studentData;

  StudentDetails({required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Details'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ADMIN',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  'admin123@gmail.com',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          CircleAvatar(
            child: Icon(Icons.person),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Details',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildDetailRow(Icons.tag, 'Student Number', studentData['student_id'] ?? ''),
                      _buildDetailRow(Icons.email, 'Email Address', studentData['email_address'] ?? ''),
                      _buildDetailRow(Icons.location_on, 'Address', studentData['address'] ?? ''),
                      _buildDetailRow(Icons.phone, 'Contact Number', studentData['contact_number'] ?? ''),
                      _buildDetailRow(Icons.cake, 'Birthday', studentData['birthday'] ?? ''),
                      _buildDetailRow(Icons.grade, 'Grade', studentData['grade_level'] ?? ''),
                      _buildDetailRow(Icons.track_changes, 'Track', studentData['seniorHigh_Track'] ?? ''),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Student',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      CircleAvatar(
                        radius: 40,
                        child: Icon(Icons.person, size: 40),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '${studentData['first_name']} ${studentData['last_name']}',
                        style: TextStyle(fontSize: 20),
                      ),
                      Text(studentData['email_address'] ?? ''),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
