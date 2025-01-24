import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class AddSubjectsForm extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeAddSubjects;

  AddSubjectsForm({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.closeAddSubjects,
  });

  @override
  State<AddSubjectsForm> createState() => _AddSubjectsFormState();
}

class _AddSubjectsFormState extends State<AddSubjectsForm> {
  final TextEditingController _subjectName = TextEditingController();
  final TextEditingController _subjectCode = TextEditingController();
  final TextEditingController _gradeLevel = TextEditingController();
  final TextEditingController _quarter = TextEditingController();

  final TextEditingController _musicController = TextEditingController();
  final TextEditingController _artsController = TextEditingController();
  final TextEditingController _peController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();
  
  String? _selectedCategory = '--';
  String? _selectedSemester = '--';
  String? _selectedCourse = '--';
  String? _selectedEducationLevel = '--';
  bool _isMapeh = false; // Flag to check if "MAPEH" is typed

  final CollectionReference subjectsCollection =
      FirebaseFirestore.instance.collection('subjects');

  @override
  void dispose() {
    _subjectName.dispose();
    _subjectCode.dispose();
    _gradeLevel.dispose();
    _quarter.dispose();
    _musicController.dispose();
    _artsController.dispose();
    _peController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    if (_selectedEducationLevel == '--') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Please select an education level'),
          ],
        )),
      );
      return;
    }

    if (_selectedEducationLevel == 'Junior High School') {
      if (_subjectName.text.isEmpty || _gradeLevel.text.isEmpty || _quarter.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Row(
            children: [
              Image.asset('balungaonhs.png', scale: 40),
              SizedBox(width: 10),
              Text('Please fill all fields'),
            ],
          )),
        );
        return;
      }
    } else {
      if (_subjectName.text.isEmpty ||
          _subjectCode.text.isEmpty ||
          _selectedCategory == '--' || 
          _selectedSemester == '--' || 
          _selectedCourse == '--') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Row(
            children: [
              Image.asset('balungaonhs.png', scale: 40),
              SizedBox(width: 10),
              Text('Please fill all fields'),
            ],
          )),
        );
        return;
      }
    } 

    try {
      final Map<String, dynamic> subjectData = {
        'educ_level': _selectedEducationLevel,
        'created_at': Timestamp.now(),
      };

      if (_selectedEducationLevel == 'Junior High School') {
        if (_isMapeh) {
          // Add MAPEH and subfields
          subjectData.addAll({
            'subject_name': 'MAPEH',
            'grade_level': _gradeLevel.text,
            'quarter': _quarter.text,
            'sub_subjects': {
              'Music': _musicController.text,
              'Arts': _artsController.text,
              'Physical Education': _peController.text,
              'Health': _healthController.text,
            },
          });
        } else {
          subjectData.addAll({
            'subject_name': _subjectName.text,
            'grade_level': _gradeLevel.text,
            'quarter': _quarter.text,
          });
        }
          } else {
        subjectData.addAll({
          'strandcourse': _selectedCourse,
          'subject_name': _subjectName.text,
          'subject_code': _subjectCode.text,
          'category': _selectedCategory,
          'semester': _selectedSemester,
        });
      }

      await subjectsCollection.add(subjectData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Subject added successfully!'),
          ],
        )),
      );

      widget.closeAddSubjects();

      _subjectName.clear();
      _subjectCode.clear();
      _gradeLevel.clear();
      _quarter.clear();
      _musicController.clear();
      _artsController.clear();
      _peController.clear();
      _healthController.clear();
      setState(() {
        _selectedEducationLevel = '--';
        _selectedCourse = '--';
        _selectedCategory = '--';
        _selectedSemester = '--';
        _isMapeh = false;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Error adding subject: $e'),
          ],
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.closeAddSubjects,
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
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: widget.closeAddSubjects,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child: Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add New Subject',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      
                      // Education Level Dropdown (always shown)
                      DropdownButtonFormField<String>(
                        value: _selectedEducationLevel,
                        decoration: InputDecoration(
                          labelText: 'Education Level',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          '--',
                          'Junior High School',
                          'Senior High School',
                        ].map((level) => DropdownMenuItem<String>(
                              value: level,
                              child: Text(level),
                            ))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedEducationLevel = val;
                            _isMapeh = false; // Reset MAPEH flag
                            // Clear other fields when education level changes
                            _subjectName.clear();
                            _subjectCode.clear();
                            _gradeLevel.clear();
                            _quarter.clear();
                            _selectedCourse = '--';
                            _selectedCategory = '--';
                            _selectedSemester = '--';
                          });
                        },
                      ),
                      SizedBox(height: 16),

                      // Conditional form fields based on education level
                      if (_selectedEducationLevel == 'Junior High School') ...[
                        TextFormField(
                          controller: _subjectName,
                          decoration: InputDecoration(
                            labelText: 'Subject Name',
                            border: OutlineInputBorder(),
                            hintText: 'Enter subject name',
                          ),
                          onChanged: (value) {
                            setState(() {
                              _isMapeh = value.trim().toUpperCase() == 'MAPEH';
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        if (_isMapeh) ...[
                          Text('MAPEH Subfields', style: TextStyle(fontWeight: FontWeight.bold)),
                          TextFormField(
                            controller: _musicController,
                            decoration: InputDecoration(
                              labelText: 'Music',
                              border: OutlineInputBorder(),
                              hintText: 'Enter Music details',
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _artsController,
                            decoration: InputDecoration(
                              labelText: 'Arts',
                              border: OutlineInputBorder(),
                              hintText: 'Enter Arts details',
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _peController,
                            decoration: InputDecoration(
                              labelText: 'Physical Education',
                              border: OutlineInputBorder(),
                              hintText: 'Enter Physical Education details',
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: _healthController,
                            decoration: InputDecoration(
                              labelText: 'Health',
                              border: OutlineInputBorder(),
                              hintText: 'Enter Health details',
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _gradeLevel,
                          decoration: InputDecoration(
                            labelText: 'Grade Level',
                            border: OutlineInputBorder(),
                            hintText: 'Enter grade level (e.g., 7, 8, 9, 10)',
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _quarter,
                          decoration: InputDecoration(
                            labelText: 'Quarter',
                            border: OutlineInputBorder(),
                            hintText: 'Enter quarter (1st, 2nd, 3rd, 4th)',
                          ),
                        ),
                      ] else if (_selectedEducationLevel == 'Senior High School') ...[
                        DropdownButtonFormField<String>(
                          value: _selectedCourse,
                          decoration: InputDecoration(
                            labelText: 'Course',
                            border: OutlineInputBorder(),
                          ),
                          items: ['--', 'ABM', 'STEM', 'HUMSS', 'ICT', 'HE', 'IA']
                              .map((strandcourse) => DropdownMenuItem<String>(
                                    value: strandcourse,
                                    child: Text(strandcourse),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCourse = val;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _subjectName,
                          decoration: InputDecoration(
                            labelText: 'Subject Name',
                            border: OutlineInputBorder(),
                            hintText: 'Enter subject name',
                          ),
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _subjectCode,
                          decoration: InputDecoration(
                            labelText: 'Subject Code',
                            border: OutlineInputBorder(),
                            hintText: 'Enter subject code',
                          ),
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: ['--', 'Core', 'Applied', 'Specialized']
                              .map((category) => DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedCategory = val;
                            });
                          },
                        ),
                        SizedBox(height: 16),
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
                            setState(() {
                              _selectedSemester = val;
                            });
                          },
                        ),
                      ],

                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: widget.screenWidth * 1,
                          height: widget.screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed: _saveSubject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              elevation: 5,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
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