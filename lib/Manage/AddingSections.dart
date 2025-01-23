import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddingSections extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeAddSections;

  const AddingSections(
      {required this.screenHeight,
      required this.screenWidth,
      required this.closeAddSections,
      super.key});

  @override
  State<AddingSections> createState() => _AddingSectionsState();
}

class _AddingSectionsState extends State<AddingSections> {
  final TextEditingController _sectionName = TextEditingController();
  final TextEditingController _sectionCapacity = TextEditingController();
  String? _selectedSemester = '--';
  String? _quarter = '--';
  String? _selectedAdviser;
  String? _selectedSchoolLevel;

  final CollectionReference subjectsCollection =
      FirebaseFirestore.instance.collection('sections');
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  List<Map<String, String>> _instructors = [];
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Form Key for validation

  @override
  void initState() {
    super.initState();
    _fetchInstructors();
  }

  Future<void> _fetchInstructors() async {
    try {
      final QuerySnapshot snapshot = await usersCollection
          .where('accountType', isEqualTo: 'instructor')
                    .where('educ_level', isEqualTo: _selectedSchoolLevel)
          .get();

      setState(() {
        _instructors = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name':
                '${data['first_name']} ${data['last_name']}', // Combine first and last name
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Error fetching instructors: $e'),
          ],
        )),
      );
    }
  }

  @override
  void dispose() {
    _sectionName.dispose();
    _sectionCapacity.dispose();
    super.dispose();
  }

  Future<void> _saveSubject() async {
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, return early
    }

     if (_selectedAdviser == null || _selectedSchoolLevel == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Please fill all fields'),
          ],
        ),
      ),
    );
    return;
  }

  // Check if the quarter or semester is filled based on selected school level
  if (_selectedSchoolLevel == 'Junior High School' && _quarter == '--') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Please select a quarter for Junior High School'),
          ],
        ),
      ),
    );
    return;
  }

  if (_selectedSchoolLevel == 'Senior High School' && _selectedSemester == '--') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Please select a semester for Senior High School'),
          ],
        ),
      ),
    );
    return;
  }

  int? capacity;
  try {
    capacity = int.parse(_sectionCapacity.text);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Please enter a valid number for capacity'),
          ],
        ),
      ),
    );
    return;
  }

    try {
    // Prepare data to be stored in Firestore
    Map<String, dynamic> sectionData = {
      'educ_level': _selectedSchoolLevel,
      'section_name': _sectionName.text,
      'section_adviser': _selectedAdviser,
      'section_capacity': capacity,
      'created_at': Timestamp.now(),
    };

    // Add quarter or semester based on the school level
    if (_selectedSchoolLevel == 'Junior High School' && _quarter != '--') {
      sectionData['quarter'] = _quarter; // Store quarter if JHS
    } else if (_selectedSchoolLevel == 'Senior High School' && _selectedSemester != '--') {
      sectionData['semester'] = _selectedSemester; // Store semester if SHS
    }

        await subjectsCollection.add(sectionData);


      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Section added successfully!'),
          ],
        )),
      );

      widget.closeAddSections();

      // Clear the form after saving
      _sectionName.clear();
      _sectionCapacity.clear();
      setState(() {
        _selectedSemester = '--';
        _selectedAdviser = null;
        _selectedSchoolLevel = null;
        _quarter = '--';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Error adding section: $e'),
          ],
        )),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: TextButton(
                            onPressed: widget.closeAddSections,
                            style: TextButton.styleFrom(
                              side: BorderSide(color: Colors.red),
                            ),
                            child: Text('Back',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add New Section',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 16),
                        // School Level Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSchoolLevel,
                          decoration: InputDecoration(
                            labelText: 'Educational Level',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'Junior High School',
                            'Senior High School',
                          ]
                              .map((level) => DropdownMenuItem<String>(
                                    value: level,
                                    child: Text(level),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedSchoolLevel = val;
                            });
                            _fetchInstructors();
                          },
                          validator: (value) => value == null
                              ? 'Please select a school level'
                              : null,
                        ),
                        SizedBox(height: 16),
                      if (_selectedSchoolLevel == 'Junior High School') ...[
                        // Section Name
                        TextFormField(
                          controller: _sectionName,
                          decoration: InputDecoration(
                            labelText: 'Section Name',
                            border: OutlineInputBorder(),
                            hintText: 'Enter Section Name (e.g. Grade 7, 8, 9, 10-MAGANDA-A)',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a section name';
                            }

                            if (_selectedSchoolLevel == 'Junior High School') {
                              // Validator for Junior High School format: 7-10-Any word-Any letter
                              final regExp =
                                  RegExp(r'^(7|8|9|10)-[A-Za-z]+-[A-Za-z]$');
                              if (!regExp.hasMatch(value)) {
                                return 'Invalid format. Use: Grade Level-Strand-Section (e.g., 7-Grade-A)';
                              }
                            } else if (_selectedSchoolLevel ==
                                'Senior High School') {
                              // Validator for Senior High School format: 11-12-(STEM|HUMSS|ABM|ICT|HE|IA)-
                              final regExp = RegExp(
                                  r'^(11|12)-(STEM|HUMSS|ABM|ICT|HE|IA)-[A-Za-z]$');
                              if (!regExp.hasMatch(value)) {
                                return 'Invalid format. Use: Grade Level-Strand-Section (e.g., 11-STEM-A)';
                              }
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Section Adviser Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedAdviser,
                          decoration: InputDecoration(
                            labelText: 'Section Adviser',
                            border: OutlineInputBorder(),
                          ),
                          items: _instructors
                              .map((instructor) => DropdownMenuItem<String>(
                                    value: instructor['name'],
                                    child: Text(instructor['name'] ?? ''),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedAdviser = val;
                            });
                          },
                          hint: Text('Select an adviser'),
                        ),
                        SizedBox(height: 16),
                        // Semester Dropdown
                        DropdownButtonFormField<String>(
                          value: _quarter,
                          decoration: InputDecoration(
                            labelText: 'Quarter',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            '--',
                            '1st',
                            '2nd',
                            '3rd',
                            '4th'
                          ]
                              .map((_quarter) => DropdownMenuItem<String>(
                                    value: _quarter,
                                    child: Text(_quarter),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            _quarter = val;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _sectionCapacity,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Section Capacity',
                            border: OutlineInputBorder(),
                            hintText: 'Enter section capacity',
                          ),
                        ),
                      ] else if (_selectedSchoolLevel == 'Senior High School') ...[
                        // Section Name
                        TextFormField(
                          controller: _sectionName,
                          decoration: InputDecoration(
                            labelText: 'Section Name',
                            border: OutlineInputBorder(),
                            hintText: 'Enter Section Name (e.g. 11-STEM-A)',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a section name';
                            }

                            if (_selectedSchoolLevel == 'Junior High School') {
                              // Validator for Junior High School format: 7-10-Any word-Any letter
                              final regExp =
                                  RegExp(r'^(7|8|9|10)-[A-Za-z]+-[A-Za-z]$');
                              if (!regExp.hasMatch(value)) {
                                return 'Invalid format. Use: Grade Level-Strand-Section (e.g., 7-Grade-A)';
                              }
                            } else if (_selectedSchoolLevel ==
                                'Senior High School') {
                              // Validator for Senior High School format: 11-12-(STEM|HUMSS|ABM|ICT|HE|IA)-
                              final regExp = RegExp(
                                  r'^(11|12)-(STEM|HUMSS|ABM|ICT|HE|IA)-[A-Za-z]$');
                              if (!regExp.hasMatch(value)) {
                                return 'Invalid format. Use: Grade Level-Strand-Section (e.g., 11-STEM-A)';
                              }
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        // Section Adviser Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedAdviser,
                          decoration: InputDecoration(
                            labelText: 'Section Adviser',
                            border: OutlineInputBorder(),
                          ),
                          items: _instructors
                              .map((instructor) => DropdownMenuItem<String>(
                                    value: instructor['name'],
                                    child: Text(instructor['name'] ?? ''),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedAdviser = val;
                            });
                          },
                          hint: Text('Select an adviser'),
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
                          ]
                              .map((semester) => DropdownMenuItem<String>(
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
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Section Capacity',
                            border: OutlineInputBorder(),
                            hintText: 'Enter section capacity',
                          ),
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
                              onPressed: _saveSubject,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                elevation:
                                    5, // Elevation level for shadow depth
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15), // Padding
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
          ),
        ],
      ),
    );
  }
}
