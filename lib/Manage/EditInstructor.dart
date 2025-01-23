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
  final FocusNode _subjectNameFocusNode = FocusNode();
  final FocusNode _subjectCodeFocusNode = FocusNode();

  String _adviserStatus = '--'; // Default value for adviser status
  String? _selectedSection; // To store the selected section
  String? _selectedEducationLevel = '--'; // New dropdown for educational level
  List<String> _sections = []; // To store section names
  List<String> _subjectNameSuggestions = [];
  List<String> _subjectCodeSuggestions = [];
  bool _isSubjectNameSelected = false;
  bool _isSubjectCodeSelected = false;
  bool _isLoading = false; // Add a loading state


  Map<String, String> _subjectPairs =
      {}; // Stores valid subject name-code pairs

  @override
  void initState() {
    super.initState();
    _loadInstructorData(); // Load the instructor's existing data
    _fetchSections();
    _fetchSubjects();
  }

  Future<void> _loadInstructorData() async {
    if (widget.instructorId == null) return; // Ensure instructorId is not null

    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.instructorId)
          .get();

      if (doc.exists) {
        setState(() {
          _subjectName.text = doc.data()?['subject_Name'] ?? '';
          _subjectCode.text = doc.data()?['subject_Code'] ?? '';
          _adviserStatus = doc.data()?['adviserStatus'] ?? '--';
          _selectedEducationLevel = doc.data()?['educ_level'] ?? null;
          String? handledSection = doc.data()?['handled_section'];
          _selectedSection =
              _sections.contains(handledSection) ? handledSection : null;
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
    // Only fetch sections if adviser status is 'yes'
    if (_adviserStatus == 'yes') {
      final snapshot = await FirebaseFirestore.instance
          .collection('sections')
          .where('educ_level', isEqualTo: _selectedEducationLevel)
          .get();

      final sections =
          snapshot.docs.map((doc) => doc['section_name'] as String).toList();

      setState(() {
        _sections = sections;
        // Retain the previous section if it exists in the new list of sections
        if (_selectedSection != null && !_sections.contains(_selectedSection)) {
          _selectedSection = null; // Reset if the previous section doesn't exist
        }
      });
    } else {
      // If adviser status is 'no', clear sections and selected section
      setState(() {
        _sections = [];
        _selectedSection = null;
      });
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching sections: $e')),
    );
  }
}

  Future<void> _fetchSubjects() async {
    setState(() {
    _isLoading = true; // Start loading
  });
    try{
    // Check if the selected education level is Junior High School
    if (_selectedEducationLevel == 'Junior High School') {
      // If Junior High School is selected, we fetch only subject_name
      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('educ_level', isEqualTo: _selectedEducationLevel)
          .get();

      setState(() {
        _subjectNameSuggestions =
            snapshot.docs.map((doc) => doc['subject_name'].toString()).toList();
        _subjectCodeSuggestions.clear(); // Clear subject codes for JHS
        _subjectPairs.clear(); // No subject pairs for JHS
      });
    } else if (_selectedEducationLevel == 'Senior High School') {
      // If Senior High School is selected, fetch both subject_name and subject_code
      final snapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('educ_level', isEqualTo: _selectedEducationLevel)
          .get();

      setState(() {
        _subjectNameSuggestions =
            snapshot.docs.map((doc) => doc['subject_name'].toString()).toList();
        _subjectCodeSuggestions =
            snapshot.docs.map((doc) => doc['subject_code'].toString()).toList();

        // Store valid subject pairs for Senior High School
        _subjectPairs.clear();
        for (var doc in snapshot.docs) {
          _subjectPairs[doc['subject_name'].toString()] =
              doc['subject_code'].toString();
        }
      });
    }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subjects: $e')),
      );
    }
  }

  List<String> _filterSuggestions(String query, List<String> suggestions) {
    if (query.isEmpty) return [];

    String queryLower = query.toLowerCase();
    return suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(queryLower))
        .toList()
      ..sort((a, b) {
        bool aStarts = a.toLowerCase().startsWith(queryLower);
        bool bStarts = b.toLowerCase().startsWith(queryLower);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        return a.compareTo(b);
      });
  }

  Future<void> _saveChanges() async {
    if (_subjectName.text.isEmpty || _adviserStatus == '--') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields and select adviser status')),
    );
    return;
  }

  // If education level is Senior High School, both subject name and subject code should be validated
  if (_selectedEducationLevel == 'Senior High School') {
    if (_subjectCode.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in the Subject Code for Senior High School')),
      );
      return;
    }
  }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.instructorId)
          .update({
        'subject_Name': _subjectName.text,
        'subject_Code': _subjectCode.text,
        'adviser': _adviserStatus,
        'handled_section': _selectedSection,
        'education_level': _selectedEducationLevel,
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
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: widget.closeEditInstructors,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child:
                              Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Edit Teacher',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedEducationLevel,
                        decoration: InputDecoration(
                          labelText: 'Education Level',
                          border: OutlineInputBorder(),
                        ),
                        items:
                            ['--', 'Junior High School', 'Senior High School']
                                .map((level) => DropdownMenuItem<String>(
                                      value: level,
                                      child: Text(level),
                                    ))
                                .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedEducationLevel = val ?? '--';
                          });
                          _fetchSubjects();
                        },
                      ),
                      SizedBox(height: 16),
                      if (_selectedEducationLevel == 'Junior High School') ...[
                        _buildSuggestionField(
                          _subjectName,
                          'Subject Name',
                          _subjectNameSuggestions,
                          _isSubjectNameSelected,
                          _subjectNameFocusNode,
                          (suggestion) {
                            setState(() {
                              _subjectName.text = suggestion;
                              _isSubjectNameSelected = true;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _adviserStatus,
                          decoration: InputDecoration(
                            labelText: 'Adviser Status',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: '--', child: Text('--')),
                            DropdownMenuItem(value: 'yes', child: Text('Yes')),
                            DropdownMenuItem(value: 'no', child: Text('No')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _adviserStatus = value ?? '--';
                            });
                           if (_adviserStatus == 'no') {
      setState(() {
        _selectedSection = null; // Reset section when adviser status is no
      });
    }

    _fetchSections(); // Fetch sections when the adviser status changes
  },
),
                        if (_adviserStatus == 'yes') ...[
                          DropdownButtonFormField<String>(
                            value: _selectedSection,
                            decoration:
                                InputDecoration(labelText: 'Select Section'),
                            items: _sections.map((section) {
                              return DropdownMenuItem(
                                value: section,
                                child: Text(section),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSection = value;
                              });
                            },
                          ),
                        ],
                      ] else if (_selectedEducationLevel ==
                          'Senior High School') ...[
                        _buildSuggestionField(
                          _subjectName,
                          'Subject Name',
                          _subjectNameSuggestions,
                          _isSubjectNameSelected,
                          _subjectNameFocusNode,
                          (suggestion) {
                            setState(() {
                              _subjectName.text = suggestion;
                              _isSubjectNameSelected = true;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        _buildSuggestionField(
                          _subjectCode,
                          'Subject Code',
                          _subjectCodeSuggestions,
                          _isSubjectCodeSelected,
                          _subjectCodeFocusNode,
                          (suggestion) {
                            setState(() {
                              _subjectCode.text = suggestion;
                              _isSubjectCodeSelected = true;
                            });
                          },
                        ),
                        SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _adviserStatus,
                          decoration: InputDecoration(
                            labelText: 'Adviser Status',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: '--', child: Text('--')),
                            DropdownMenuItem(value: 'yes', child: Text('Yes')),
                            DropdownMenuItem(value: 'no', child: Text('No')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _adviserStatus = value ?? '--';
                            });
                            _fetchSections();
                          },
                        ),
                        if (_adviserStatus == 'yes') ...[
                          DropdownButtonFormField<String>(
                            value: _selectedSection,
                            decoration:
                                InputDecoration(labelText: 'Select Section'),
                            items: _sections.map((section) {
                              return DropdownMenuItem(
                                value: section,
                                child: Text(section),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSection = value;
                              });
                            },
                          ),
                        ],
                      ],
                      SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton(
                          onPressed: _saveChanges,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Save Changes',
                            style: TextStyle(color: Colors.white),
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

  Widget _buildSuggestionField(
    TextEditingController controller,
    String labelText,
    List<String> suggestions,
    bool isSubjectSelected,
    FocusNode focusNode,
    Function(String) onSuggestionTap,
  ) {
  bool isValid = true;

  // Skip validation if loading
  if (_isLoading) {
    isValid = true; // Skip validation while loading
  } else {
    // Validate Subject Name
    if (labelText == 'Subject Name') {
      if (_selectedEducationLevel == 'Junior High School') {
        // Validate only subject name for Junior High School
        isValid = controller.text.isEmpty ||
            _subjectNameSuggestions.contains(controller.text);
      } else if (_selectedEducationLevel == 'Senior High School') {
        // Validate subject name for Senior High School
        isValid = controller.text.isEmpty ||
            _subjectPairs.containsKey(controller.text); // Check if it's a valid subject
      }
    } else if (labelText == 'Subject Code') {
      // Validate subject code for Senior High School
      if (_selectedEducationLevel == 'Senior High School') {
        isValid = controller.text.isEmpty ||
            _subjectCodeSuggestions.contains(controller.text);
      } else {
        isValid = true; // No validation for Subject Code if JHS is selected
      }
    }
  }


    return Column(
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
            errorText: !isValid ? 'Invalid $labelText' : null,
          ),
          onChanged: (value) {
            setState(() {
              if (labelText == 'Subject Name') {
                _isSubjectNameSelected = false;
              } else {
                _isSubjectCodeSelected = false;
              }
            });
          },
        ),
        if (focusNode.hasFocus && !isSubjectSelected)
          Container(
            height: 150,
            child: ListView(
              children: _filterSuggestions(controller.text, suggestions)
                  .map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    onSuggestionTap(suggestion);
                    setState(() {
                      if (labelText == 'Subject Name') {
                        _isSubjectNameSelected = true;
                      } else {
                        _isSubjectCodeSelected = true;
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
