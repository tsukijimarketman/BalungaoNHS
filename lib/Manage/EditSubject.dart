import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditSubjectsForm extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeEditSubjects;
  final String? subjectId;

  EditSubjectsForm({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
    required this.closeEditSubjects,
    this.subjectId,
  });

  @override
  State<EditSubjectsForm> createState() => _EditSubjectsFormState();
}

class _EditSubjectsFormState extends State<EditSubjectsForm> {
  final TextEditingController _subjectName = TextEditingController();
  final TextEditingController _subjectCode = TextEditingController();
  String? _selectedCategory = '--';
  String? _selectedSemester = '--';
  String? _selectedCourse = '--';
  String? _selectedEducationLevel = '--';

  final CollectionReference subjectsCollection =
      FirebaseFirestore.instance.collection('subjects');

  @override
  void initState() {
    super.initState();
    _fetchSubjectData();
  }

  Future<void> _fetchSubjectData() async {
    DocumentSnapshot subjectDoc = await subjectsCollection.doc(widget.subjectId).get();

    if (subjectDoc.exists) {
      Map<String, dynamic>? data = subjectDoc.data() as Map<String, dynamic>?;
      setState(() {
        _selectedCourse = data?['strandcourse'] ?? '--';
        _subjectName.text = data?['subject_name'] ?? '';
        _subjectCode.text = data?['subject_code'] ?? '';
        _selectedCategory = data?['category'] ?? '--';
        _selectedSemester = data?['semester'] ?? '--';
        _selectedEducationLevel = data?['education_level'] ?? '--';
      });
    }
  }

  Future<void> _updateSubject() async {
    if (_selectedCategory == '--' ||
        _subjectName.text.isEmpty ||
        _subjectCode.text.isEmpty ||
        _selectedCourse == '--' ||
        _selectedSemester == '--' ||
        _selectedEducationLevel == '--') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.asset('PBMA.png', scale: 40),
              SizedBox(width: 10),
              Text('Please fill all fields'),
            ],
          ),
        ),
      );
      return;
    }

    try {
      await subjectsCollection.doc(widget.subjectId).update({
        'strandcourse': _selectedCourse,
        'subject_name': _subjectName.text,
        'subject_code': _subjectCode.text,
        'category': _selectedCategory,
        'semester': _selectedSemester,
        'education_level': _selectedEducationLevel,
        'updated_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.asset('PBMA.png', scale: 40),
              SizedBox(width: 10),
              Text('Subject updated successfully!'),
            ],
          ),
        ),
      );

      widget.closeEditSubjects();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.asset('PBMA.png', scale: 40),
              SizedBox(width: 10),
              Text('Error updating subject: $e'),
            ],
          ),
        ),
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
      onTap: widget.closeEditSubjects,
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
        onPressed: widget.closeEditSubjects,
        style: TextButton.styleFrom(
          side: BorderSide(color: Colors.red),
        ),
        child: Text('Back', style: TextStyle(color: Colors.red)),
      ),
    ),
    SizedBox(height: 8),
    Text(
      'Edit Subject',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    SizedBox(height: 16),
    DropdownButtonFormField<String>(
      value: _selectedEducationLevel,
      decoration: InputDecoration(
        labelText: 'Education Level',
        border: OutlineInputBorder(),
      ),
      items: ['--', 'Junior High School', 'Senior High School']
          .map((level) => DropdownMenuItem<String>(
                value: level,
                child: Text(level),
              ))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedEducationLevel = val;
        });
      },
    ),
    SizedBox(height: 16),
    DropdownButtonFormField<String>(
      value: _selectedCourse,
      decoration: InputDecoration(
        labelText: 'Strand/Course',
        border: OutlineInputBorder(),
      ),
      items: [
        '--',
        'ABM',
        'STEM',
        'HUMSS',
        'ICT',
        'HE',
        'IA'
      ].map((strandcourse) {
        return DropdownMenuItem<String>(
          value: strandcourse,
          child: Text(strandcourse),
        );
      }).toList(),
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
    SizedBox(height: 24),
    Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: widget.screenWidth,
        height: widget.screenHeight * 0.06,
        child: ElevatedButton(
          onPressed: _updateSubject,
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
