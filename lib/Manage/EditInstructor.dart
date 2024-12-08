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
  List<String> _sections = []; // To store section names
  List<String> _subjectNameSuggestions = [];
  List<String> _subjectCodeSuggestions = [];
  bool _isSubjectNameSelected =
      false; // Track whether a suggestion was selected
  bool _isSubjectCodeSelected =
      false; // Track whether a suggestion was selected for subject code

  Map<String, String> _subjectPairs = {}; // Stores valid subject name-code pairs

  @override
  void initState() {
    super.initState();
    _loadInstructorData(); // Load the instructor's existing data
    _fetchSections();
    _fetchSubjects();
  }

  // Load the existing data for the instructor from Firestore
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
          _adviserStatus =
              doc.data()?['adviserStatus'] ?? '--'; // Load adviser status

          String? handledSection = doc.data()?['handled_section'];
          _selectedSection = _sections.contains(handledSection)
              ? handledSection
              : null; // Validate section
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
      final snapshot =
          await FirebaseFirestore.instance.collection('sections').get();
      final sections = snapshot.docs
          .map((doc) => doc['section_name'] as String)
          .toList(); // Assuming each section document has a 'section_name' field
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

  Future<void> _fetchSubjects() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('subjects').get();
    setState(() {
      _subjectNameSuggestions = snapshot.docs
          .map((doc) => doc['subject_name'].toString())
          .toList();
      _subjectCodeSuggestions = snapshot.docs
          .map((doc) => doc['subject_code'].toString())
          .toList();
      
      // Store valid subject pairs
      _subjectPairs.clear();
      for (var doc in snapshot.docs) {
        _subjectPairs[doc['subject_name'].toString()] = doc['subject_code'].toString();
      }
    });
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
      // Prioritize suggestions that start with the query
      bool aStarts = a.toLowerCase().startsWith(queryLower);
      bool bStarts = b.toLowerCase().startsWith(queryLower);
      if (aStarts && !bStarts) return -1;
      if (!aStarts && bStarts) return 1;
      return a.compareTo(b);
    });
}


  // Save the updated data to Firestore
 // ... existing code ...

Future<void> _saveChanges() async {
  if (_subjectName.text.isEmpty ||
      _subjectCode.text.isEmpty ||
      _adviserStatus == '--') {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill all fields and select adviser status')),
    );
    return;
  }

  try {
    final batch = FirebaseFirestore.instance.batch();
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.instructorId);
    
    // Update the user document
    if (_adviserStatus == 'yes') {
      batch.update(userDocRef, {
        'subject_Name': _subjectName.text,
        'subject_Code': _subjectCode.text,
        'adviser': _adviserStatus,
        'handled_section': _selectedSection,
      });
    } else {
      batch.update(userDocRef, {
        'subject_Name': _subjectName.text,
        'subject_Code': _subjectCode.text,
        'adviser': _adviserStatus,
        'handled_section': null,
      });

      // Query sections where this instructor is the adviser
      QuerySnapshot sectionsQuery = await FirebaseFirestore.instance
          .collection('sections')
          .where('section_adviser', isEqualTo: '${await getUserFullName()}')
          .get();

      // Update each section to set adviser to 'N/A'
      for (var doc in sectionsQuery.docs) {
        batch.update(doc.reference, {
          'section_adviser': 'N/A'
        });
      }
    }

    await batch.commit();

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

// Add this helper method to get the instructor's full name
Future<String> getUserFullName() async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(widget.instructorId)
      .get();
  
  if (doc.exists) {
    final data = doc.data() as Map<String, dynamic>;
    return '${data['first_name']} ${data['last_name']}';
  }
  return '';
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
                          child:
                              Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      // Form title
                      Text(
                        'Edit Teacher',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      _buildSuggestionField(
                        _subjectName,
                        'Subject Name',
                        _subjectNameSuggestions,
                        _isSubjectNameSelected,
                        _subjectNameFocusNode, // Pass the FocusNode here
                        (suggestion) {
                          setState(() {
                            _subjectName.text = suggestion;
                            _isSubjectNameSelected = true;
                          });
                        },
                      ),

                      _buildSuggestionField(
                        _subjectCode,
                        'Subject Code',
                        _subjectCodeSuggestions,
                        _isSubjectCodeSelected,
                        _subjectCodeFocusNode, // Pass the FocusNode here
                        (suggestion) {
                          setState(() {
                            _subjectCode.text = suggestion;
                            _isSubjectCodeSelected = true;
                          });
                        },
                      ),

                      SizedBox(height: 16),
                      // Adviser Status Dropdown
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
                        },
                        validator: (value) {
                          if (value == '--') {
                            return 'Please select teacher status';
                          }
                          return null;
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
                              _selectedSection =
                                  value; // Update selected section
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Please select a section' : null,
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
    Function(String) onSuggestionTap) {
  bool isValid = true;
  if (labelText == 'Subject Name') {
    isValid = _subjectName.text.isEmpty || 
              _subjectPairs.containsKey(_subjectName.text);
  } else if (labelText == 'Subject Code') {
    isValid = _subjectCode.text.isEmpty || 
              _subjectPairs.values.contains(_subjectCode.text);
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
        onTap: () {
          setState(() {
            // Reset selection state when field is tapped
            if (labelText == 'Subject Name') {
              _isSubjectNameSelected = false;
            } else {
              _isSubjectCodeSelected = false;
            }
          });
        },
      ),
      if (focusNode.hasFocus && !isSubjectSelected) // Show suggestions when focused and not selected
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
                      // Auto-fill subject code if available
                      if (_subjectPairs.containsKey(suggestion)) {
                        _subjectCode.text = _subjectPairs[suggestion]!;
                        _isSubjectCodeSelected = true;
                      }
                    } else {
                      _isSubjectCodeSelected = true;
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      SizedBox(height: 8),
    ],
  );
}
}
