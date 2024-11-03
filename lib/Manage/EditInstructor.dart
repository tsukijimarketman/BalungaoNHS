import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditInstructor extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeEditInstructors;
  final String? instructorId;

  const EditInstructor({
    super.key,
    required this.closeEditInstructors,
    required this.screenHeight,
    required this.screenWidth,
    this.instructorId,
  });

  @override
  State<EditInstructor> createState() => _EditInstructorState();
}

class _EditInstructorState extends State<EditInstructor> {
  final TextEditingController _subjectName = TextEditingController();
  final TextEditingController _subjectCode = TextEditingController();
  String _adviserStatus = '--'; // Default value for adviser status
  String? _selectedSection; // To store the selected section
  List<String> _sections = []; // To store section names

  @override
  void initState() {
    super.initState();
    _loadInstructorData(); // Load the instructor's existing data
    _fetchSections();
  }

  // Load the existing data for the instructor from Firestore
  Future<void> _loadInstructorData() async {
    if (widget.instructorId == null) return; // Ensure instructorId is not null

    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.instructorId)
          .get();

      if (doc.exists) {
        setState(() {
          _subjectName.text = doc.data()?['subject_Name'] ?? '';
          _subjectCode.text = doc.data()?['subject_Code'] ?? '';
          _adviserStatus = doc.data()?['adviserStatus'] ?? '--'; // Load adviser status

         String? handledSection = doc.data()?['handled_section'];
        _selectedSection = _sections.contains(handledSection) ? handledSection : null; // Validate section
      });
      } else {
        print('No document found for instructor ID: ${widget.instructorId}');
      }
    } catch (e) {
      print('Error loading instructor data: $e');
    }
  }

  Future<void> _fetchSections() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('sections').get();
    final sections = snapshot.docs.map((doc) => doc['section_name'] as String).toList(); // Assuming each section document has a 'section_name' field
    setState(() {
      _sections = sections; // Update sections list
      if (_selectedSection != null && !_sections.contains(_selectedSection)) {
        _selectedSection = null; // Reset if it doesn't exist
      }
    });
  } catch (e) {
    // Handle errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching sections: $e')),
    );
  }
}

  // Save the updated data to Firestore
  Future<void> _saveChanges() async {
    if (_subjectName.text.isEmpty || _subjectCode.text.isEmpty || _adviserStatus == '--') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields and select adviser status')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.instructorId).update({
        'subject_Name': _subjectName.text,
        'subject_Code': _subjectCode.text,
        'adviser': _adviserStatus, // Update adviser status
        'handled_section': _selectedSection, // Save selected section
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Instructor updated successfully')),
      );

      widget.closeEditInstructors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update instructor: $e')),
      );
    }
  }

  @override
  void dispose() {
    _subjectName.dispose();
    _subjectCode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.closeEditInstructors,
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: widget.screenWidth / 2,
                height: widget.screenHeight / 1.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: widget.closeEditInstructors,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child: Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Form title
                      Text(
                        'Edit Instructor',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Subject Name
                      TextFormField(
                        controller: _subjectName,
                        decoration: InputDecoration(
                          labelText: 'Subject Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter subject name',
                        ),
                      ),
                      SizedBox(height: 16),
                      // Subject Code
                      TextFormField(
                        controller: _subjectCode,
                        decoration: InputDecoration(
                          labelText: 'Subject Code',
                          border: OutlineInputBorder(),
                          hintText: 'Enter subject code',
                        ),
                      ),
                      SizedBox(height: 16),
                      // Adviser Status Dropdown
                      DropdownButtonFormField<String>(
                        value: _adviserStatus,
                        decoration: InputDecoration(labelText: 'Adviser Status', border: OutlineInputBorder(),),
                        items: [
                          DropdownMenuItem(value: '--', child: Text('--')),
                          DropdownMenuItem(value: 'yes', child: Text('Yes')),
                          DropdownMenuItem(value: 'no', child: Text('No')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _adviserStatus = value ?? '--';
                          });
                        },
                        validator: (value) {
                          if (value == '--') {
                            return 'Please select adviser status';
                          }
                          return null;
                        },
                      ),
                      if (_adviserStatus == 'yes') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedSection,
                          decoration: InputDecoration(labelText: 'Select Section'),
                          items: _sections.map((section) {
                            return DropdownMenuItem(
                              value: section,
                              child: Text(section),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSection = value; // Update selected section
                            });
                          },
                          validator: (value) => value == null ? 'Please select a section' : null,
                        ),
                      ],
                      SizedBox(height: 24),
                      // Save Changes button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: widget.screenWidth * 1,
                          height: widget.screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              elevation: 5, // Elevation level for shadow depth
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15), // Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                            ),
                            ),
                            child: Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 14,),),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
