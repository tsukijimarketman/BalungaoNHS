import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentInSection extends StatefulWidget {
  final String sectionName;

  StudentInSection({required this.sectionName});

  @override
  State<StudentInSection> createState() => _StudentInSectionState();
}

class _StudentInSectionState extends State<StudentInSection> {
  // Method to fetch students from Firestore
  Future<QuerySnapshot> _fetchStudentsInSection() async {
    return await FirebaseFirestore.instance
        .collection('users') // Replace with your actual students collection
        .where('accountType', isEqualTo: 'student')
        .where('section', isEqualTo: widget.sectionName) // Assuming each student has a section_id field
        .get();
  }

  Future<List<String>> _fetchSections() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('sections').get();
    // Extract section names
    List<String> sections = snapshot.docs.map((doc) => doc['section_name'] as String).toList();
    return sections;
  }

  // Show Cupertino Dialog for section selection
  void _showSectionDialog(BuildContext context, String studentId, String currentSection) async {
    String selectedSection = currentSection; // Store the currently selected section

    // Fetch sections from Firestore
    List<String> sections = await _fetchSections();

    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Select Section'),
          content: Material(  // Wrap the content in a Material widget
            color: Colors.transparent,  // Make it transparent to blend with Cupertino style
            child: Column(
              children: [
                // Dropdown for section selection
                StatefulBuilder(
                  builder: (context, setState) {
                    return DropdownButton<String>(
                      value: selectedSection,
                      items: sections.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSection = newValue!;
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
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            // Save button
            CupertinoDialogAction(
              child: Text('Save'),
              onPressed: () async {
                // Update the section for the student in Firestore
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(studentId)
                    .update({'section': selectedSection});
                
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
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final students = snapshot.data!.docs;

          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: const <int, TableColumnWidth>{
                0: FixedColumnWidth(40.0),
                1: FlexColumnWidth(),
                2: FlexColumnWidth(),
                3: FlexColumnWidth(),
                4: FlexColumnWidth(),
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
                        icon: Icon(Icons.edit_document, color: Colors.blue,)),)
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}