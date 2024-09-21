import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddSubjects extends StatefulWidget {
  final VoidCallback closeAddSubjects;

  const AddSubjects({super.key, required this.closeAddSubjects});

  @override
  State<AddSubjects> createState() => _AddSubjectsState();
}

class _AddSubjectsState extends State<AddSubjects> {
  final TextEditingController _subject1 = TextEditingController();
  final TextEditingController _subject2 = TextEditingController();
  final TextEditingController _subject3 = TextEditingController();
  final TextEditingController _subject4 = TextEditingController();
  final TextEditingController _subject5 = TextEditingController();
  final TextEditingController _subject6 = TextEditingController();
  final TextEditingController _subject7 = TextEditingController();
  final TextEditingController _subject8 = TextEditingController();
  final TextEditingController _subject9 = TextEditingController();
  final TextEditingController _subject10 = TextEditingController();
  String? _selectedGradeLevel;
  String? _selectedTrack;
  String? _selectedStrand;
  String? _selectedSemester;

  final List<String> _gradeLevels = ['11', '12'];
  final List<String> _tracks = [
    'Academic Track',
    'Technical-Vocational-Livelihood (TVL)'
  ];
  final List<String> _semester = [
    '1st_Semester',
    '2nd_Semester'
  ];

  List<String> _getStrands() {
    if (_selectedTrack == 'Technical-Vocational-Livelihood (TVL)') {
      return [
        'Home Economics (HE)',
        'Information and Communication Technology (ICT)',
        'Industrial Arts (IA)'
      ];
    } else if (_selectedTrack == 'Academic Track') {
      return [
        'Accountancy, Business, and Management (ABM)',
        'Science, Technology, Engineering and Mathematics (STEM)',
        'Humanities and Social Sciences (HUMSS)',
      ];
    } else {
      return [];
    }
  }

Future<void> saveToFirestore() async {
  try {
    // Reference to the selected semester document
    var semesterDocRef = FirebaseFirestore.instance
      .collection('subjects')
      .doc(_selectedSemester); // The selected semester as the document ID

    // Add a new document inside a sub-collection (e.g., 'subject_list') under the selected semester
    await semesterDocRef.collection('subject_list').add({
      'grade_level': _selectedGradeLevel,
      'semester': _selectedSemester,
      'track': _selectedTrack,
      'strand': _selectedStrand,
      'subject_1': _subject1.text,
      'subject_2': _subject2.text,
      'subject_3': _subject3.text,
      'subject_4': _subject4.text,
      'subject_5': _subject5.text,
      'subject_6': _subject6.text,
      'subject_7': _subject7.text,
      'subject_8': _subject8.text,
      'subject_9': _subject9.text,
      'subject_10': _subject10.text,
      'created_at': FieldValue.serverTimestamp(), // Optionally track when this document was added
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Subjects saved successfully!')),
    );
    widget.closeAddSubjects();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save subjects: $e')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        width: screenWidth / 2,
        height: screenHeight / 1.2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              Text(
                'Manage Subjects',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  value: _selectedGradeLevel,
                  hint: Text('Grade Level'),
                  items: _gradeLevels.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGradeLevel = newValue;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  value: _selectedSemester,
                  hint: Text('Semester'),
                  items: _semester.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSemester = newValue;
                      // Reset strand when track changes
                      
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  value: _selectedTrack,
                  hint: Text('Track'),
                  items: _tracks.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTrack = newValue;
                      // Reset strand when track changes
                      _selectedStrand = null;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  value: _selectedStrand,
                  hint: Text('Strand'),
                  items: _getStrands().map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStrand = newValue;
                    });
                  },
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(60, 0, 60, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject1,
                          placeholder: 'Subject',
                        )),
                        Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject2,
                          placeholder: 'Subject',
                        )),
                  ],
                ),
              ),
               Padding(
                 padding: const EdgeInsets.fromLTRB(60, 0, 60, 10),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject3,
                          placeholder: 'Subject',
                        )),
                        Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject4,
                          placeholder: 'Subject',
                        )),
                  ],
                               ),
               ),
               Padding(
                 padding: const EdgeInsets.fromLTRB(60, 0, 60, 10),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject5,
                          placeholder: 'Subject',
                        )),
                        Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject6,
                          placeholder: 'Subject',
                        )),
                  ],
                               ),
               ),
               Padding(
                 padding: const EdgeInsets.fromLTRB(60, 0, 60, 10),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject7,
                          placeholder: 'Subject',
                        )),
                        Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject8,
                          placeholder: 'Subject',
                        )),
                  ],
                               ),
               ),
               Padding(
                 padding: const EdgeInsets.fromLTRB(60, 0, 60, 10),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject9,
                          placeholder: 'Subject',
                        )),
                        Container(
                        width: 320,
                        height: 40,
                        child: CupertinoTextField(
                          controller: _subject10,
                          placeholder: 'Subject',
                        )),
                  ],
                               ),
               ),
               Padding(
                 padding: const EdgeInsets.fromLTRB(60, 0, 60, 10),
                 child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 320,
                        height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(10),
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                        ),
                        onPressed: (){
                         widget.closeAddSubjects();           
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 20, color: Colors.white),)),
                    ),
                    Container(
                      width: 320,
                        height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: MaterialStatePropertyAll(10),
                          backgroundColor: MaterialStatePropertyAll(Colors.blue),
                          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                        ),
                        onPressed: (){
                        saveToFirestore();
                      },
                      child: Text('Save', style: TextStyle(fontSize: 20, color: Colors.white),)),
                    )
                  ],
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
