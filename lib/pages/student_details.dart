import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class StudentDetails extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final String studentDocId;

  StudentDetails({required this.studentData, required this.studentDocId});

  @override
  _StudentDetailsState createState() => _StudentDetailsState();
}

class _StudentDetailsState extends State<StudentDetails> {
  bool _hovering = false; // Hover state for the "Go back to Students" link
  bool _isEditing = false;

// Editable fields controllers
  late TextEditingController _ageController;
  late TextEditingController _gradeController;
  late TextEditingController _trackController;
  late TextEditingController _strandController;
  late TextEditingController _fathersNameController;
  late TextEditingController _mothersNameController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianRelationshipController;
  late TextEditingController _juniorHighController;
  late TextEditingController _jhsAddressController;

  // Controllers for new editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _extensionNameController;

  String selectedTrack = '';
  String selectedStrand = '';

  List<String> strandOptions = [];

  @override
  void initState() {
    super.initState();

    // Initialize controllers for editable fields
    _ageController = TextEditingController(text: widget.studentData['age']);
    _gradeController =
        TextEditingController(text: widget.studentData['grade_level']);
    _trackController =
        TextEditingController(text: widget.studentData['seniorHigh_Track']);
    _strandController =
        TextEditingController(text: widget.studentData['seniorHigh_Strand']);
    _fathersNameController =
        TextEditingController(text: widget.studentData['fathersName']);
    _mothersNameController =
        TextEditingController(text: widget.studentData['mothersName']);
    _guardianNameController =
        TextEditingController(text: widget.studentData['guardianName']);
    _guardianRelationshipController =
        TextEditingController(text: widget.studentData['relationshipGuardian']);
    _juniorHighController =
        TextEditingController(text: widget.studentData['juniorHS']);
    _jhsAddressController =
        TextEditingController(text: widget.studentData['schoolAdd']);

    // Initialize controllers for the new fields
    _firstNameController =
        TextEditingController(text: widget.studentData['first_name']);
    _middleNameController =
        TextEditingController(text: widget.studentData['middle_name']);
    _lastNameController =
        TextEditingController(text: widget.studentData['last_name']);
    _extensionNameController =
        TextEditingController(text: widget.studentData['extension_name']);

    selectedTrack = widget.studentData['seniorHigh_Track'];
    selectedStrand = widget.studentData['seniorHigh_Strand'];
    _updateStrandOptions(
        selectedTrack); // Update strand options based on the initial track
  }

  void _updateStrandOptions(String track) {
    setState(() {
      if (track == 'Technical-Vocational-Livelihood (TVL)') {
        strandOptions = [
          'Home Economics (HE)',
          'Information and Communication Technology (ICT)',
          'Industrial Arts (IA)',
        ];
      } else if (track == 'Academic Track') {
        strandOptions = [
          'Accountancy, Business, and Management (ABM)',
          'Science, Technology, Engineering and Mathematics (STEM)',
          'Humanities and Social Sciences (HUMSS)',
        ];
      } else {
        strandOptions = [];
      }
      selectedStrand = widget.studentData[
          'seniorHigh_Strand']; // Keep the current strand when track changes
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    _ageController.dispose();
    _gradeController.dispose();
    _trackController.dispose();
    _strandController.dispose();
    _fathersNameController.dispose();
    _mothersNameController.dispose();
    _guardianNameController.dispose();
    _guardianRelationshipController.dispose();
    _juniorHighController.dispose();
    _jhsAddressController.dispose();

    // Dispose the new controllers
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _extensionNameController.dispose();

    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveChanges() async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(widget.studentDocId).update({
      'age': _ageController.text,
      'grade_level': _gradeController.text,
      'seniorHigh_Track': selectedTrack,
      'seniorHigh_Strand': selectedStrand,
      'fathersName': _fathersNameController.text,
      'mothersName': _mothersNameController.text,
      'guardianName': _guardianNameController.text,
      'relationshipGuardian': _guardianRelationshipController.text,
      'juniorHS': _juniorHighController.text,
      'schoolAdd': _jhsAddressController.text,
      'first_name': _firstNameController.text,
      'middle_name': _middleNameController.text,
      'last_name': _lastNameController.text,
      'extension_name': _extensionNameController.text,
    });

    // Update the local state to reflect the changes
    setState(() {
      widget.studentData['age'] = _ageController.text;
      widget.studentData['grade_level'] = _gradeController.text;
      widget.studentData['seniorHigh_Track'] = selectedTrack;
      widget.studentData['seniorHigh_Strand'] = selectedStrand;
      widget.studentData['fathersName'] = _fathersNameController.text;
      widget.studentData['mothersName'] = _mothersNameController.text;
      widget.studentData['guardianName'] = _guardianNameController.text;
      widget.studentData['relationshipGuardian'] =
          _guardianRelationshipController.text;
      widget.studentData['juniorHS'] = _juniorHighController.text;
      widget.studentData['schoolAdd'] = _jhsAddressController.text;
      widget.studentData['first_name'] = _firstNameController.text;
      widget.studentData['middle_name'] = _middleNameController.text;
      widget.studentData['last_name'] = _lastNameController.text;
      widget.studentData['extension_name'] = _extensionNameController.text;
    });

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String combinedAddress = [
      widget.studentData['house_number'] ?? '',
      widget.studentData['street_name'] ?? '',
      widget.studentData['subdivision_barangay'] ?? '',
      widget.studentData['city_municipality'] ?? '',
      widget.studentData['province'] ?? '',
      widget.studentData['country'] ?? '',
    ].where((s) => s.isNotEmpty).join(', ');

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) {
                        setState(() {
                          _hovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _hovering = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Student List',
                          style: TextStyle(
                            color: _hovering ? Colors.blue : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Student Details',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEditableRow(Icons.person, 'First Name:',
                                  _firstNameController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.person, 'Middle Name:',
                                  _middleNameController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.person, 'Last Name:',
                                  _lastNameController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.person, 'Extension Name:',
                                  _extensionNameController,
                                  isCapitalized: true),
                              _buildEditableRow(
                                  Icons.person, 'Age:', _ageController,
                                  isNumberField: true),
                              _buildEditableRow(
                                  Icons.grade, 'Grade:', _gradeController,
                                  isNumberField: true),
                              _buildTrackRow(),
                              _buildStrandRow(),
                              _buildEditableRow(Icons.person, 'Father’s Name:',
                                  _fathersNameController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.person, 'Mother’s Name:',
                                  _mothersNameController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.person,
                                  'Guardian’s Name:', _guardianNameController,
                                  isCapitalized: true),
                              _buildEditableRow(
                                  Icons.group,
                                  'Guardian Relationship:',
                                  _guardianRelationshipController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.school,
                                  'Junior High School:', _juniorHighController,
                                  isCapitalized: true),
                              _buildEditableRow(Icons.location_city,
                                  'JHS Address:', _jhsAddressController,
                                  isCapitalized: true),
                              _buildDetailRow(Icons.phone, 'Guardian Contact Number:',
                                  widget.studentData['cellphone_number'] ?? ''),
                              _buildDetailRow(Icons.tag, 'Student Number:',
                                  widget.studentData['student_id'] ?? ''),
                              _buildDetailRow(Icons.email, 'Email Address:',
                                  widget.studentData['email_Address'] ?? ''),
                              _buildDetailRow(Icons.location_on, 'Address:',
                                  combinedAddress),
                              _buildDetailRow(Icons.phone, 'Contact Number:',
                                  widget.studentData['phone_number'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Birthday:',
                                  widget.studentData['birthdate'] ?? ''),
                              _buildDetailRow(Icons.person, 'Gender:',
                                  widget.studentData['gender'] ?? ''),
                              _buildDetailRow(Icons.groups, 'Indigenous Group:',
                                  widget.studentData['indigenous_group'] ?? ''),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              '${widget.studentData['accountType']?.toUpperCase() ?? ''}',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {},
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: widget
                                            .studentData['image_url'] !=
                                        null
                                    ? NetworkImage(
                                        widget.studentData['image_url'])
                                    : NetworkImage(
                                        'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '${widget.studentData['first_name'] ?? ''} ${widget.studentData['last_name'] ?? ''}',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${widget.studentData['student_id'] ?? ''}',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _isEditing ? _saveChanges : _toggleEditing,
        child: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors. white, size: 30,),
      ),
    );
  }

  Widget _buildTrackRow() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Icon(Icons.track_changes, size: 24, color: Colors.black),
          SizedBox(width: 10),
          Text("Track", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          _isEditing
              ? Expanded(
                  // Add this Expanded widget to ensure the dropdown takes available space
                  child: DropdownButtonFormField<String>(
                    value: selectedTrack.isNotEmpty ? selectedTrack : null,
                    onChanged: (value) {
                      setState(() {
                        selectedTrack = value!;
                        _updateStrandOptions(selectedTrack);
                        selectedStrand =
                            strandOptions.isNotEmpty ? strandOptions[0] : '';
                      });
                    },
                    items: [
                      'Academic Track',
                      'Technical-Vocational-Livelihood (TVL)',
                    ]
                        .map((track) => DropdownMenuItem<String>(
                              value: track,
                              child: Text(track),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                    ),
                  ),
                )
              : Text(selectedTrack.isNotEmpty ? selectedTrack : "Not selected"),
        ],
      ),
    );
  }

  Widget _buildStrandRow() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Icon(Icons.assignment, size: 24, color: Colors.black),
          SizedBox(width: 10),
          Text("Strand", style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          _isEditing
              ? Expanded(
                  // Similarly, wrap this DropdownButtonFormField with Expanded
                  child: DropdownButtonFormField<String>(
                    value: selectedStrand.isNotEmpty ? selectedStrand : null,
                    onChanged: (value) {
                      setState(() {
                        selectedStrand = value!;
                      });
                    },
                    items: strandOptions
                        .map((strand) => DropdownMenuItem<String>(
                              value: strand,
                              child: Text(strand),
                            ))
                        .toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                    ),
                  ),
                )
              : Text(
                  selectedStrand.isNotEmpty ? selectedStrand : "Not selected"),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
      IconData icon, String label, TextEditingController controller,
      {bool isNumberField = false, bool isCapitalized = false}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.black),
          SizedBox(width: 10),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          _isEditing
              ? Expanded(
                  child: TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 1.0),
                      ),
                    ),
                    keyboardType: isNumberField
                        ? TextInputType.number
                        : TextInputType.text,
                    inputFormatters: [
                      if (isNumberField) FilteringTextInputFormatter.digitsOnly,
                      if (isNumberField) LengthLimitingTextInputFormatter(2),
                      if (isCapitalized)
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          // Capitalize first letter after space or initially
                          final newText = newValue.text;

                          if (newText.isEmpty) return newValue;

                          // Capitalize the first letter of the string
                          String resultText =
                              newText[0].toUpperCase() + newText.substring(1);

                          // Iterate over the string to capitalize after every space
                          for (int i = 1; i < newText.length; i++) {
                            if (newText[i - 1] == ' ' && newText[i] != ' ') {
                              resultText = resultText.substring(0, i) +
                                  newText[i].toUpperCase() +
                                  newText.substring(i + 1);
                            }
                          }

                          return newValue.copyWith(text: resultText);
                        }),
                    ],
                  ),
                )
              : Text(controller.text),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black),
        SizedBox(width: 10),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 10),
        Text(value),
      ],
    );
  }
}
