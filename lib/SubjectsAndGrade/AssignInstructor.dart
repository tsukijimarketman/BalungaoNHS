import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AssignInstructor extends StatefulWidget {
   final VoidCallback closeAddInstructor;
  const AssignInstructor({super.key, required this.closeAddInstructor});

  @override
  State<AssignInstructor> createState() => _AssignInstructorState();
}

class _AssignInstructorState extends State<AssignInstructor> {

  final TextEditingController _instructorFullname = TextEditingController();
  final TextEditingController _gradeLevel = TextEditingController();
  final TextEditingController _strand = TextEditingController();
  final TextEditingController _track = TextEditingController();
  final TextEditingController _assignSubject = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _instructorList = [];
  String? _selectedInstructor;
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


  @override
  void initState() {
    super.initState();
    _fetchInstructors();
  }

  Future<void> _saveInstructorData() async {
  if (_selectedInstructor != null &&
      _selectedGradeLevel != null &&
      _selectedTrack != null &&
      _selectedStrand != null &&
      _assignSubject.text.isNotEmpty) {

    try {
      // Split the selected instructor into first and last names
      List<String> nameParts = _selectedInstructor!.split(' ');
      if (nameParts.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid instructor name')));
        return;
      }
      String firstName = nameParts[0];
      String lastName = nameParts[1];

      // Query to find the instructor document
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'instructor')
          .where('first_name', isEqualTo: firstName)
          .where('last_name', isEqualTo: lastName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming the query returns only one document
        DocumentSnapshot instructorDoc = querySnapshot.docs.first;

        // Update the document with the new data
        await instructorDoc.reference.update({
          'gradeLevel': _selectedGradeLevel,
          'semester': _selectedSemester,
          'track': _selectedTrack,
          'strand': _selectedStrand,
          'assignedSubject': _assignSubject.text
        });

        // Optionally, you can show a confirmation message or reset the form
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Instructor assigned successfully')));
        widget.closeAddInstructor(); // Close the form

      } else {
        // Handle the case where no instructor document was found
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Instructor not found')));
      }
    } catch (e) {
      // Handle any errors that occur
      print('Error saving data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving data')));
    }
  } else {
    // Handle the case where not all fields are filled
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
  }
}


  Future<void> _fetchInstructors() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'instructor')
          .get();
      
      List<String> instructorNames = [];
    for (var doc in querySnapshot.docs) {
      // Concatenate first_name and last_name
      String fullName = '${doc['first_name']} ${doc['last_name']}';
      instructorNames.add(fullName);
    }

    setState(() {
      _instructorList = instructorNames;
    });
  } catch (e) {
    print('Error fetching instructors: $e');
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
              SizedBox(
                height: 10,
              ),
              Text('Assign Instructors'
              ,style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              ),
              ),
              SizedBox(
                height: 10,
              ),
               Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  hint: Text('Select Instructor'),
                  value: _selectedInstructor,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedInstructor = newValue;
                      _instructorFullname.text = newValue ?? '';
                    });
                  },
                  items: _instructorList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  hint: Text('Select Semester'),
                  value: _selectedSemester,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSemester = newValue;
                    });
                  },
                  items: _semester.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  hint: Text('Select Grade Level'),
                  value: _selectedGradeLevel,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGradeLevel = newValue;
                    });
                  },
                  items: _gradeLevels.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  hint: Text('Select Track'),
                  value: _selectedTrack,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTrack = newValue;
                      _selectedStrand = null; // Reset selected strand when track changes
                    });
                  },
                  items: _tracks.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: 400,
                height: 40,
                child: DropdownButton<String>(
                  hint: Text('Select Strand'),
                  value: _selectedStrand,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStrand = newValue;
                    });
                  },
                  items: _getStrands().map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Container(
                  width: 400,
                  height: 40,
                  child: CupertinoTextField(
                    controller: _assignSubject,
                    placeholder: 'Assign Subject',
                  )),
                  SizedBox(
                height: 10,
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
                          elevation: WidgetStatePropertyAll(10),
                          backgroundColor: WidgetStatePropertyAll(Colors.red),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                        ),
                        onPressed: (){
                         widget.closeAddInstructor();          
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 20, color: Colors.white),)),
                    ),
                    Container(
                      width: 320,
                        height: 40,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          elevation: WidgetStatePropertyAll(10),
                          backgroundColor: WidgetStatePropertyAll(Colors.blue),
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))
                        ),
                        onPressed: _saveInstructorData,
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