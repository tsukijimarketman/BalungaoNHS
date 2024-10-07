import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StudentDetails extends StatefulWidget {
  final Map<String, dynamic> studentData;

  StudentDetails({required this.studentData});

  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  bool _hovering = false; // Hover state for the "Go back to Students" link

  @override
  Widget build(BuildContext context) {
    String combinedAddress = [
      widget.studentData['house_number'] ?? '',
      widget.studentData['street_name'] ?? '',
      widget.studentData['subdivision_barangay'] ?? '',
      widget.studentData['city_municipality'] ?? '',
      widget.studentData['province'] ?? '',
      widget.studentData['country'] ?? '',
    ].where((s) => s.isNotEmpty).join(', ');

    return Scaffold(
      body: Column(
        children: [
          // Breadcrumb Container
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // MouseRegion for hover effect on 'Go back to Students'
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) {
                        setState(() {
                          _hovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _hovering = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Go back to the previous page (Student List)
                        },
                        child: Text(
                          'Student List',
                          style: TextStyle(
                            color: _hovering ? Colors.blue : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Student Details',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left Card for Student Details
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Student Details',
                              //   style: TextStyle(
                              //       fontSize: 24, fontWeight: FontWeight.bold),
                              // ),
                              // SizedBox(height: 16),
                              _buildDetailRow(Icons.tag, 'Student Number',
                                  widget.studentData['student_id'] ?? ''),
                              _buildDetailRow(Icons.email, 'Email Address',
                                  widget.studentData['email_Address'] ?? ''),
                              _buildDetailRow(Icons.location_on, 'Address',
                                  combinedAddress),
                              _buildDetailRow(Icons.phone, 'Contact Number',
                                  widget.studentData['phone_number'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Birthday',
                                  widget.studentData['birthdate'] ?? ''),
                              _buildDetailRow(Icons.person, 'Age',
                                  widget.studentData['age'] ?? ''),
                              _buildDetailRow(Icons.person, 'Gender',
                                  widget.studentData['gender'] ?? ''),
                              _buildDetailRow(Icons.grade, 'Grade',
                                  widget.studentData['grade_level'] ?? ''),
                              _buildDetailRow(Icons.track_changes, 'Track',
                                  widget.studentData['seniorHigh_Track'] ?? ''),
                              _buildDetailRow(Icons.book, 'Strand',
                                  widget.studentData['seniorHigh_Strand'] ?? ''),
                              _buildDetailRow(Icons.groups, 'Indigenous Group',
                                  widget.studentData['indigenous_group'] ?? ''),
                              _buildDetailRow(Icons.person, 'Father’s Name',
                                  widget.studentData['fathersName'] ?? ''),
                              _buildDetailRow(Icons.person, 'Mother’s Name',
                                  widget.studentData['mothersName'] ?? ''),
                              _buildDetailRow(Icons.person, 'Guardian’s Name',
                                  widget.studentData['guardianName'] ?? ''),
                              _buildDetailRow(Icons.group, 'Guardian Relationship',
                                  widget.studentData['relationshipGuardian'] ?? ''),
                              _buildDetailRow(Icons.school, 'Junior High School',
                                  widget.studentData['juniorHS'] ?? ''),
                              _buildDetailRow(Icons.location_city, 'JHS Address',
                                  widget.studentData['schoolAdd'] ?? ''),
                              _buildDetailRow(Icons.transfer_within_a_station, 'Transferee',
                                  widget.studentData['transferee'] ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  // Right Card for Student Profile
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '${widget.studentData['accountType']?.toUpperCase() ?? ''}',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                // Handle tap on profile picture
                              },
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: widget.studentData['image_url'] != null
                                    ? NetworkImage(widget.studentData['image_url'])
                                    : NetworkImage(
                                        'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '${widget.studentData['first_name'] ?? ''} ${widget.studentData['middle_name'] ?? ''} ${widget.studentData['last_name'] ?? ''} ${widget.studentData['extension_name'] ?? ''}',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(widget.studentData['email_Address'] ?? ''),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build detail rows
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
