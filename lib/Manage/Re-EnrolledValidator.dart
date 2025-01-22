import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReEnrolledValidator extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const ReEnrolledValidator({required this.studentData, super.key});

  @override
  State<ReEnrolledValidator> createState() => _ReEnrolledValidatorState();
}

class _ReEnrolledValidatorState extends State<ReEnrolledValidator> {
  bool _hovering = false;
  bool _isLoadingGrades = true; // Add this line
  Map<String, List<Map<String, String>>> semesterGrades = {};

  Future<void> _loadGrades() async {
    setState(() {
      _isLoadingGrades = true; // Set loading to true when starting
    });

    try {
      List<String> collectionsToCheck = [];

      // Determine the appropriate collections based on educ_level
      if (widget.studentData['educ_level'] == 'Junior High School') {
        collectionsToCheck = [
          '1st Quarter',
          '2nd Quarter',
          '3rd Quarter',
          '4th Quarter',
        ];
      } else if (widget.studentData['educ_level'] == 'Senior High School') {
        collectionsToCheck = [
          'Grade 11 - 1st Semester',
          'Grade 11 - 2nd Semester',
          'Grade 12 - 1st Semester',
          'Grade 12 - 2nd Semester',
        ];
      }

      // Clear previous grades
      semesterGrades.clear();

      // Get the student's UID from the passed studentData
      String studentUid = widget.studentData['uid'];

      for (String collectionName in collectionsToCheck) {
        QuerySnapshot gradeSnapshot =
            await FirebaseFirestore.instance.collection(collectionName).get();

        print('Checking collection: $collectionName');

        if (gradeSnapshot.docs.isNotEmpty) {
          List<Map<String, String>> gradesList = [];

          for (var gradeDoc in gradeSnapshot.docs) {
            var studentData = gradeDoc.data() as Map<String, dynamic>;

            studentData.forEach((studentKey, studentValue) {
              List<dynamic> gradesListFromDoc = studentValue['grades'] ?? [];

              for (var gradeEntry in gradesListFromDoc) {
                if (gradeEntry is Map<String, dynamic>) {
                  String uid = gradeEntry['uid'] ?? '';

                  // Check if the uid matches the student's uid from studentData
                  if (uid == studentUid) {
                    String subjectCode = gradeEntry['subject_code'] ?? '';
                    String subjectName = gradeEntry['subject_name'] ?? '';
                    String grade = gradeEntry['grade']?.toString() ?? '';

                    gradesList.add({
                      'subject_code': subjectCode,
                      'subject_name': subjectName,
                      'grade': grade,
                    });

                    print('Added grade: $grade for subject: $subjectName');
                  }
                }
              }
            });
          }

          if (gradesList.isNotEmpty) {
            semesterGrades[collectionName] = gradesList;
          }
        }
      }

      setState(() {
        // Update UI after loading grades
      });

      if (semesterGrades.isEmpty) {
        print('No grades found for student UID: $studentUid');
      }
      setState(() {
        _isLoadingGrades = false; // Set loading to false when complete
      });
    } catch (e) {
      print('Error loading grades: $e');
      setState(() {
        _isLoadingGrades = false; // Set loading to false on error
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

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
          // Breadcrumb Container (unchanged)
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
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
                          Navigator.pop(
                              context); // Go back to the previous page (Student List)
                        },
                        child: Text(
                          'Re-Enrolled Students',
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
                  // Left Card for Student Details (unchanged)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Text(
                                    'STUDENT',
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () {
                                      // Handle tap on profile picture
                                    },
                                    child: CircleAvatar(
                                      radius: 100,
                                      backgroundImage: widget
                                                  .studentData['image_url'] !=
                                              null
                                          ? NetworkImage(
                                              widget.studentData['image_url'])
                                          : NetworkImage(
                                              'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    '${widget.studentData['first_name'] ?? ''} ${widget.studentData['middle_name'] ?? ''} ${widget.studentData['last_name'] ?? ''} ${widget.studentData['extension_name'] ?? ''}',
                                    style: TextStyle(fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                      Icons.email,
                                      'Email Address',
                                      widget.studentData['email_Address'] ??
                                          ''),
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
                                  if (widget.studentData['educ_level'] ==
                                      'Senior High School') ...[
                                    _buildDetailRow(
                                        Icons.track_changes,
                                        'Track',
                                        widget.studentData[
                                                'seniorHigh_Track'] ??
                                            ''),
                                    _buildDetailRow(
                                        Icons.book,
                                        'Strand',
                                        widget.studentData[
                                                'seniorHigh_Strand'] ??
                                            ''),
                                  ],
                                  _buildDetailRow(
                                      Icons.groups,
                                      'Indigenous Group',
                                      widget.studentData['indigenous_group'] ??
                                          ''),
                                  _buildDetailRow(Icons.person, 'Father’s Name',
                                      widget.studentData['fathersName'] ?? ''),
                                  _buildDetailRow(Icons.person, 'Mother’s Name',
                                      widget.studentData['mothersName'] ?? ''),
                                  _buildDetailRow(
                                      Icons.person,
                                      'Guardian’s Name',
                                      widget.studentData['guardianName'] ?? ''),
                                  _buildDetailRow(
                                      Icons.group,
                                      'Guardian Relationship',
                                      widget.studentData[
                                              'relationshipGuardian'] ??
                                          ''),
                                  _buildDetailRow(
                                      Icons.phone,
                                      'Contact Number Guardian',
                                      widget.studentData['cellphone_number'] ??
                                          ''),
                                  if (widget.studentData['educ_level'] ==
                                      'Senior High School') ...[
                                    _buildDetailRow(
                                        Icons.school,
                                        'Junior High School',
                                        widget.studentData['juniorHS'] ?? ''),
                                    _buildDetailRow(
                                        Icons.location_city,
                                        'JHS Address',
                                        widget.studentData['schoolAdd'] ?? ''),
                                  ],
                                  _buildDetailRow(
                                      Icons.transfer_within_a_station,
                                      'Transferee',
                                      widget.studentData['transferee'] ?? ''),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  // Right Card for Student Profile (unchanged)
                  Expanded(
                      child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'REPORT CARD',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: _isLoadingGrades
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(),
                                          SizedBox(height: 16),
                                          Text('Loading grades...',
                                              style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                    )
                                  : SingleChildScrollView(
                                      physics: BouncingScrollPhysics(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ...semesterGrades.entries
                                              .map((entry) {
                                            String semester = entry
                                                .key; // e.g., 'Grade 11 - 1st Semester'
                                            List<
                                                Map<String,
                                                    String>> grades = entry
                                                .value; // List of grades for that semester

                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  semester,
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white,
                                                  child: Table(
                                                    border: TableBorder.all(
                                                        color: Colors.black),
                                                    columnWidths: {
                                                      if (widget.studentData[
                                                              'educ_level'] ==
                                                          'Senior High School')
                                                        0: FlexColumnWidth(2),
                                                      1: FlexColumnWidth(4),
                                                      2: FlexColumnWidth(2),
                                                    },
                                                    children: [
                                                      TableRow(children: [
                                                        if (widget.studentData[
                                                                'educ_level'] ==
                                                            'Senior High School') ...[
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                            child: Text(
                                                                'Course Code',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .black)),
                                                          ),
                                                        ],
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12.0),
                                                          child: Text('Subject',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  12.0),
                                                          child: Text('Grade',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                        ),
                                                      ]),
                                                      ...grades.map((subject) {
                                                        return TableRow(
                                                            children: [
                                                              if (widget.studentData[
                                                                      'educ_level'] ==
                                                                  'Senior High School') ...[
                                                                Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              12.0),
                                                                  child: Text(
                                                                      subject['subject_code'] ??
                                                                          '',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.black)),
                                                                ),
                                                              ],
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            12.0),
                                                                child: Text(
                                                                    subject['subject_name'] ??
                                                                        '',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            12.0),
                                                                child: Text(
                                                                    subject['grade'] ??
                                                                        'N/A',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black)),
                                                              ),
                                                            ]);
                                                      }).toList(),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                              ],
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                            ),
                          ]),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build detail rows (unchanged)
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
