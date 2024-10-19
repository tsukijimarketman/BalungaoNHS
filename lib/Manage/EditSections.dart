// lib/add_subjects_form.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class EditSectionsForm extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeEditSections;
  final String? sectionId;


  EditSectionsForm({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.closeEditSections,
    this.sectionId,

    
  });

  @override
  State<EditSectionsForm> createState() => _EditSectionsFormState();
}

class _EditSectionsFormState extends State<EditSectionsForm> {
  final TextEditingController _sectionName = TextEditingController();
  final TextEditingController _sectionAdviser = TextEditingController();
  final TextEditingController _sectionCapacity = TextEditingController();
  String? _selectedSemester = '--' ;


  final CollectionReference sectionsCollection =
      FirebaseFirestore.instance.collection('sections');

  @override
  void initState() {
    super.initState();
    _fetchSectionData();
  }

  // Fetch subject details from Firestore using the subjectId
  Future<void> _fetchSectionData() async {
    DocumentSnapshot sectionDoc = await sectionsCollection.doc(widget.sectionId).get();

    if (sectionDoc.exists) {
      Map<String, dynamic>? data = sectionDoc.data() as Map<String, dynamic>?;
      setState(() {
        _sectionName.text = data?['section_name'] ?? '';
        _sectionAdviser.text = data?['section_adviser'] ?? '';
        _selectedSemester = data?['semester'] ?? '--';
        _sectionCapacity.text = data?['section_capacity'] ?? '';
      });
    }
  }

  // Update the subject in Firestore
  Future<void> _updateSection() async {
    if (_sectionName.text.isEmpty || _sectionAdviser.text.isEmpty || _selectedSemester == '--' || _sectionCapacity.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await sectionsCollection.doc(widget.sectionId).update({
        'section_name': _sectionName.text,
        'section_adviser': _sectionAdviser.text,
        'semester': _selectedSemester,
        'section_capacity': _sectionCapacity.text,
        'updated_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Section updated successfully!')),
      );

      widget.closeEditSections();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating section: $e')),
      );
    }
  }

  @override
  void dispose() {
    _sectionName.dispose();
    _sectionAdviser.dispose();
    _sectionCapacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.closeEditSections,
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
                          onPressed: widget.closeEditSections,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child: Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Form title
                      Text(
                        'Edit Section',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      // Subject Name
                      TextFormField(
                        controller: _sectionName,
                        decoration: InputDecoration(
                          labelText: 'Section Name',
                          border: OutlineInputBorder(),
                          hintText: 'Enter section name',
                        ),
                      ),
                      SizedBox(height: 16),
                      // Subject Code
                      TextFormField(
                        controller: _sectionAdviser,
                        decoration: InputDecoration(
                          labelText: 'Section Adviser',
                          border: OutlineInputBorder(),
                          hintText: 'Enter section adviser',
                        ),
                      ),
                      SizedBox(height: 16),
                      // Semester Dropdown
                      DropdownButtonFormField<String>(
                        value: _selectedSemester,
                        decoration: InputDecoration(
                          labelText: 'Semester',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          '--',
                          'Grade 11 - 1st Semester',
                          'Grade 11 - 2nd Semester',
                          'Grade 12 - 1st Semester',
                          'Grade 12 - 2nd Semester'
                        ].map((semester) => DropdownMenuItem<String>(
                              value: semester,
                              child: Text(semester),
                            ))
                            .toList(),
                        onChanged: (val) {
                          _selectedSemester = val;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _sectionCapacity,
                        decoration: InputDecoration(
                          labelText: 'Section Capacity',
                          border: OutlineInputBorder(),
                          hintText: 'Enter section capacity',
                        ),
                      ),
                      // Save Changes button
                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: _updateSection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: Text('Save Changes'),
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
