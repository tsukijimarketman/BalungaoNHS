import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pbma_portal/SubjectsAndGrade/AddingSubjects.dart';
import 'package:pbma_portal/SubjectsAndGrade/AssignInstructor.dart';
import 'package:pbma_portal/SubjectsAndGrade/SubjectsandGrade.dart';
import 'package:pbma_portal/launcher.dart';
import 'package:pbma_portal/pages/Auth_View/Adding_InstructorAcc_Desktview.dart';
import 'package:pbma_portal/pages/dashboard.dart';
import 'package:pbma_portal/pages/student_details.dart';
import 'package:pbma_portal/student_utils/Student_Utils.dart';
import 'package:pbma_portal/Admin Dashboard Sorting/Dashboard Sorting.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, bool> _selectedStudents = {};
  String _selectedDrawerItem = 'Dashboard';
  String _email = '';
  String _accountType = '';
  int _gradeLevelIconState = 0;
  int _transfereeIconState = 0;
  int _trackIconState = 0;
  String _selectedStrand = 'ALL';
  bool _showAddSubjects = false;
  bool _showAddInstructor = false;
   String? _selectedSemester;
  final List<String> _semesterOptions = ['1st_Semester', '2nd_Semester'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _assignedInstructors = [];

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  Map<String, String> strandMapping = {
    'STEM': 'Science, Technology, Engineering and Mathematics (STEM)',
    'HUMSS': 'Humanities and Social Sciences (HUMSS)',
    'ABM': 'Accountancy, Business, and Management (ABM)',
    'ICT': 'Information and Communication Technology (ICT)',
    'HE': 'Home Economics (HE)', 
    'IA': 'Industrial Arts (IA)',
  
};
bool get _isAnyStudentSelected {
    return _selectedStudents.values.any((isSelected) => isSelected);
  }

  void toggleAddInstructor() {
    setState(() {
      _showAddInstructor = !_showAddInstructor;
    });
  }

  void closeAddInstructor() {
    setState(() {
      _showAddInstructor = false;
    });
  }

  void toggleAddSubjects() {
    setState(() {
      _showAddSubjects = !_showAddSubjects;
    });
  }

  void closeAddSubjects() {
    setState(() {
      _showAddSubjects = false;
    });
  }

  void _toggleGradeLevelIcon() {
    setState(() {
      _gradeLevelIconState =
          (_gradeLevelIconState + 1) % 3; // Cycles through 0, 1, 2
    });
  }

  void _toggleTransfereeIcon() {
    setState(() {
      _transfereeIconState =
          (_transfereeIconState + 1) % 3; // Cycles through 0, 1, 2
    });
  }

  void _toggleTrackIcon() {
    setState(() {
      _trackIconState = (_trackIconState + 1) % 3; // Cycles through 0, 1, 2
    });
  }

  Stream<QuerySnapshot> _getFilteredStudents() {
    return getFilteredStudents(_trackIconState, _gradeLevelIconState,
        _transfereeIconState, _selectedStrand);
  }

  Stream<QuerySnapshot> _getEnrolledStudentsCount() {
  Query query = FirebaseFirestore.instance
      .collection('users')
      .where('enrollment_status', isEqualTo: 'approved'); // Always filter by 'approved'

  // Map icon states to Firestore values
  String? trackValue;
  if (_trackIconState == 1) {
    trackValue = 'Academic Track'; // Replace with actual Firestore value
  } else if (_trackIconState == 2) {
    trackValue = 'Technical-Vocational-Livelihood (TVL)'; // Replace with actual Firestore value
  }
  if (trackValue != null) {
    query = query.where('seniorHigh_Track', isEqualTo: trackValue);
  }

  // Map grade level states
  String? gradeLevelValue;
  if (_gradeLevelIconState == 1) {
    gradeLevelValue = '11'; // Replace with actual Firestore value
  } else if (_gradeLevelIconState == 2) {
    gradeLevelValue = '12'; // Replace with actual Firestore value
  }
  if (gradeLevelValue != null) {
    query = query.where('grade_level', isEqualTo: gradeLevelValue);
  }

  // Map transferee states
  String? transfereeValue;
  if (_transfereeIconState == 1) {
    transfereeValue = 'yes'; // Replace with actual Firestore value
  } else if (_transfereeIconState == 2) {
    transfereeValue = 'no'; // Replace with actual Firestore value
  }
  if (transfereeValue != null) {
    query = query.where('transferee', isEqualTo: transfereeValue);
  }

  // Add strand filter only if it's not 'ALL'
  if (_selectedStrand != 'ALL') {
    String? strandValue = strandMapping[_selectedStrand];
     print("Selected Strand: $_selectedStrand"); // Check the selected strand
  print("Mapped Strand Value: $strandValue"); // Check the mapped value

  if (strandValue != null) {
      print("Applying strand filter: $strandValue");
    query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
  }
}
 


  return query.snapshots();
}

  Stream<QuerySnapshot> _getNewcomersStudents() {
    return getNewcomersStudents(_trackIconState, _gradeLevelIconState,
        _transfereeIconState, _selectedStrand);
  }

  Stream<QuerySnapshot> _getSubjectsStream() {
  if (_selectedSemester == null) {
    return Stream.empty(); // Handle case when no semester is selected
  }

  return FirebaseFirestore.instance
      .collection('subjects')
      .doc(_selectedSemester) // Use the selected semester
      .collection('subject_list')
      .snapshots();
}

 Stream<QuerySnapshot<Map<String, dynamic>>> _getFilteredInstructorStudents() async* {
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();

  final userData = userDoc.data()!;
  final userGradeLevel = userData['gradeLevel'];
  final userStrand = userData['strand'];
  final userTrack = userData['track'];

  Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('users')
      .where('grade_level', isEqualTo: userGradeLevel)
      .where('seniorHigh_Strand', isEqualTo: userStrand)
      .where('seniorHigh_Track', isEqualTo: userTrack)
      .where('enrollment_status', isEqualTo: 'approved')
      .where('accountType', isEqualTo: 'student');

  if (_trackIconState != 0) {
    query = query.where('seniorHigh_Track', isEqualTo: _trackIconState);
  }

  if (_gradeLevelIconState != 0) {
    query = query.where('grade_level', isEqualTo: _gradeLevelIconState);
  }

  if (_selectedStrand != 'ALL') {
    query = query.where('seniorHigh_Strand', isEqualTo: _selectedStrand);
  }

  yield* query.snapshots();
}

  @override
  void initState() {
    super.initState();
    _selectedSemester = _semesterOptions.first; // Default to '1st_Semester'
    _fetchUserData();
   _fetchAssignedInstructors();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<QuerySnapshot> _fetchSubjectsData() async {
    return FirebaseFirestore.instance.collection('subjects').get();
  }

  Future<void> _fetchAssignedInstructors() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('accountType', isEqualTo: 'instructor')
          .where('assignedSubject', isNotEqualTo: null) // Fetch instructors with assigned subjects
          
          .get();

      List<Map<String, dynamic>> instructors = [];
      for (var doc in querySnapshot.docs) {
        instructors.add({
          'name': '${doc['first_name']} ${doc['last_name']}',
          'assignedSubject': doc['assignedSubject'],
          'gradeLevel': doc['gradeLevel'],
          'strand':doc['strand'],
          'track':doc['track']
        });
      }

      setState(() {
        _assignedInstructors = instructors;
      });
    } catch (e) {
      print('Error fetching instructors: $e');
    }
  }

  // pag retrieve ng nag login na account admin, instructor
  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;

        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();

        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>;

          setState(() {
            _accountType = (data['accountType'] as String).toUpperCase();
            _email = data['email_Address'];
            _selectedDrawerItem =
                _accountType == 'INSTRUCTOR' ? 'Strand Instructor' : 'Dashboard';
          });
        } else {
          print('No document found for UID: $uid');
          setState(() {
            _accountType = 'Not Found';
          });
        }
      } else {
        print('No current user found.');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _accountType = 'Error';
      });
    }
  }

  // pag disabled ng menus
  bool _isItemDisabled(String item) {
    if (_accountType == 'ADMIN') {
      return item == 'Strand Instructor';
    } else if (_accountType == 'INSTRUCTOR') {
      return item != 'Strand Professor';
    }
    return false;
  }

  Widget _buildDrawerItem(String title, IconData icon, String drawerItem) {
    bool isDisabled = _isItemDisabled(drawerItem);
    return ListTile(
      leading: Icon(icon, color: isDisabled ? Colors.grey : Colors.black),
      title: Text(title,
          style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
      onTap: isDisabled
          ? null
          : () {
              setState(() {
                _selectedDrawerItem = drawerItem;
              });
              Navigator.of(context).pop();
            },
    );
  }

  // pag delete ng enrollment form sa manage new comers
  void deleteStudent(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete student: $e')),
      );
    }
  }

  Widget _buildBodyContent() {
    switch (_selectedDrawerItem) {
      case 'Dashboard':
        return _buildDashboardContent();
      case 'Students':
        return _buildStudentsContent();
      case 'Strand Instructor':
        return _buildStrandInstructorContent();
      case 'Manage Newcomers':
        return _buildNewcomersContent();
      case 'Subjects and Instructor':
        return _buildSubjectsandInstructorContent();
      case 'Dropped Student' :
        return _buildDropStudent();
      default:
        return Center(child: Text('Body Content Here'));
    }
  }

  Widget _buildDashboardContent() {
  return Container(
    color: Colors.grey[300],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // "Students List" Text
              Text(
                'Students List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 50),

              // Enrolled Students Card using StreamBuilder to fetch the count dynamically
              StreamBuilder<QuerySnapshot>(
                stream: _getEnrolledStudentsCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      width: 120,
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Center(child: CircularProgressIndicator()), // Loader while waiting
                    );
                  }

                  if (!snapshot.hasData) {
                    // If there are no enrolled students, display "0"
                    return Container(
                      width: 120,
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  '0', // Display 0 if no data
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'ENROLLED',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  'STUDENTS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.0,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }

                  int enrolledStudentsCount = snapshot.data!.docs.length;

                  return Container(
                    width: 120, // Set fixed width
                    height: 60, // Set fixed height
                    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Align the content horizontally
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 24.0, // Adjust icon size to fit
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                '$enrolledStudentsCount', // Display the actual count
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'ENROLLED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0, // Smaller text to fit within the box
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'STUDENTS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0, // Smaller text to fit
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getEnrolledStudentsCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data!.docs;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text('Student ID')),
                            Expanded(child: Text('First Name')),
                            Expanded(child: Text('Last Name')),
                            Expanded(child: Text('Middle Name')),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Track'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTrackIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Strand'),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons
                                        .arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedStrand =
                                            value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        'ALL',
                                        'STEM',
                                        'HUMSS',
                                        'ABM',
                                        'ICT',
                                        'HE',
                                        'IA'
                                      ].map((String strand) {
                                        return PopupMenuItem<String>(
                                          value: strand,
                                          child: Text(strand),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Grade Level'),
                                  GestureDetector(
                                    onTap:
                                        _toggleGradeLevelIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Transferee'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTransfereeIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_transfereeIconState == 0 ||
                                            _transfereeIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_transfereeIconState == 0 ||
                                            _transfereeIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        ...students.map((student) {
                          final data = student.data() as Map<String, dynamic>;
                          return Row(
                            children: [
                              // Checkbox(
                              //     value: false, onChanged: (bool? value) {}),
                              Expanded(child: Text(data['student_id'] ?? '')),
                              Expanded(child: Text(data['first_name'] ?? '')),
                              Expanded(child: Text(data['last_name'] ?? '')),
                              Expanded(child: Text(data['middle_name'] ?? '')),
                              Expanded(
                                  child: Text(data['seniorHigh_Track'] ?? '')),
                              Expanded(
                                  child: Text(data['seniorHigh_Strand'] ?? '')),
                              Expanded(child: Text(data['grade_level'] ?? '')),
                              Expanded(child: Text(data['transferee'] ?? '')),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStudentsContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Students',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Row with Drop button (on the left) and Search Student (fixed on the right)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                
                if (_isAnyStudentSelected)
                  OutlinedButton(
                    onPressed: () {
                      
                    },
                    child: Text('Move to Drop List', style: TextStyle(color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                // Add Spacer or Expanded to ensure Search stays on the right
                Spacer(),
                // Search Student field stays on the right
                Container(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Student',
                      prefixIcon: Icon(Iconsax.search_normal_1_copy),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                    final students = snapshot.data!.docs.where((student) {
                    final data = student.data() as Map<String, dynamic>;
                    final query = _searchQuery.toLowerCase();

                    final studentId = data['student_id']?.toLowerCase() ?? '';
                    final firstName = data['first_name']?.toLowerCase() ?? '';
                    final lastName = data['last_name']?.toLowerCase() ?? '';
                    final middleName = data['middle_name']?.toLowerCase() ?? '';
                    final track = data['seniorHigh_Track']?.toLowerCase() ?? '';
                    final strand =
                        data['seniorHigh_Strand']?.toLowerCase() ?? '';
                    final gradeLevel = data['grade_level']?.toLowerCase() ?? '';
                    final Transferee = data['transferee']?.toLowerCase() ?? '';

                    final fullName = '$firstName $middleName $lastName';

                    return studentId.contains(query) ||
                        fullName.contains(query) ||
                        track.contains(query) ||
                        strand.contains(query) ||
                        gradeLevel.contains(query) ||
                        Transferee.contains(query);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 32), // Same width as a checkbox to preserve alignment
                            Expanded(child: Text('Student ID')),
                            Expanded(child: Text('First Name')),
                            Expanded(child: Text('Last Name')),
                            Expanded(child: Text('Middle Name')),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Track'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTrackIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Strand'),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons
                                        .arrow_drop_down), 
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedStrand =
                                            value; 
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        'ALL',
                                        'STEM',
                                        'HUMSS',
                                        'ABM',
                                        'ICT',
                                        'HE',
                                        'IA'
                                      ].map((String strand) {
                                        return PopupMenuItem<String>(
                                          value: strand,
                                          child: Text(strand),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Grade Level'),
                                  GestureDetector(
                                    onTap:
                                        _toggleGradeLevelIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Transferee'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTransfereeIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_transfereeIconState == 0 ||
                                            _transfereeIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_transfereeIconState == 0 ||
                                            _transfereeIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        ...students.map((student) {
                          final data = student.data() as Map<String, dynamic>;
                          String studentId = data['student_id'] ?? '';
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      StudentDetails(studentData: data),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Checkbox(
                                  value: _selectedStudents[studentId] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _selectedStudents[studentId] = value!;
                                    });
                                  },
                                ),
                                Expanded(child: Text(data['student_id'] ?? '')),
                                Expanded(child: Text(data['first_name'] ?? '')),
                                Expanded(child: Text(data['last_name'] ?? '')),
                                Expanded(
                                    child: Text(data['middle_name'] ?? '')),
                                Expanded(
                                    child:
                                        Text(data['seniorHigh_Track'] ?? '')),
                                Expanded(
                                    child:
                                        Text(data['seniorHigh_Strand'] ?? '')),
                                Expanded(
                                    child: Text(data['grade_level'] ?? '')),
                                Expanded(
                                    child: Text(data['transferee'] ?? '')),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrandInstructorContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Strand Instructor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 300,
                  child: Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search Student',
                        prefixIcon: Icon(Iconsax.search_normal_1_copy),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _getFilteredInstructorStudents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
              
                  final students = snapshot.data!.docs.where((student) {
                    final data = student.data() as Map<String, dynamic>;
                    final query = _searchQuery.toLowerCase();

                    final studentId = data['student_id']?.toLowerCase() ?? '';
                    final firstName = data['first_name']?.toLowerCase() ?? '';
                    final lastName = data['last_name']?.toLowerCase() ?? '';
                    final middleName = data['middle_name']?.toLowerCase() ?? '';
                    final track = data['seniorHigh_Track']?.toLowerCase() ?? '';
                    final strand = data['seniorHigh_Strand']?.toLowerCase() ?? '';

                    final fullName = '$firstName $middleName $lastName';

                    return studentId.contains(query) ||
                        fullName.contains(query) ||
                        track.contains(query) ||
                        strand.contains(query);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text('Student ID')),
                            Expanded(child: Text('Name')),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Track'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTrackIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Strand'),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons
                                        .arrow_drop_down), 
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedStrand =
                                            value; 
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        'ALL',
                                        'STEM',
                                        'HUMSS',
                                        'ABM',
                                        'ICT',
                                        'HE',
                                        'IA'
                                      ].map((String strand) {
                                        return PopupMenuItem<String>(
                                          value: strand,
                                          child: Text(strand),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Grade Level'),
                                  GestureDetector(
                                    onTap:
                                        _toggleGradeLevelIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(child: Text('Average')),
                          ],
                        ),
                        Divider(),
                      ...students.map((student) {
                        final data = student.data();
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SubjectsandGrade(
                                          studentData: data,
                                        )));
                          },
                          child: Row(
                            children: [
                              Checkbox(value: false, onChanged: (bool? value) {}),
                              Expanded(child: Text(data['student_id'] ?? '')),
                              Expanded(child: Text('${data['first_name'] ?? ''} ${data['middle_name'] ?? ''} ${data['last_name'] ?? ''}')),
                              Expanded(child: Text(data['seniorHigh_Track'] ?? '')),
                              Expanded(child: Text(data['seniorHigh_Strand'] ?? '')),
                              Expanded(child: Text(data['grade_level'] ?? '')),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildNewcomersContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Manage Newcomers',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Student',
                      prefixIcon: Icon(Iconsax.search_normal_1_copy),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getNewcomersStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final students = snapshot.data!.docs.where((student) {
                    final data = student.data() as Map<String, dynamic>;
                    final query = _searchQuery.toLowerCase();

                    final studentId = data['student_id']?.toLowerCase() ?? '';
                    final firstName = data['first_name']?.toLowerCase() ?? '';
                    final lastName = data['last_name']?.toLowerCase() ?? '';
                    final middleName = data['middle_name']?.toLowerCase() ?? '';
                    final track = data['seniorHigh_Track']?.toLowerCase() ?? '';
                    final strand =
                        data['seniorHigh_Strand']?.toLowerCase() ?? '';
                    final gradeLevel = data['grade_level']?.toLowerCase() ?? '';

                    final fullName = '$firstName $middleName $lastName';

                    return studentId.contains(query) ||
                        fullName.contains(query) ||
                        track.contains(query) ||
                        strand.contains(query) ||
                        gradeLevel.contains(query);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text('Student ID')),
                            Expanded(child: Text('First Name')),
                            Expanded(child: Text('Last Name')),
                            Expanded(child: Text('Middle Name')),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Track'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTrackIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Strand'),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons
                                        .arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedStrand =
                                            value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        'ALL',
                                        'STEM',
                                        'HUMSS',
                                        'ABM',
                                        'ICT',
                                        'HE',
                                        'IA'
                                      ].map((String strand) {
                                        return PopupMenuItem<String>(
                                          value: strand,
                                          child: Text(strand),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Grade Level'),
                                  GestureDetector(
                                    onTap:
                                        _toggleGradeLevelIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        ...students.map((student) {
                          final data = student.data() as Map<String, dynamic>;
                          return Row(
                            children: [
                              Checkbox(
                                  value: false, onChanged: (bool? value) {}),
                              Expanded(child: Text(data['student_id'] ?? '')),
                              Expanded(child: Text(data['first_name'] ?? '')),
                              Expanded(child: Text(data['last_name'] ?? '')),
                              Expanded(child: Text(data['middle_name'] ?? '')),
                              Expanded(
                                  child: Text(data['seniorHigh_Track'] ?? '')),
                              Expanded(
                                  child: Text(data['seniorHigh_Strand'] ?? '')),
                              Expanded(child: Text(data['grade_level'] ?? '')),
                              Expanded(
                                child: Row( 
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Iconsax.tick_circle_copy,
                                          color: Colors.green),
                                      onPressed: () {
                                        approveStudent(student.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Iconsax.close_circle_copy,
                                          color: Colors.red),
                                      onPressed: () {
                                        deleteStudent(student.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsandInstructorContent() {
  double screenWidth = MediaQuery.of(context).size.width;
  double screenHeight = MediaQuery.of(context).size.height;

  return Stack(
    children: [
      Container(
        color: Colors.grey[300],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Manage Subjects',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  onPressed: toggleAddSubjects,
                  child: Text(
                    'Add New Subject',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.all(16),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subjects List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      Table(
                        border: TableBorder.all(color: Colors.grey),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(40.0),
                          1: FlexColumnWidth(),
                          2: FlexColumnWidth(),
                          3: FlexColumnWidth(),
                          4: FlexColumnWidth(),
                          5: FlexColumnWidth(),
                          6: FixedColumnWidth(100.0),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Subject Name', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Code', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Semester', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Instructor', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No Subject Added',
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      AnimatedSwitcher(
  duration: Duration(milliseconds: 550),
  child: _showAddSubjects
      ? Positioned.fill(
          child: GestureDetector(
            onTap: closeAddSubjects,
            child: Stack(
              children: [
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(color: Colors.black.withOpacity(0.5)),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      width: screenWidth / 2,
                      height: screenHeight / 1.4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      padding: EdgeInsets.all(20),
                      child: SingleChildScrollView( // Add scroll functionality
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Back button
                            Align(
                              alignment: Alignment.topRight,
                              child: TextButton(
                                onPressed: closeAddSubjects,
                                style: TextButton.styleFrom(
                                  side: BorderSide(color: Colors.red),
                                ),
                                child: Text('Back', style: TextStyle(color: Colors.red)),
                              ),
                            ),
                            SizedBox(height: 8),
                            // Form title
                            Text(
                              'Add New Subject',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            // Subject Name
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Subject Name',
                                border: OutlineInputBorder(),
                                hintText: 'Enter subject name',
                              ),
                            ),
                            SizedBox(height: 16),
                            // Subject Code
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Subject Code',
                                border: OutlineInputBorder(),
                                hintText: 'Enter subject code',
                              ),
                            ),
                            SizedBox(height: 16),
                            // Instructor
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Instructor',
                                border: OutlineInputBorder(),
                                hintText: 'Enter instructor name',
                              ),
                            ),
                            SizedBox(height: 16),
                            // Category Dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Category',
                                border: OutlineInputBorder(),
                              ),
                              items: ['--', 'Category 1', 'Category 2']
                                  .map((category) => DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      ))
                                  .toList(),
                              onChanged: (val) {},
                            ),
                            SizedBox(height: 16),
                            // Semester Dropdown
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Semester',
                                border: OutlineInputBorder(),
                              ),
                              items: ['--', 'Grade 11 - 1st Semester', 'Grade 11 - 2nd Semester',
                              'Grade 12 - 1st Semester', 'Grade 12 - 2nd Semester']
                                  .map((semester) => DropdownMenuItem<String>(
                                        value: semester,
                                        child: Text(semester),
                                      ))
                                  .toList(),
                              onChanged: (val) {},
                            ),
                            SizedBox(height: 24),
                            // Save Changes button
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Save functionality
                                },
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
          ),
        )
      : SizedBox.shrink(),
),

    ],
  );
}


  Widget _buildDropStudent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Dropped Students',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 300,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Student',
                      prefixIcon: Icon(Iconsax.search_normal_1_copy),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getNewcomersStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No pending students.'));
                  }

                  final students = snapshot.data!.docs.where((student) {
                    final data = student.data() as Map<String, dynamic>;
                    final query = _searchQuery.toLowerCase();

                    final studentId = data['student_id']?.toLowerCase() ?? '';
                    final firstName = data['first_name']?.toLowerCase() ?? '';
                    final lastName = data['last_name']?.toLowerCase() ?? '';
                    final middleName = data['middle_name']?.toLowerCase() ?? '';
                    final track = data['seniorHigh_Track']?.toLowerCase() ?? '';
                    final strand =
                        data['seniorHigh_Strand']?.toLowerCase() ?? '';
                    final gradeLevel = data['grade_level']?.toLowerCase() ?? '';

                    final fullName = '$firstName $middleName $lastName';

                    return studentId.contains(query) ||
                        fullName.contains(query) ||
                        track.contains(query) ||
                        strand.contains(query) ||
                        gradeLevel.contains(query);
                  }).toList();

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text('Student ID')),
                            Expanded(child: Text('First Name')),
                            Expanded(child: Text('Last Name')),
                            Expanded(child: Text('Middle Name')),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Track'),
                                  GestureDetector(
                                    onTap:
                                        _toggleTrackIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Strand'),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons
                                        .arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedStrand =
                                            value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        'ALL',
                                        'STEM',
                                        'HUMSS',
                                        'ABM',
                                        'ICT',
                                        'HE',
                                        'IA'
                                      ].map((String strand) {
                                        return PopupMenuItem<String>(
                                          value: strand,
                                          child: Text(strand),
                                        );
                                      }).toList();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  Text('Grade Level'),
                                  GestureDetector(
                                    onTap:
                                        _toggleGradeLevelIcon, // Handles the tap to change icons
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                1) // Show up arrow for state 0 and 1
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState ==
                                                2) // Show down arrow for state 0 and 2
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        ...students.map((student) {
                          final data = student.data() as Map<String, dynamic>;
                          return Row(
                            children: [
                              Checkbox(
                                  value: false, onChanged: (bool? value) {}),
                              Expanded(child: Text(data['student_id'] ?? '')),
                              Expanded(child: Text(data['first_name'] ?? '')),
                              Expanded(child: Text(data['last_name'] ?? '')),
                              Expanded(child: Text(data['middle_name'] ?? '')),
                              Expanded(
                                  child: Text(data['seniorHigh_Track'] ?? '')),
                              Expanded(
                                  child: Text(data['seniorHigh_Strand'] ?? '')),
                              Expanded(child: Text(data['grade_level'] ?? '')),
                              Expanded(
                                child: Row( 
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Iconsax.tick_circle_copy,
                                          color: Colors.green),
                                      onPressed: () {
                                        approveStudent(student.id);
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Iconsax.close_circle_copy,
                                          color: Colors.red),
                                      onPressed: () {
                                        deleteStudent(student.id);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the preferred height
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor:
              Colors.white, // Set the background color to match the image
          title: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 16.0, bottom: 16.0, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 30,
                  icon: Icon(Iconsax.menu_copy,
                      color: Colors.blue), // Use Iconsax.menu
                  onPressed: () {
                    _scaffoldKey.currentState
                        ?.openDrawer(); // Open the drawer when pressed
                  },
                ),
                Row(
                  children: [
                    Icon(
                      size: 30,
                      Iconsax.profile_circle_copy,
                    ),
                    SizedBox(
                        width: 15), // Add spacing between the icon and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$_accountType',
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 16, // Smaller font size for the label
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                        Text(
                          _email,
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 14, // Smaller font size for the email
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/PBMA.png', // Replace with your asset image path
                    height: 130,
                  ),
                ],
              ),
            ),
             _buildDrawerItem('Dashboard', Iconsax.dash_dash, 'Dashboard'),
            _buildDrawerItem('Students', Iconsax.user, 'Students'),
            _buildDrawerItem(
                'Strand Instructor', Iconsax.teacher, 'Strand Instructor'),
            _buildDrawerItem(
                'Manage Newcomers', Iconsax.task, 'Manage Newcomers'),
            _buildDrawerItem('Subjects and Instructor', Iconsax.activity,
                'Subjects and Instructor'),
            _buildDrawerItem(
                'Dropped Students', Iconsax.dropbox_copy, 'Dropped Students'),
            ListTile(
            leading: Icon(Iconsax.logout),
            title: Text('Log out'),
            onTap: () {
              // Show confirmation dialog before logging out
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    title: Text('Logout Confirmation'),
                    content: Text('Are you sure you want to do logout?'),
                    actions: <Widget>[
                      // Confirm button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          // Navigate to the Launcher (or perform actual logout)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Launcher()),
                          );
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue, // Blue background
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white), // White text
                        ),
                      ),
                      // Cancel button
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: TextButton.styleFrom(
                          side: BorderSide(color: Colors.blue), // Blue border
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue), // Blue text
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          ],
        ),
      ),
      body: _buildBodyContent(),
    );
  }
}
