import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pbma_portal/Manage/AddingSections.dart';
import 'package:pbma_portal/Manage/AddingSubjects.dart';
import 'package:pbma_portal/Manage/EditInstructor.dart';
import 'package:pbma_portal/Manage/EditSections.dart';
import 'package:pbma_portal/Manage/EditSubject.dart';
import 'package:pbma_portal/Manage/NewcomersValidator.dart';
import 'package:pbma_portal/Manage/Re-EnrolledValidator.dart';
import 'package:pbma_portal/Manage/StudentInSection.dart';
import 'package:pbma_portal/Manage/SubjectsandGrade.dart';
import 'package:pbma_portal/launcher.dart';
import 'package:pbma_portal/pages/Auth_View/Adding_InstructorAcc_Desktview.dart';
import 'package:pbma_portal/pages/banner.dart';
import 'package:pbma_portal/pages/news_updates.dart';
import 'package:pbma_portal/pages/student_details.dart';
import 'package:pbma_portal/pages/views/sections/desktop/contact_us.dart';
import 'package:pbma_portal/reports/enrollment_report/enrollment_report.dart';
import 'package:pbma_portal/pages/views/chatbot/faqs.dart';
import 'package:pbma_portal/student_utils/Student_Utils.dart';
import 'package:pbma_portal/Admin Dashboard Sorting/Dashboard Sorting.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedCourse = "All";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, bool> _selectedStudents = {};
  String _selectedDrawerItem = 'Dashboard';
  String _email = '';
  String _accountType = '';
  int _gradeLevelIconState = 0;
  int _transfereeIconState = 0;
  int _trackIconState = 0;
  String _selectedStrand = 'ALL';

  String? selectedSubjectId;
  String? selectedInstructorId;
  String? selectedSectionId;

  bool _showAddSubjects = false;
  bool _showEditSubjects = false;
  bool _showAddInstructors = false;
  bool _showEditInstructors = false;
  bool _showAddSections = false;
  bool _showEditSections = false;
  String _selectedSemester = '1st Semester'; // Initial semester option
  String _curriculum = ''; // Curriculum text
  bool _isLoading = true;
  DocumentSnapshot? _currentInstructorDoc;
  bool _isInstructorLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final DateFormat formatter = DateFormat('MM-dd-yyyy');

  Map<String, String> strandMapping = {
    'STEM': 'Science, Technology, Engineering and Mathematics (STEM)',
    'HUMSS': 'Humanities and Social Sciences (HUMSS)',
    'ABM': 'Accountancy, Business, and Management (ABM)',
    'ICT': 'Information and Communication Technology (ICT)',
    'HE': 'Home Economics (HE)',
    'IA': 'Industrial Arts (IA)',
  };

  //BuildDashboardContent
  Stream<QuerySnapshot> _getEnrolledStudentsCount() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('Status', isEqualTo: 'active')
        .where('enrollment_status',
            isEqualTo: 'approved'); // Always filter by 'approved'

    // Map icon states to Firestore values
    String? trackValue;
    if (_trackIconState == 1) {
      trackValue = 'Academic Track'; // Replace with actual Firestore value
    } else if (_trackIconState == 2) {
      trackValue =
          'Technical-Vocational-Livelihood (TVL)'; // Replace with actual Firestore value
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

      if (strandValue != null) {
        print("Applying strand filter: $strandValue");
        query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
      }
    }

    return query.snapshots();
  }
  //BuildDashBoardContent

  //BuildStudentsContent
  void moveToDropList() async {
    List<String> selectedStudentIds = _selectedStudents.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (selectedStudentIds.isNotEmpty) {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (String studentId in selectedStudentIds) {
        // Query the collection to find the document with student_id == studentId
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('student_id', isEqualTo: studentId)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Assuming 'student_id' is unique and we only get one document
          DocumentReference studentDoc = querySnapshot.docs.first.reference;

          // Add the 'Status' field and set its value to 'drop'
          batch.update(studentDoc, {
            'Status': 'inactive',
            'dropDate': FieldValue.serverTimestamp(),
          });
        } else {
          // Handle the case where the document doesn't exist
          print('Document with student_id $studentId not found.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Student with ID $studentId not found')),
          );
        }
      }

      // Commit the batch update if there are valid documents to update
      await batch.commit();

      // Optional: Show a confirmation message if some updates were successful
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected students moved to drop list')));

      // Clear the selected students list after updating Firestore
      setState(() {
        _selectedStudents.clear();
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No students selected')));
    }
  }

  Stream<QuerySnapshot> _getFilteredStudents() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('Status', isEqualTo: 'active'); // Filter for active students

    if (_trackIconState == 1) {
      query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
    } else if (_trackIconState == 2) {
      query = query.where('seniorHigh_Track',
          isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
    }

    // Add additional filters for grade level
    if (_gradeLevelIconState == 1) {
      query = query.where('grade_level', isEqualTo: '11');
    } else if (_gradeLevelIconState == 2) {
      query = query.where('grade_level', isEqualTo: '12');
    }

    // Add additional filters for transferee status
    if (_transfereeIconState == 1) {
      query = query.where('transferee', isEqualTo: 'yes');
    } else if (_transfereeIconState == 2) {
      query = query.where('transferee', isEqualTo: 'no');
    }

    // Add additional filters for selected strand
    if (_selectedStrand != 'ALL') {
      String? strandValue = strandMapping[_selectedStrand];

      if (strandValue != null) {
        print("Applying strand filter: $strandValue");
        query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
      }
    }
    // Return the query snapshots
    return query.snapshots();
  }

  bool get _isAnyStudentSelected {
    return _selectedStudents.values.any((isSelected) => isSelected);
  }

  void _showConfirmationStudentDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Confirm Action"),
          content: Text(
              "Are you sure you want to move the selected students to the drop list?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                moveToDropList(); // Call your function to move to drop list
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  //BuildStudentsContent

  //BuildStrandInstructorContent
  Stream<QuerySnapshot<Map<String, dynamic>>>
      _getFilteredInstructorStudents() async* {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    final userData = userDoc.data()!;
    final instructorFirstName = userData['first_name'];
    final instructorLastName = userData['last_name'];
    final instructorFullName = '$instructorFirstName $instructorLastName';

    // Fetch sections where the adviser matches the instructor's name
    final sectionsSnapshot = await FirebaseFirestore.instance
        .collection('sections')
        .where('section_adviser', isEqualTo: instructorFullName)
        .get();

    // Extract the section names from the sections where the adviser matches
    final sectionNames =
        sectionsSnapshot.docs.map((doc) => doc['section_name']).toList();

    // Now fetch the students that belong to these sections
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('users')
        .where('enrollment_status', isEqualTo: 'approved')
        .where('accountType', isEqualTo: 'student');

    // Filter students based on their section names if we have any
    if (sectionNames.isNotEmpty) {
      query = query.where('section', whereIn: sectionNames);
    }

    yield* query.snapshots();
  }
  //BuildStrandInstructorContent

  //BuildNewcomersContent
  Stream<QuerySnapshot> _getNewcomersStudents() {
    return getNewcomersStudents(_trackIconState, _gradeLevelIconState,
        _transfereeIconState, _selectedStrand);
  }

  void _showDeleteConfirmationDialog(BuildContext context, String studentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Delete Student"),
          content: Text("Are you sure you want to delete this student?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                deleteNewComersStudent(studentId); // Proceed to delete
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showAcceptConfirmationDialog(BuildContext context, String studentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Approve Student"),
          content: Text("Are you sure you want to approve this student?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                approveStudent(studentId);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void deleteNewComersStudent(String studentId) async {
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
  //BuildNewcomersContent

  //BuildManageSubjectsContent
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

  void toggleEditSubjects() {
    setState(() {
      _showEditSubjects = !_showEditSubjects;
    });
  }

  void closeEditSubjects() {
    setState(() {
      _showEditSubjects = false;
    });
  }

  void _deleteSubject(String subjectId) async {
    try {
      await FirebaseFirestore.instance
          .collection('subjects')
          .doc(subjectId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Subject deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting subject: $e')),
      );
    }
  }

  void _showDeleteSubjectConfirmation(BuildContext context, String subjectId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this subject?'),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          CupertinoDialogAction(
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              _deleteSubject(subjectId); // Call delete function
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
  //BuildManageSubjectsContent

  //BuildManageInstructorContent
  void toggleAddInstructors() {
    setState(() {
      _showAddInstructors = !_showAddInstructors;
    });
  }

  void closeAddInstructors() {
    setState(() {
      _showAddInstructors = false;
    });
  }

  void toggleEditInstructors() {
    setState(() {
      _showEditInstructors = !_showEditInstructors;
    });
  }

  void closeEditInstructors() {
    setState(() {
      _showEditInstructors = false;
    });
  }

  Future<void> _setInstructorStatusInactive(String instructorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(instructorId)
          .update({
        'Status': 'inactive', // Change the field name if it's different
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Instructor status updated to inactive')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<void> _setInstructorStatusActive(String instructorId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(instructorId)
          .update({
        'Status': 'active', // Change the field name if it's different
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Instructor status updated to inactive')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  void _showStatusChangeDialog(
      BuildContext context, String instructorId, String newStatus) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Confirm Action"),
          content:
              Text("Are you sure you want to change the status to $newStatus?"),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                // Call the appropriate method based on the new status
                if (newStatus == 'inactive') {
                  _setInstructorStatusInactive(instructorId); // Call the method
                } else {
                  _setInstructorStatusActive(instructorId); // Call the method
                }
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
  //BuildManageInstructorContent

  //BuildDropStudent
  Stream<QuerySnapshot> _getFilteredDropStudents() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('Status', isEqualTo: 'inactive'); // Filter for active students

    if (_trackIconState == 1) {
      query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
    } else if (_trackIconState == 2) {
      query = query.where('seniorHigh_Track',
          isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
    }

    // Add additional filters for grade level
    if (_gradeLevelIconState == 1) {
      query = query.where('grade_level', isEqualTo: '11');
    } else if (_gradeLevelIconState == 2) {
      query = query.where('grade_level', isEqualTo: '12');
    }

    // Add additional filters for transferee status
    if (_transfereeIconState == 1) {
      query = query.where('transferee', isEqualTo: 'yes');
    } else if (_transfereeIconState == 2) {
      query = query.where('transferee', isEqualTo: 'no');
    }

    // Add additional filters for selected strand
    if (_selectedStrand != 'ALL') {
      String? strandValue = strandMapping[_selectedStrand];

      if (strandValue != null) {
        print("Applying strand filter: $strandValue");
        query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
      }
    }
    // Return the query snapshots
    return query.snapshots();
  }

  Future<void> _setStudentStatusActive(String studentId) async {
    try {
      // Retrieve the document with the matching student_id
      var studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('student_id', isEqualTo: studentId)
          .get();

      // Check if a document was found
      if (studentDoc.docs.isNotEmpty) {
        // Update the status field to 'active'
        await studentDoc.docs.first.reference.update({
          'Status': 'active',
          'dropDate': FieldValue.delete(),
        });
        print('Student status updated to active for ID: $studentId');
      } else {
        print('No student found with ID: $studentId');
      }
    } catch (e) {
      print('Error updating student status: $e');
    }
  }

  void showConfirmationDropDialog(
      BuildContext context, String studentId) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Confirm Action'),
          content: Text('Do you want to activate this student?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog after action
                _setStudentStatusActive(
                    studentId); // Call the function to set student status active
              },
            ),
          ],
        );
      },
    );
  }
  //BuildDropStudent

  //BuildManageSections
  void toggleAddSections() {
    setState(() {
      _showAddSections = !_showAddSections;
    });
  }

  void closeAddSections() {
    setState(() {
      _showAddSections = false;
    });
  }

  void toggleEditSections() {
    setState(() {
      _showEditSections = !_showEditSections;
    });
  }

  void closeEditSections() {
    setState(() {
      _showEditSections = false;
    });
  }

  void _deleteSection(String sectionId) async {
    try {
      await FirebaseFirestore.instance
          .collection('sections')
          .doc(sectionId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Section deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting section: $e')),
      );
    }
  }

  void _showDeleteSectionConfirmation(BuildContext context, String sectionId) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this subject?'),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          CupertinoDialogAction(
            child: Text(
              'Yes',
              style: TextStyle(color: Colors.blue),
            ),
            onPressed: () {
              _deleteSection(sectionId); // Call delete function
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }
  //BuildManageSections

  // Configuration
  // Method to save data to Firebase
  void _saveConfiguration() {
    FirebaseFirestore.instance
        .collection('configurations')
        .doc('currentConfig')
        .set({
      'curriculum': _curriculum,
      'semester': _selectedSemester,
    }).then((_) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Configuration saved successfully!')),
      );

      // Update enrollment status for all students
      await _updateEnrollmentStatusForStudents();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save configuration: $error')),
      );
    });
  }

// Function to update enrollment status for all students
  Future<void> _updateEnrollmentStatusForStudents() async {
    try {
      // Query to get all documents with accountType = "student"
      QuerySnapshot studentDocs = await FirebaseFirestore.instance
          .collection(
              'users') // replace 'users' with the actual name of your users collection
          .where('accountType', isEqualTo: 'student')
          .get();

      // Batch update to change enrollment_status for each student document
      WriteBatch batch = FirebaseFirestore.instance.batch();

      for (QueryDocumentSnapshot doc in studentDocs.docs) {
        batch.update(doc.reference, {'enrollment_status': 're-enrolled'});
      }

      // Commit the batch update
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enrollment status updated for all students.')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update enrollment status: $error')),
      );
    }
  }

  // Configuration

  // Re-Enrolled Students
  Stream<QuerySnapshot> _getReEnrolledStudents() {
    return getReEnrolledStudents(_trackIconState, _gradeLevelIconState,
        _transfereeIconState, _selectedStrand);
  }

  Future<void> updateEnrollmentStatus(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({
        'enrollment_status': 'approved',
      });
      // Optionally return a success message or handle success feedback here
    } catch (error) {
      // Optionally throw the error or return it for further handling
      throw Exception('Failed to update enrollment status: $error');
    }
  }

  // Re-Enrolled Students

  //Filtering
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
  //Filtering

  //Disabling Drawer
  bool _isItemDisabled(String item) {
    if (_accountType == 'INSTRUCTOR') {
      return item != 'Strand Teacher';
    } else if (_accountType == 'ADMIN') {
      return item == 'Strand Teacher';
    }
    return false;
  }

  Widget _buildDrawerItem(String title, IconData icon, String drawerItem) {
    bool isDisabled = _isItemDisabled(drawerItem);

    if (_accountType == 'INSTRUCTOR') {
      if (drawerItem != 'Strand Teacher') {
        return SizedBox.shrink(); // Hide other drawer items
      }
    }

    return ListTile(
      leading: Icon(icon, color: isDisabled ? Colors.grey : Colors.black),
      title: Text(title,
          style: TextStyle(color: isDisabled ? Colors.grey : Colors.black)),
      onTap: isDisabled ? null : () => _onDrawerItemTapped(drawerItem),
    );
  }
  //Disabling Drawer

  //Retrieving the Current AccountType
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
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
    } finally {
      setState(() {
        _isLoading = false; // Set loading to false after data is loaded
      });
    }
  }

  Future<void> _loadSelectedDrawerItem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Only load drawer state if it matches the current account type
    if (_accountType == 'INSTRUCTOR') {
      setState(() {
        _selectedDrawerItem =
            'Strand Teacher'; // Always set to Strand Teacher for instructors
      });
    } else if (_accountType == 'ADMIN') {
      String? savedItem = prefs.getString('adminDrawerItem');
      setState(() {
        _selectedDrawerItem = savedItem ?? 'Dashboard';
      });
    }
  }

  Future<void> _saveSelectedDrawerItem(String item) async {
    // Only save drawer state for admin users
    if (_accountType == 'ADMIN') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('adminDrawerItem', item);
    }
  }

  void _onDrawerItemTapped(String item) async {
    await _saveSelectedDrawerItem(item);
    setState(() {
      _selectedDrawerItem = item;
    });
    Navigator.pop(context); // Close the drawer
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      print("User logged out successfully");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (builder) => Launcher()));
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  Future<void> _fetchInstructorData() async {
    try {
      String currentInstructorUid = FirebaseAuth.instance.currentUser!.uid;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'instructor')
          .get();

      if (snapshot.docs.isNotEmpty) {
        _currentInstructorDoc = snapshot.docs.firstWhere(
          (doc) => doc.id == currentInstructorUid,
          orElse: () => throw Exception('Instructor not found'),
        );
      }
    } catch (e) {
      print('Error fetching instructor data: $e');
    } finally {
      setState(() {
        _isInstructorLoading = false;
      });
    }
  }

  Stream<List<DocumentSnapshot>> _getStudentsWithSubject(String subjectName) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', isEqualTo: 'approved')
        .snapshots()
        .asyncMap((snapshot) async {
      List<DocumentSnapshot> matchingStudents = [];

      for (var studentDoc in snapshot.docs) {
        var sectionsSnapshot =
            await studentDoc.reference.collection('sections').get();

        for (var sectionDoc in sectionsSnapshot.docs) {
          var sectionData = sectionDoc.data();
          List<dynamic> subjects = sectionData['subjects'] ?? [];

          print('Checking student ${studentDoc.id}');
          print('Section: ${sectionData['selectedSection']}');
          print('Subjects: $subjects');
          print('Looking for subject: $subjectName');

          // Changed subject_Name to subject_name to match the data structure
          if (subjects
              .any((subject) => subject['subject_name'] == subjectName)) {
            print('Found matching student: ${studentDoc.id}');
            matchingStudents.add(studentDoc);
            break;
          }
        }
      }

      print('Total matching students: ${matchingStudents.length}');
      return matchingStudents;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData().then((_) {
      _loadSelectedDrawerItem(); // Load drawer item after fetching user data
    });
    _fetchInstructorData(); // Add this line
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

  Widget _buildBodyContent() {
    switch (_selectedDrawerItem) {
      case 'Dashboard':
        return _buildDashboardContent();
      case 'Students':
        return _buildStudentsContent();
      case 'Strand Teacher':
        return _buildStrandTeacherContent();
      case 'Manage Newcomers':
        return _buildNewcomersContent();
      case 'Manage Re-Enrolled Students':
        return _buildReEnrolledStudentContent();
      case 'Manage Subjects':
        return _buildManageSubjects();
      case 'Manage Teachers':
        return _buildManageTeachersContent();
      case 'Configuration':
        return _buildConfigurationContent();
      case 'Manage Sections':
        return _buildManageSections();
      case 'Dropped Student':
        return _buildDropStudent();
      case 'Banner':
        return BannerImage();
      case 'News and Updates':
        return NewsUpdates();
      case 'FAQS':
        return FAQAdminPage();
      case 'Reports':
        return _buildAnalytics();
      default:
        return Center(child: Text('Body Content Here'));
    }
  }

  //method para sa Adviser and Not Adviser
  Widget _buildStrandTeacherContent() {
    if (_isInstructorLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_currentInstructorDoc == null) {
      return Center(child: Text('No instructor data found'));
    }

    final adviserStatus = _currentInstructorDoc!.get('adviser');

    if (adviserStatus == 'yes') {
      return _buildInstructorWithAdviserDrawer(_currentInstructorDoc!);
    } else {
      return _buildInstructorWithoutAdviserDrawer(_currentInstructorDoc!);
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Center(
                            child:
                                CircularProgressIndicator()), // Loader while waiting
                      );
                    }

                    if (!snapshot.hasData) {
                      // If there are no enrolled students, display "0"
                      return Container(
                        width: 120,
                        height: 60,
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0), // Adjust padding
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // Align the content horizontally
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
                                    fontSize:
                                        10.0, // Smaller text to fit within the box
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

                  return Column(
                    children: [
                      // Fixed header row
                      Row(
                        children: [
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Track'),
                                GestureDetector(
                                  onTap: _toggleTrackIcon,
                                  child: Row(
                                    children: [
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  icon: Icon(Icons.arrow_drop_down),
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedStrand = value;
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
                                  onTap: _toggleGradeLevelIcon,
                                  child: Row(
                                    children: [
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  onTap: _toggleTransfereeIcon,
                                  child: Row(
                                    children: [
                                      if (_transfereeIconState == 0 ||
                                          _transfereeIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_transfereeIconState == 0 ||
                                          _transfereeIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),

                      // Scrollable rows for student data
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: students.map((student) {
                              final data =
                                  student.data() as Map<String, dynamic>;
                              return Row(
                                children: [
                                  Expanded(
                                      child: Text(data['student_id'] ?? '')),
                                  Expanded(
                                      child: Text(data['first_name'] ?? '')),
                                  Expanded(
                                      child: Text(data['last_name'] ?? '')),
                                  Expanded(
                                      child: Text(data['middle_name'] ?? '')),
                                  Expanded(
                                      child:
                                          Text(data['seniorHigh_Track'] ?? '')),
                                  Expanded(
                                      child: Text(
                                          data['seniorHigh_Strand'] ?? '')),
                                  Expanded(
                                      child: Text(data['grade_level'] ?? '')),
                                  Expanded(
                                      child: Text(data['transferee'] ?? '')),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
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
                      _showConfirmationStudentDialog(context);
                    },
                    child: Text('Move to Drop List',
                        style: TextStyle(color: Colors.black)),
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
                    final transferee = data['transferee']?.toLowerCase() ?? '';

                    final fullName = '$firstName $middleName $lastName';

                    return studentId.contains(query) ||
                        fullName.contains(query) ||
                        track.contains(query) ||
                        strand.contains(query) ||
                        gradeLevel.contains(query) ||
                        transferee.contains(query);
                  }).toList();

                  return Column(
                    children: [
                      // Fixed header row
                      Row(
                        children: [
                          SizedBox(width: 32),
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Track'),
                                GestureDetector(
                                  onTap: _toggleTrackIcon,
                                  child: Row(
                                    children: [
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  icon: Icon(Icons.arrow_drop_down),
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedStrand = value;
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
                                  onTap: _toggleGradeLevelIcon,
                                  child: Row(
                                    children: [
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  onTap: _toggleTransfereeIcon,
                                  child: Row(
                                    children: [
                                      if (_transfereeIconState == 0 ||
                                          _transfereeIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_transfereeIconState == 0 ||
                                          _transfereeIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(),

                      // Scrollable rows for student data
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: students.map((student) {
                              final data =
                                  student.data() as Map<String, dynamic>;
                              String studentId = data['student_id'] ?? '';
                              return GestureDetector(
                                onTap: () {
                                  final studentDocId =
                                      student.id; // Get the document ID here
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StudentDetails(
                                        studentData: data,
                                        studentDocId: studentDocId,
                                      ),
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _selectedStudents[studentId] ??
                                            false,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            _selectedStudents[studentId] =
                                                value!;
                                          });
                                        },
                                      ),
                                      Expanded(
                                          child:
                                              Text(data['student_id'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['first_name'] ?? '')),
                                      Expanded(
                                          child: Text(data['last_name'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['middle_name'] ?? '')),
                                      Expanded(
                                          child: Text(
                                              data['seniorHigh_Track'] ?? '')),
                                      Expanded(
                                          child: Text(
                                              data['seniorHigh_Strand'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['grade_level'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['transferee'] ?? '')),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructorWithAdviserDrawer(DocumentSnapshot doc) {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Strand Teacher',
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
                    final strand =
                        data['seniorHigh_Strand']?.toLowerCase() ?? '';

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
                            // Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text('Student ID')),
                            Expanded(child: Text('Name')),
                            Expanded(
                              child: Text('Track'),
                            ),
                            Expanded(
                              child: Text('Strand'),
                            ),
                            Expanded(
                              child: Text('Grade Level'),
                            ),
                            // Expanded(child: Text('Average')),
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
                                // Checkbox(
                                //     value: false, onChanged: (bool? value) {}),
                                Expanded(child: Text(data['student_id'] ?? '')),
                                Expanded(
                                    child: Text(
                                        '${data['first_name'] ?? ''} ${data['middle_name'] ?? ''} ${data['last_name'] ?? ''}')),
                                Expanded(
                                    child:
                                        Text(data['seniorHigh_Track'] ?? '')),
                                Expanded(
                                    child:
                                        Text(data['seniorHigh_Strand'] ?? '')),
                                Expanded(
                                    child: Text(data['grade_level'] ?? '')),
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

  // Widget for instructors without adviser status
  Widget _buildInstructorWithoutAdviserDrawer(DocumentSnapshot doc) {
    final subjectName = doc['subject_Name'];

    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'My Classes',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Subject: ${doc['subject_Name'] ?? 'Not assigned'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 20),
                Text(
                  'Subject Code: ${doc['subject_Code'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: StreamBuilder<List<DocumentSnapshot>>(
                // Use a custom stream that fetches students with matching subjects
                stream: _getStudentsWithSubject(subjectName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No students found'));
                  }

                  final students = snapshot.data!;

                  return Column(
                    children: [
                      // Header Row
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text('Student ID',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                child: Text('Name',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                child: Text('Section',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                child: Text('Grade Level',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                            Expanded(
                                child: Text('Strand',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ),
                      Divider(),
                      // Student List
                      Expanded(
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final studentData =
                                students[index].data() as Map<String, dynamic>;
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            studentData['student_id'] ?? '')),
                                    Expanded(
                                      child: Text(
                                          '${studentData['first_name'] ?? ''} ${studentData['last_name'] ?? ''}'),
                                    ),
                                    Expanded(
                                        child:
                                            Text(studentData['section'] ?? '')),
                                    Expanded(
                                        child: Text(
                                            studentData['grade_level'] ?? '')),
                                    Expanded(
                                        child: Text(
                                            studentData['seniorHigh_Strand'] ??
                                                '')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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

                  return Column(
                    children: [
                      // Fixed header row
                      Row(
                        children: [
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Track'),
                                GestureDetector(
                                  onTap: _toggleTrackIcon,
                                  child: Row(
                                    children: [
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  icon: Icon(Icons.arrow_drop_down),
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedStrand = value;
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
                                  onTap: _toggleGradeLevelIcon,
                                  child: Row(
                                    children: [
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: Text('')),
                        ],
                      ),
                      Divider(),

                      // Scrollable rows for student data
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: students.map((student) {
                              final data =
                                  student.data() as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Newcomersvalidator(
                                                  studentData: data)));
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child:
                                              Text(data['first_name'] ?? '')),
                                      Expanded(
                                          child: Text(data['last_name'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['middle_name'] ?? '')),
                                      Expanded(
                                          child: Text(
                                              data['seniorHigh_Track'] ?? '')),
                                      Expanded(
                                          child: Text(
                                              data['seniorHigh_Strand'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['grade_level'] ?? '')),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                  Iconsax.tick_circle_copy,
                                                  color: Colors.green),
                                              onPressed: () {
                                                _showAcceptConfirmationDialog(
                                                    context, student.id);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                  Iconsax.close_circle_copy,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _showDeleteConfirmationDialog(
                                                    context, student.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSubjects() {
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
              // Dropdown for selecting a course
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Filter by Course:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16),
                    DropdownButton<String>(
                      value: selectedCourse,
                      items: [
                        "All",
                        "STEM",
                        "ABM",
                        "HUMSS",
                        "ICT",
                        "HE",
                        "IA"
                      ] // Add all your course options here
                          .map((course) => DropdownMenuItem<String>(
                                value: course,
                                child: Text(course),
                              ))
                          .toList(),
                      onChanged: (course) {
                        setState(() {
                          selectedCourse = course!;
                        });
                      },
                    ),
                  ],
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

                        // Fixed header row
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(50.0),
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
                                  child: Text('#',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Course',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Subject Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Category',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Semester',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Actions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Scrollable data rows
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('subjects')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No Subject Added',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              // Sort and filter subjects by selected course
                              final subjects = snapshot.data!.docs;
                              subjects.sort((a, b) => a['strandcourse']
                                  .compareTo(b['strandcourse']));

                              // Apply filtering based on the selected course
                              final filteredSubjects = selectedCourse == "All"
                                  ? subjects
                                  : subjects
                                      .where((subject) =>
                                          subject['strandcourse'] ==
                                          selectedCourse)
                                      .toList();

                              return SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FixedColumnWidth(50.0),
                                    1: FlexColumnWidth(),
                                    2: FlexColumnWidth(),
                                    3: FlexColumnWidth(),
                                    4: FlexColumnWidth(),
                                    5: FlexColumnWidth(),
                                    6: FixedColumnWidth(100.0),
                                  },
                                  children: [
                                    for (var i = 0;
                                        i < filteredSubjects.length;
                                        i++)
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text((i + 1).toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(filteredSubjects[i]
                                                ['strandcourse']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(filteredSubjects[i]
                                                ['subject_name']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(filteredSubjects[i]
                                                ['subject_code']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(filteredSubjects[i]
                                                ['category']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(filteredSubjects[i]
                                                ['semester']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedSubjectId =
                                                          filteredSubjects[i]
                                                              .id;
                                                      _showEditSubjects = true;
                                                    });
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    _showDeleteSubjectConfirmation(
                                                        context,
                                                        filteredSubjects[i].id);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
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
              ? Stack(children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: closeAddSubjects,
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child:
                                Container(color: Colors.black.withOpacity(0.5)),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: screenWidth / 1.2,
                                height: screenHeight / 1.2,
                                curve: Curves.easeInOut,
                                child: AddSubjectsForm(
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  key: ValueKey('AddSubjects'),
                                  closeAddSubjects: closeAddSubjects,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])
              : SizedBox.shrink(),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 550),
          child: _showEditSubjects
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: closeEditSubjects,
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: screenWidth / 1.2,
                                  height: screenHeight / 1.2,
                                  curve: Curves.easeInOut,
                                  child: EditSubjectsForm(
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth,
                                    subjectId:
                                        selectedSubjectId, // Pass the selected subject ID
                                    closeEditSubjects: closeEditSubjects,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        )
      ],
    );
  }

  Widget _buildManageTeachersContent() {
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
                  'Manage Teachers',
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
                    onPressed: toggleAddInstructors,
                    child: Text(
                      'Add New Teacher',
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
                          'Teacher Lists',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Fixed header row
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(40.0),
                            1: FlexColumnWidth(),
                            2: FlexColumnWidth(),
                            3: FlexColumnWidth(),
                            4: FlexColumnWidth(),
                            5: FlexColumnWidth(),
                            6: FlexColumnWidth(),
                            7: FixedColumnWidth(160.0),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('#',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Teacher Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Email Address',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Subjects',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Subject Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Adviser',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Handled Section',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Actions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Scrollable data rows
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .where('accountType', isEqualTo: 'instructor')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No Teacher Added',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              final users = snapshot.data!.docs;

                              return SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FixedColumnWidth(40.0),
                                    1: FlexColumnWidth(),
                                    2: FlexColumnWidth(),
                                    3: FlexColumnWidth(),
                                    4: FlexColumnWidth(),
                                    5: FlexColumnWidth(),
                                    6: FlexColumnWidth(),
                                    7: FixedColumnWidth(160.0),
                                  },
                                  children: [
                                    for (var i = 0; i < users.length; i++)
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text((i + 1).toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${users[i]['first_name']} '
                                              '${users[i]['middle_name']?.isNotEmpty == true ? users[i]['middle_name'] + ' ' : ''}'
                                              '${users[i]['last_name']}',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text(users[i]['email_Address']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text(users[i]['subject_Name']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text(users[i]['subject_Code']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(users[i]['adviser']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(users[i]
                                                    ['handled_section'] ??
                                                'N/A'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    setState(() {
                                                      selectedInstructorId =
                                                          users[i].id;
                                                      toggleEditInstructors();
                                                    });
                                                  },
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: DropdownButton<String>(
                                                    value: users[i][
                                                        'Status'], // Assuming 'status' holds 'active' or 'inactive'
                                                    icon: Icon(Icons
                                                        .more_vert), // Dropdown icon
                                                    items: <String>[
                                                      'active',
                                                      'inactive'
                                                    ].map((String status) {
                                                      return DropdownMenuItem<
                                                          String>(
                                                        value: status,
                                                        child: Text(status),
                                                      );
                                                    }).toList(),
                                                    onChanged:
                                                        (String? newStatus) {
                                                      if (newStatus != null &&
                                                          newStatus !=
                                                              users[i]
                                                                  ['Status']) {
                                                        _showStatusChangeDialog(
                                                            context,
                                                            users[i].id,
                                                            newStatus); // Call the dialog method
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
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
          child: _showAddInstructors
              ? Stack(children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: closeAddInstructors,
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child:
                                Container(color: Colors.black.withOpacity(0.5)),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: screenWidth / 1.2,
                                height: screenHeight / 1.2,
                                curve: Curves.easeInOut,
                                child: AddInstructorDialog(
                                  screenHeight: screenHeight,
                                  screenWidth: screenWidth,
                                  key: ValueKey('AddInstructor'),
                                  closeAddInstructors: closeAddInstructors,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])
              : SizedBox.shrink(),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 550),
          child: _showEditInstructors
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: closeEditInstructors,
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: screenWidth / 1.2,
                                  height: screenHeight / 1.2,
                                  curve: Curves.easeInOut,
                                  child: EditInstructor(
                                    instructorId: selectedInstructorId,
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth,
                                    closeEditInstructors: closeEditInstructors,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        )
      ],
    );
  }

  Widget _buildConfigurationContent() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This is Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 16),

          // Curriculum Text Field
          CupertinoTextField(
            placeholder: 'Enter Curriculum',
            onChanged: (value) {
              setState(() {
                _curriculum = value;
              });
            },
          ),
          SizedBox(height: 16),

          // Semester Selection Radio Buttons
          ListTile(
            title: Text('1st Semester'),
            leading: Radio<String>(
              value: '1st Semester',
              groupValue: _selectedSemester,
              onChanged: (String? value) {
                setState(() {
                  _selectedSemester = value!;
                });
              },
            ),
          ),
          ListTile(
            title: Text('2nd Semester'),
            leading: Radio<String>(
              value: '2nd Semester',
              groupValue: _selectedSemester,
              onChanged: (String? value) {
                setState(() {
                  _selectedSemester = value!;
                });
              },
            ),
          ),

          // Save Button
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _curriculum.isNotEmpty ? _saveConfiguration : null,
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildReEnrolledStudentContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Manage Re-Enrolled Students',
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
                stream: _getReEnrolledStudents(),
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

                  return Column(
                    children: [
                      // Fixed header row
                      Row(
                        children: [
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Track'),
                                GestureDetector(
                                  onTap: _toggleTrackIcon,
                                  child: Row(
                                    children: [
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  icon: Icon(Icons.arrow_drop_down),
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedStrand = value;
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
                                  onTap: _toggleGradeLevelIcon,
                                  child: Row(
                                    children: [
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: Text('')),
                        ],
                      ),
                      Divider(),

                      // Scrollable rows for student data
                      Expanded(
                        child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                          child: SingleChildScrollView(
                            child: Column(
                              children: students.map((student) {
                                final data =
                                    student.data() as Map<String, dynamic>;
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReEnrolledValidator(studentData: data)));
                                  },
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Text(data['first_name'] ?? '')),
                                      Expanded(
                                          child: Text(data['last_name'] ?? '')),
                                      Expanded(
                                          child: Text(data['middle_name'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['seniorHigh_Track'] ?? '')),
                                      Expanded(
                                          child: Text(
                                              data['seniorHigh_Strand'] ?? '')),
                                      Expanded(
                                          child: Text(data['grade_level'] ?? '')),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(Iconsax.tick_circle_copy,
                                                  color: Colors.green),
                                              onPressed: () {
                                                updateEnrollmentStatus(student.id);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Iconsax.close_circle_copy,
                                                  color: Colors.red),
                                              onPressed: () {
                                                (context, student.id);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageSections() {
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
                  'Manage Sections',
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
                    onPressed: toggleAddSections,
                    child: Text(
                      'Add New Sections',
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
                          'Sections List',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Fixed header row
                        Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(40.0),
                            1: FlexColumnWidth(),
                            2: FlexColumnWidth(),
                            3: FlexColumnWidth(),
                            4: FlexColumnWidth(),
                            5: FlexColumnWidth(),
                            6: FixedColumnWidth(160.0),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('#',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Section Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Section Adviser',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Semester',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Section Capacity',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Capacity Count',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Actions',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),

                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('sections')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'No Section Added',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              final sections = snapshot.data!.docs;

                              return SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FixedColumnWidth(40.0),
                                    1: FlexColumnWidth(),
                                    2: FlexColumnWidth(),
                                    3: FlexColumnWidth(),
                                    4: FlexColumnWidth(),
                                    5: FlexColumnWidth(),
                                    6: FixedColumnWidth(160.0),
                                  },
                                  children: [
                                    for (var i = 0; i < sections.length; i++)
                                      TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text((i + 1).toString()),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                sections[i]['section_name']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                sections[i]['section_adviser']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text(sections[i]['semester']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(sections[i]
                                                    ['section_capacity']
                                                .toString()),
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection('users')
                                                .where('section',
                                                    isEqualTo: sections[i]
                                                        ['section_name'])
                                                .snapshots(),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Transform.scale(
                                                    scale: 0.5,
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                );
                                              }

                                              if (userSnapshot.hasData) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(userSnapshot
                                                      .data!.docs.length
                                                      .toString()),
                                                );
                                              } else {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text('0'),
                                                );
                                              }
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                      Icons
                                                          .remove_red_eye_sharp,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            StudentInSection(
                                                          sectionName: sections[
                                                                  i]
                                                              ['section_name'],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(Icons.edit,
                                                      color: Colors.blue),
                                                  onPressed: () {
                                                    selectedSectionId =
                                                        sections[i].id;
                                                    toggleEditSections();
                                                  },
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.delete_forever,
                                                      color: Colors.red),
                                                  onPressed: () {
                                                    _showDeleteSectionConfirmation(
                                                        context,
                                                        sections[i].id);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              );
                            },
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
          child: _showAddSections
              ? Stack(children: [
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: closeAddSections,
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child:
                                Container(color: Colors.black.withOpacity(0.5)),
                          ),
                          Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: screenWidth / 1.2,
                                height: screenHeight / 1.2,
                                curve: Curves.easeInOut,
                                child: AddingSections(
                                  screenWidth: screenWidth,
                                  screenHeight: screenHeight,
                                  key: ValueKey('AddSections'),
                                  closeAddSections: closeAddSections,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])
              : SizedBox.shrink(),
        ),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 550),
          child: _showEditSections
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: closeEditSections,
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: screenWidth / 1.2,
                                  height: screenHeight / 1.2,
                                  curve: Curves.easeInOut,
                                  child: EditSectionsForm(
                                    screenHeight: screenHeight,
                                    screenWidth: screenWidth,
                                    sectionId: selectedSectionId,
                                    key: ValueKey('EditSections'),
                                    closeEditSections: closeEditSections,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
        )
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
                stream: _getFilteredDropStudents(),
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

                  return Column(
                    children: [
                      // Fixed header row
                      Row(
                        children: [
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Track'),
                                GestureDetector(
                                  onTap: _toggleTrackIcon,
                                  child: Row(
                                    children: [
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_trackIconState == 0 ||
                                          _trackIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
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
                                  icon: Icon(Icons.arrow_drop_down),
                                  onSelected: (String value) {
                                    setState(() {
                                      _selectedStrand = value;
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
                                  onTap: _toggleGradeLevelIcon,
                                  child: Row(
                                    children: [
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 1)
                                        Icon(Iconsax.arrow_up_3_copy, size: 16),
                                      if (_gradeLevelIconState == 0 ||
                                          _gradeLevelIconState == 2)
                                        Icon(Iconsax.arrow_down_copy, size: 16),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: Text('Date')),
                          Expanded(child: Text('Actions')),
                        ],
                      ),
                      Divider(),

                      // Scrollable student list
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: students.map((student) {
                              final data =
                                  student.data() as Map<String, dynamic>;
                              return Row(
                                children: [
                                  Expanded(
                                      child: Text(data['student_id'] ?? '')),
                                  Expanded(
                                      child: Text(data['first_name'] ?? '')),
                                  Expanded(
                                      child: Text(data['last_name'] ?? '')),
                                  Expanded(
                                      child: Text(data['middle_name'] ?? '')),
                                  Expanded(
                                      child:
                                          Text(data['seniorHigh_Track'] ?? '')),
                                  Expanded(
                                      child: Text(
                                          data['seniorHigh_Strand'] ?? '')),
                                  Expanded(
                                      child: Text(data['grade_level'] ?? '')),
                                  Expanded(
                                    child: Text(
                                      data['dropDate'] != null
                                          ? formatter.format(
                                              (data['dropDate'] as Timestamp)
                                                  .toDate())
                                          : '',
                                    ),
                                  ),
                                  Expanded(
                                    child: TextButton(
                                      onPressed: () {
                                        showConfirmationDropDialog(
                                            context, data['student_id']);
                                      },
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        shadowColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                        overlayColor: MaterialStateProperty.all(
                                            Colors.transparent),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.transparent),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                        foregroundColor: MaterialStateProperty
                                            .resolveWith<Color>(
                                          (Set<MaterialState> states) {
                                            if (states.contains(
                                                MaterialState.hovered)) {
                                              return Colors.green;
                                            }
                                            return Colors.red;
                                          },
                                        ),
                                      ),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Reactivate',
                                                style: TextStyle(fontSize: 14),
                                              ),
                                              SizedBox(width: 4),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalytics() {
    return EnrollmentReport();
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
                    // Icon(
                    //   size: 30,
                    //   Iconsax.profile_circle_copy,
                    // ),
                    SizedBox(
                        width: 15), // Add spacing between the icon and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _accountType == 'ADMIN'
                              ? 'ADMIN'
                              : (_accountType == 'INSTRUCTOR' ? 'TEACHER' : ''),
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
            if (_accountType == 'ADMIN') ...[
              _buildDrawerItem('Dashboard', Iconsax.dash_dash, 'Dashboard'),
              _buildDrawerItem('Students', Iconsax.user, 'Students'),
              _buildDrawerItem(
                  'Manage Newcomers', Iconsax.task, 'Manage Newcomers'),
              _buildDrawerItem('Manage Re-Enrolled Students ', Iconsax.task,
                  'Manage Re-Enrolled Students'),
              _buildDrawerItem(
                  'Manage Subjects', Iconsax.activity, 'Manage Subjects'),
              _buildDrawerItem(
                  'Manage Teachers', Iconsax.user, 'Manage Teachers'),
              _buildDrawerItem(
                  'Manage Sections', Iconsax.user, 'Manage Sections'),
              _buildDrawerItem(
                  'Dropped Student', Iconsax.dropbox_copy, 'Dropped Student'),
              _buildDrawerItem('Configuration', Iconsax.user, 'Configuration'),
              _buildDrawerItem('Banner', Iconsax.image_copy, 'Banner'),
              _buildDrawerItem('News and Updates', Iconsax.activity_copy,
                  'News and Updates'),
              _buildDrawerItem('FAQS', Iconsax.message_2_copy, 'FAQS'),
              _buildDrawerItem('Reports', Iconsax.data_copy, 'Reports'),
            ] else if (_accountType == 'INSTRUCTOR') ...[
              _buildDrawerItem(
                  'Strand Teacher', Iconsax.teacher, 'Strand Teacher'),
            ],
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
                            logout();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue, // Blue background
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
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
      body: _isLoading
          ? Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    WavyAnimatedText('LOADING...'),
                  ],
                  isRepeatingAnimation: true,
                ),
              ),
            )
          : _buildBodyContent(),
    );
  }
}
