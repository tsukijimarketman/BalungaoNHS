import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class JHSStudentInSection extends StatefulWidget {
    final String sectionName;

  const JHSStudentInSection({required this.sectionName});

  @override
  State<JHSStudentInSection> createState() => _JHSStudentInSectionState();
}

class _JHSStudentInSectionState extends State<JHSStudentInSection> {
  // Method to fetch students from Firestore
  Future<QuerySnapshot> _fetchStudentsInSection() async {
    return await FirebaseFirestore.instance
        .collection('users') // Replace with your actual students collection
        .where('accountType', isEqualTo: 'student')
                .where('educ_level', isEqualTo: 'Junior High School')

        .where('section', isEqualTo: widget.sectionName) // Assuming each student has a section_id field
        .get();
  }

  Future<List<Map<String, String>>> _fetchSections() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('sections')
      .where('educ_level', isEqualTo: 'Junior High School')
      .get();

  // Extract section names and advisers
  List<Map<String, String>> sections = snapshot.docs.map((doc) {
    return {
      'section_name': doc['section_name'] as String,
      'section_adviser': doc['section_adviser'] as String, // Assuming section_adviser is stored here
    };
  }).toList();

  return sections;
}

  // Show Cupertino Dialog for section selection
  void _showSectionDialog(BuildContext context, String studentId, String currentSection) async {
  String selectedSection = currentSection; // Store the currently selected section
  String selectedAdviser = ''; // Variable to store section adviser

  // Fetch sections from Firestore
  List<Map<String, String>> sections = await _fetchSections();

  showCupertinoDialog(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text('Select Section'),
        content: Material( // Wrap the content in a Material widget
          color: Colors.transparent, // Make it transparent to blend with Cupertino style
          child: Column(
            children: [
              // Dropdown for section selection
               StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<String>(
                      value: selectedSection,
                    items: sections.map<DropdownMenuItem<String>>((Map<String, String> section) {
                        return DropdownMenuItem<String>(
                          value: section['section_name'],
                        child: Text(section['section_name']!),
                      );
                    }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                        selectedSection = newValue!;
                        // Update adviser based on selected section
                        selectedAdviser = sections.firstWhere((section) => section['section_name'] == newValue)['section_adviser']!;
                      });
                      },
                    );
                  },
                ),
            ],
          ),
        ),
        actions: [
          // Cancel button
          CupertinoDialogAction(
            child: Text('Cancel', style: TextStyle(color: Colors.red),),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          // Save button
          CupertinoDialogAction(
              child: Text('Save', style: TextStyle(color: Colors.blue),),
              onPressed: () async {
                // Update the section for the student in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(studentId)
                    .update({'section': selectedSection});

                     // Step 2: Retrieve the student's 'sections' subcollection
      QuerySnapshot sectionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .collection('sections')
          .get();

      // Step 3: Loop through the sections to find the relevant document (if needed)
      if (sectionsSnapshot.docs.isNotEmpty) {
        for (var doc in sectionsSnapshot.docs) {
          // Step 4: Update the selected section in the matching section document
          await doc.reference.update({'selectedSection': selectedSection});
                  await doc.reference.update({'section_adviser': selectedAdviser});
                  print('Updated selectedSection and section_adviser in section subcollection: ${doc.id}');
                }
              }

                
                Navigator.of(context).pop(); // Close the dialog
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Students in Section'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _fetchStudentsInSection(), // Call the new method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
          child: DefaultTextStyle(
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('LOADING...'),
              ],
              isRepeatingAnimation: true,
            ),
          ),
        );
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final students = snapshot.data!.docs;

          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                border: TableBorder.all(color: Colors.grey),
                columnWidths: const <int, TableColumnWidth>{
                  0: FixedColumnWidth(40.0),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FlexColumnWidth(),
                  4: FlexColumnWidth(),
                  5: IntrinsicColumnWidth(),           
                },
                children: [
                  // Header Row
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey[200]), // Header background color
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('No', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('First Name', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Education Level', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Section', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Data Rows
                  for (var i = 0; i < students.length; i++)
                    TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text((i + 1).toString()),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(students[i]['first_name'] ?? 'N/A'), // Adjust field name accordingly
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(students[i]['student_id'] ?? 'N/A'), // Adjust field name accordingly
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(students[i]['educ_level'] ?? 'N/A'), // Adjust field name accordingly
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(students[i]['section'] ?? 'N/A'), // Assuming this field exists
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: (){
                             _showSectionDialog(
                                context,
                                students[i].id, // Pass the student ID
                                students[i]['section'] ?? 'N/A', 
                             );
                          }, 
                          icon: Icon(Icons.edit_note_rounded, color: Colors.blue,)),)
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}