import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddingSections extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeAddSections;

  const AddingSections({
    required this.screenHeight,
    required this.screenWidth,
    required this.closeAddSections,
    super.key});

  @override
  State<AddingSections> createState() => _AddingSectionsState();
}

class _AddingSectionsState extends State<AddingSections> {
  final TextEditingController _sectionName = TextEditingController();
  final TextEditingController _sectionAdviser = TextEditingController();
  final TextEditingController _sectionCapacity = TextEditingController();
  String? _selectedSemester = '--' ;

  final CollectionReference subjectsCollection =
      FirebaseFirestore.instance.collection('sections');

  @override
  void dispose() {
    _sectionName.dispose();
    _sectionAdviser.dispose();
    _sectionCapacity.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    // Basic validation before saving
    if (_sectionName.text.isEmpty || _sectionAdviser.text.isEmpty || _selectedSemester == '--') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Create a document in Firestore
      await subjectsCollection.add({
        'section_name': _sectionName.text,
        'section_adviser': _sectionAdviser.text,
        'semester': _selectedSemester,
        'section_capacity': _sectionCapacity.text,
        'created_at': Timestamp.now(),
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject added successfully!')),
      );

      widget.closeAddSections();

      // Clear the form after saving
      _sectionName.clear();
      _sectionAdviser.clear();
      _sectionCapacity.clear();
      setState(() {
        _selectedSemester = '--';
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding subject: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.closeAddSections,
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
                          onPressed: widget.closeAddSections,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child: Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Form title
                      Text(
                        'Add New Section',
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
                      SizedBox(height: 24),
                      // Save Changes button
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: _saveSubject,
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
