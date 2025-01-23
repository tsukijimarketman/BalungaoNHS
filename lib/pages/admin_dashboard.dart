// ignore_for_file: unnecessary_null_comparison, unused_local_variable
import 'dart:ui';
import 'package:balungao_nhs/Manage/JHSStudentDetails.dart';
import 'package:balungao_nhs/Manage/JHSStudentInSection.dart';
import 'package:balungao_nhs/Manage/JHSStudentReportCard.dart';
import 'package:balungao_nhs/Manage/SubjectsandGradeJHS.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:balungao_nhs/Manage/AddingSections.dart';
import 'package:balungao_nhs/Manage/AddingSubjects.dart';
import 'package:balungao_nhs/Manage/EditInstructor.dart';
import 'package:balungao_nhs/Manage/EditSections.dart';
import 'package:balungao_nhs/Manage/EditSubject.dart';
import 'package:balungao_nhs/Manage/NewcomersValidator.dart';
import 'package:balungao_nhs/Manage/Re-EnrolledValidator.dart';
import 'package:balungao_nhs/Manage/SHSStudentInSection.dart';
import 'package:balungao_nhs/Manage/StudentReportCard.dart';
import 'package:balungao_nhs/Manage/SubjectsandGrade.dart';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/pages/Auth_View/Adding_InstructorAcc_Desktview.dart';
import 'package:balungao_nhs/pages/banner.dart';
import 'package:balungao_nhs/pages/news_updates.dart';
import 'package:balungao_nhs/pages/student_details.dart';
import 'package:balungao_nhs/reports/enrollment_report/enrollment_report.dart';
import 'package:balungao_nhs/pages/views/chatbot/faqs.dart';
import 'package:balungao_nhs/student_utils/Student_Utils.dart';
import 'package:balungao_nhs/Admin Dashboard Sorting/Dashboard Sorting.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String selectedCourse = "All";
  String _selectedSchoolYear = "All"; // Default value
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, bool> _selectedStudents = {};
  String _selectedDrawerItem = 'Dashboard';
  String _email = '';
  String _accountType = '';
  int _gradeLevelIconState = 0;
  int _transfereeIconState = 0;
  int _trackIconState = 0;
  String _selectedStrand = 'ALL';
  String selectedLevel = 'Junior High School'; // Default value
  String? _selectedGrade; // For storing selected grade level
  String selectedJHSGrade = "All";

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
  String? _selectedConfigId;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final DateFormat formatter = DateFormat('MM-dd-yyyy');

  String? _errorText; // For displaying validation errors

  bool validateInput(String value) {
    // Regular expression for year format: YYYY-YYYY
    final regex = RegExp(r'^\d{4}-\d{4}$');
    return regex.hasMatch(value);
  }

  Map<String, String> strandMapping = {
    'STEM': 'Science, Technology, Engineering and Mathematics (STEM)',
    'HUMSS': 'Humanities and Social Sciences (HUMSS)',
    'ABM': 'Accountancy, Business, and Management (ABM)',
    'ICT': 'Information and Communication Technology (ICT)',
    'CO': 'Cookery (CO)',
  };

  String _selectedSubMenu = 'subjects'; // Default value

  String _selectedSubject = "All"; // Add this line
  Map<String, bool> _expandedStudents = {};
  String instructorSubjectName = '';
  String instructorSubjectCode = '';

  //BuildDashboardContent
  Stream<QuerySnapshot> _getEnrolledStudentsCount() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('Status', isEqualTo: 'active')
        .where('educ_level',
            isEqualTo: selectedLevel) // Use the selectedLevel variable
        .where('enrollment_status', isEqualTo: 'approved');
    // Add any additional filters based on the selected level
    if (selectedLevel == 'Senior High School') {
      if (_trackIconState == 1) {
        query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
      } else if (_trackIconState == 2) {
        query = query.where('seniorHigh_Track',
            isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
      }
      if (_selectedStrand != 'ALL') {
        String? strandValue = strandMapping[_selectedStrand];
        if (strandValue != null) {
          query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
        }
      }
      if (_gradeLevelIconState == 1) {
        query = query.where('grade_level', isEqualTo: '11');
      } else if (_gradeLevelIconState == 2) {
        query = query.where('grade_level', isEqualTo: '12');
      }
    } else if (selectedLevel == 'Junior High School') {
      // Add filters specific to Junior High School
      if (_selectedGrade != 'All') {
        query = query.where('grade_level', isEqualTo: _selectedGrade);
      }
    }

    String? transfereeValue;
    if (_transfereeIconState == 1) {
      transfereeValue = 'yes'; // Replace with actual Firestore value
    } else if (_transfereeIconState == 2) {
      transfereeValue = 'no'; // Replace with actual Firestore value
    }
    if (transfereeValue != null) {
      query = query.where('transferee', isEqualTo: transfereeValue);
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
            SnackBar(
                content: Row(
              children: [
                Image.asset('balungaonhs.png', scale: 40),
                SizedBox(width: 10),
                Text('Student with ID $studentId not found'),
              ],
            )),
          );
        }
      }

      // Commit the batch update if there are valid documents to update
      await batch.commit();

      // Optional: Show a confirmation message if some updates were successful
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
        children: [
          Image.asset('balungaonhs.png', scale: 40),
          SizedBox(width: 10),
          Text('Selected students moved to drop list'),
        ],
      )));

      // Clear the selected students list after updating Firestore
      setState(() {
        _selectedStudents.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
        children: [
          Image.asset('balungaonhs.png', scale: 40),
          SizedBox(width: 10),
          Text('No students selected'),
        ],
      )));
    }
  }

  Stream<QuerySnapshot> _getFilteredStudents() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('educ_level', isEqualTo: selectedLevel)
        .where('Status', isEqualTo: 'active'); // Filter for active students

    if (selectedLevel == 'Senior High School') {
      if (_trackIconState == 1) {
        query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
      } else if (_trackIconState == 2) {
        query = query.where('seniorHigh_Track',
            isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
      }
      if (_selectedStrand != 'ALL') {
        String? strandValue = strandMapping[_selectedStrand];
        if (strandValue != null) {
          query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
        }
      }
      if (_gradeLevelIconState == 1) {
        query = query.where('grade_level', isEqualTo: '11');
      } else if (_gradeLevelIconState == 2) {
        query = query.where('grade_level', isEqualTo: '12');
      }
    } else if (selectedLevel == 'Junior High School') {
      // Add filters specific to Junior High School
      if (_selectedGrade != 'All') {
        query = query.where('grade_level', isEqualTo: _selectedGrade);
      }
    }

    String? transfereeValue;
    if (_transfereeIconState == 1) {
      transfereeValue = 'yes'; // Replace with actual Firestore value
    } else if (_transfereeIconState == 2) {
      transfereeValue = 'no'; // Replace with actual Firestore value
    }
    if (transfereeValue != null) {
      query = query.where('transferee', isEqualTo: transfereeValue);
    }

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

  Stream<List<String>> _getSchoolYears(String selectedLevel) {
  // Determine the collection based on selectedLevel
  String collectionName = selectedLevel == 'Junior High School' 
      ? 'jhs configurations' 
      : 'shs configurations';

  return FirebaseFirestore.instance
      .collection(collectionName)
      .snapshots()
      .map((snapshot) {
    // Initialize the list with "All"
    List<String> years = ['All'];

    // Add school years from the fetched documents
    years.addAll(snapshot.docs.map((doc) {
      final data = doc.data();
      if (data.containsKey('school_year')) {
        return data['school_year'] as String;
      } else {
        print('Document missing school_year field: $data');
        return null; // Handle missing field gracefully
      }
    }).where((value) => value != null).cast<String>());

    return years.toSet().toList(); // Remove duplicates and return
  });
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
    return getNewcomersStudents(
      selectedLevel, // Add this as first parameter
      _trackIconState,
      _gradeLevelIconState,
      _transfereeIconState,
      _selectedStrand,
      _selectedGrade ?? 'All', // Add this parameter
    );
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
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Student deleted successfully'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to delete student: $e'),
          ],
        )),
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
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Subject deleted successfully'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Error deleting subject: $e'),
          ],
        )),
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
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Instructor status updated to inactive'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to update status: $e'),
          ],
        )),
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
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Instructor status updated to inactive'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to update status: $e'),
          ],
        )),
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
        .where('educ_level',
            isEqualTo: selectedLevel) // Use the selectedLevel variable
        .where('Status', isEqualTo: 'inactive'); // Filter for active students

    if (selectedLevel == 'Senior High School') {
      if (_trackIconState == 1) {
        query = query.where('seniorHigh_Track', isEqualTo: 'Academic Track');
      } else if (_trackIconState == 2) {
        query = query.where('seniorHigh_Track',
            isEqualTo: 'Technical-Vocational-Livelihood (TVL)');
      }
      if (_selectedStrand != 'ALL') {
        String? strandValue = strandMapping[_selectedStrand];
        if (strandValue != null) {
          query = query.where('seniorHigh_Strand', isEqualTo: strandValue);
        }
      }
      if (_gradeLevelIconState == 1) {
        query = query.where('grade_level', isEqualTo: '11');
      } else if (_gradeLevelIconState == 2) {
        query = query.where('grade_level', isEqualTo: '12');
      }
    } else if (selectedLevel == 'Junior High School') {
      // Add filters specific to Junior High School
      if (_selectedGrade != 'All') {
        query = query.where('grade_level', isEqualTo: _selectedGrade);
      }
    }

    String? transfereeValue;
    if (_transfereeIconState == 1) {
      transfereeValue = 'yes'; // Replace with actual Firestore value
    } else if (_transfereeIconState == 2) {
      transfereeValue = 'no'; // Replace with actual Firestore value
    }
    if (transfereeValue != null) {
      query = query.where('transferee', isEqualTo: transfereeValue);
    }

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
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Section deleted successfully'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Error deleting section: $e'),
          ],
        )),
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

  //JHS Configuration

  Future<void> _showJHSDeleteeConfirmationDialog(
      BuildContext context, String configId) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete JHS Configuration'),
          content:
              Text('Are you sure you want to delete this JHS configuration?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                _JHSdeleteConfiguration(configId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showJHSActivateConfirmationDialog(
      BuildContext context, String configId) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Activate JHS Configuration'),
          content: Column(
            children: [
              Text('Are you sure you want to activate this JHS configuration?'),
              Text(
                'Please note that activating this will require the JHS student to reenroll.',
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Activate',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                _JHSactivateConfiguration(configId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showJHSSaveConfirmationDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Save JHS Configuration'),
          content:
              Text('Are you sure you want to save this JHS configuration?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                _JHSsaveConfiguration();
              },
            ),
          ],
        );
      },
    );
  }

  void _JHSdeleteConfiguration(String configId) async {
    try {
      await FirebaseFirestore.instance
          .collection('jhs configurations')
          .doc(configId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('JHS Configuration deleted successfully'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to delete JHS configuration: $e'),
          ],
        )),
      );
    }
  }

  Future<void> _JHSactivateConfiguration(String configId) async {
    try {
      final selectedConfigSnapshot = await FirebaseFirestore.instance
          .collection('jhs configurations')
          .doc(configId)
          .get();

      if (!selectedConfigSnapshot.exists) {
        throw 'Selected configuration not found.';
      }

      final configurationSemester = selectedConfigSnapshot.get('semester');

      // First, set all configurations to inactive
      final batch = FirebaseFirestore.instance.batch();
      final configs = await FirebaseFirestore.instance
          .collection('jhs configurations')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in configs.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Set the selected configuration as active
      batch.update(
          FirebaseFirestore.instance
              .collection('jhs configurations')
              .doc(configId),
          {'isActive': true});

      await batch.commit();

      // Get all students
      QuerySnapshot studentDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'student')
          .where('educ_level', isEqualTo: 'Junior High School')
          .get();

      // Create a new batch for student updates
      WriteBatch studentBatch = FirebaseFirestore.instance.batch();

      // Update each student's enrollment status and reset their data
      for (var studentDoc in studentDocs.docs) {
        // Update main document status
        studentBatch.update(studentDoc.reference, {
          'enrollment_status': 're-enrolled',
          'quarter': configurationSemester,
          'section':
              FieldValue.delete(), // Remove the section field if it exists
        });

        try {
          // Reset the sections subcollection for each student
          DocumentReference sectionRef =
              studentDoc.reference.collection('sections').doc(studentDoc.id);

          // Check if document exists
          DocumentSnapshot sectionDoc = await sectionRef.get();

          if (sectionDoc.exists) {
            await sectionRef.update({
              'isFinalized': false,
              'selectedSection': FieldValue.delete(),
              'subjects': FieldValue.delete(),
            });
          }
        } catch (e) {
          print('Error resetting sections for student ${studentDoc.id}: $e');
        }
      }

      // Commit student updates
      await studentBatch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text(
                'JHS Configuration activated and student enrollments reset successfully'),
          ],
        )),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to activate jhs configuration: $error'),
          ],
        )),
      );
    }
  }

  // Method to save data to Firebase
  void _JHSsaveConfiguration() {
      print('School Year: $_curriculum');

      if (_curriculum.isEmpty) {
    // Show an error if the curriculum value is empty
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please enter a valid school year.'),
      ),
    );
    return;
  }
    // Create a new document with a timestamp-based ID
    String docId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance
        .collection('jhs configurations')
        .doc(docId) // Using timestamp as document ID
        .set({
      'school_year': _curriculum,
      'semester': _selectedSemester,
      'educ_level': 'Junior High School',
      'timestamp': FieldValue.serverTimestamp(), // Add timestamp for tracking
      'isActive': false, // Flag to identify the current active configuration
    }).then((_) async {
      // Set all other configurations as inactive
      QuerySnapshot prevConfigs = await FirebaseFirestore.instance
          .collection('jhs configurations')
          .where('isActive', isEqualTo: true)
          .where(FieldPath.documentId, isNotEqualTo: docId)
          .get();

      // Create a batch to update all previous configurations
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in prevConfigs.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('JHS Configuration saved successfully!'),
          ],
        )),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to save jhs configuration: $error'),
          ],
        )),
      );
    });
  }

// Function to update enrollment status for all students
  Future<void> _updateEnrollmentStatusForJHSStudents() async {
    try {
      // Query to get all student documents
      QuerySnapshot studentDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'student')
          .where('educ_level', isEqualTo: 'Junior High School')
          .get();

      // Create a batch for the main documents update
      WriteBatch mainBatch = FirebaseFirestore.instance.batch();

      // Update each student's enrollment status
      for (QueryDocumentSnapshot doc in studentDocs.docs) {
        mainBatch.update(doc.reference, {
          'enrollment_status': 're-enrolled',
          'section': FieldValue
              .delete(), // Remove the section field from main document
        });

        try {
          // Get the sections subcollection document for each student
          DocumentReference sectionRef =
              doc.reference.collection('sections').doc(doc.id);

          // Check if the document exists
          DocumentSnapshot sectionDoc = await sectionRef.get();

          if (sectionDoc.exists) {
            // Reset the section document
            await sectionRef.update({
              'isFinalized': false,
              'selectedSection': FieldValue.delete(),
              'subjects': FieldValue.delete(),
            });
          }
        } catch (e) {
          print('Error resetting sections for student ${doc.id}: $e');
        }
      }

      // Commit the main batch update
      await mainBatch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Enrollment status and sections reset for all students.'),
          ],
        )),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to update enrollment status: $error'),
          ],
        )),
      );
    }
  }

  //JHS Configuration

  //SHS Configuration

  Future<void> _showSHSDeleteeConfirmationDialog(
      BuildContext context, String configId) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Delete SHS Configuration'),
          content:
              Text('Are you sure you want to delete this SHS configuration?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                _SHSdeleteConfiguration(configId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSHSActivateConfirmationDialog(
      BuildContext context, String configId) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Activate SHS Configuration'),
          content: Column(
            children: [
              Text('Are you sure you want to activate this SHS configuration?'),
              Text(
                'Please note that activating this will require the student to reenroll.',
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Activate',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                _SHSactivateConfiguration(configId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSHSSaveConfirmationDialog(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Save SHS Configuration'),
          content:
              Text('Are you sure you want to save this SHS configuration?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: Text(
                'Save',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                _SHSsaveConfiguration();
              },
            ),
          ],
        );
      },
    );
  }

  void _SHSdeleteConfiguration(String configId) async {
    try {
      await FirebaseFirestore.instance
          .collection('shs configurations')
          .doc(configId)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('SHS Configuration deleted successfully'),
          ],
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to delete configuration: $e'),
          ],
        )),
      );
    }
  }

  Future<void> _SHSactivateConfiguration(String configId) async {
    try {
      // First, set all configurations to inactive
      final batch = FirebaseFirestore.instance.batch();
      final configs = await FirebaseFirestore.instance
          .collection('shs configurations')
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in configs.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Set the selected configuration as active
      batch.update(
          FirebaseFirestore.instance
              .collection('shs configurations')
              .doc(configId),
          {'isActive': true});

      await batch.commit();

      // Get all students
      QuerySnapshot studentDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'student')
          .where('educ_level', isEqualTo: 'Senior High School')
          .get();

      // Create a new batch for student updates
      WriteBatch studentBatch = FirebaseFirestore.instance.batch();

      // Update each student's enrollment status and reset their data
      for (var studentDoc in studentDocs.docs) {
        // Update main document status
        studentBatch.update(studentDoc.reference, {
          'enrollment_status': 're-enrolled',
          'section':
              FieldValue.delete(), // Remove the section field if it exists
        });

        try {
          // Reset the sections subcollection for each student
          DocumentReference sectionRef =
              studentDoc.reference.collection('sections').doc(studentDoc.id);

          // Check if document exists
          DocumentSnapshot sectionDoc = await sectionRef.get();

          if (sectionDoc.exists) {
            await sectionRef.update({
              'isFinalized': false,
              'selectedSection': FieldValue.delete(),
              'subjects': FieldValue.delete(),
            });
          }
        } catch (e) {
          print('Error resetting sections for student ${studentDoc.id}: $e');
        }
      }

      // Commit student updates
      await studentBatch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text(
                'SHS Configuration activated and student enrollments reset successfully'),
          ],
        )),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to activate configuration: $error'),
          ],
        )),
      );
    }
  }

  // Method to save data to Firebase
  void _SHSsaveConfiguration() {
    // Create a new document with a timestamp-based ID
    String docId = DateTime.now().millisecondsSinceEpoch.toString();

    FirebaseFirestore.instance
        .collection('shs configurations')
        .doc(docId) // Using timestamp as document ID
        .set({
      'school_year': _curriculum,
      'semester': _selectedSemester,
      'timestamp': FieldValue.serverTimestamp(), // Add timestamp for tracking
      'educ_level': 'Senior High School',
      'isActive': false, // Flag to identify the current active configuration
    }).then((_) async {
      // Set all other configurations as inactive
      QuerySnapshot prevConfigs = await FirebaseFirestore.instance
          .collection('shs configurations')
          .where('isActive', isEqualTo: true)
          .where(FieldPath.documentId, isNotEqualTo: docId)
          .get();

      // Create a batch to update all previous configurations
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in prevConfigs.docs) {
        batch.update(doc.reference, {'isActive': false});
      }
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('SHS Configuration saved successfully!'),
          ],
        )),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to save configuration: $error'),
          ],
        )),
      );
    });
  }

// Function to update enrollment status for all students
  Future<void> _updateEnrollmentStatusForSHSStudents() async {
    try {
      // Query to get all student documents
      QuerySnapshot studentDocs = await FirebaseFirestore.instance
          .collection('users')
          .where('accountType', isEqualTo: 'student')
          .where('educ_level', isEqualTo: 'Senior High School')
          .get();

      // Create a batch for the main documents update
      WriteBatch mainBatch = FirebaseFirestore.instance.batch();

      // Update each student's enrollment status
      for (QueryDocumentSnapshot doc in studentDocs.docs) {
        mainBatch.update(doc.reference, {
          'enrollment_status': 're-enrolled',
          'section': FieldValue
              .delete(), // Remove the section field from main document
        });

        try {
          // Get the sections subcollection document for each student
          DocumentReference sectionRef =
              doc.reference.collection('sections').doc(doc.id);

          // Check if the document exists
          DocumentSnapshot sectionDoc = await sectionRef.get();

          if (sectionDoc.exists) {
            // Reset the section document
            await sectionRef.update({
              'isFinalized': false,
              'selectedSection': FieldValue.delete(),
              'subjects': FieldValue.delete(),
            });
          }
        } catch (e) {
          print('Error resetting sections for student ${doc.id}: $e');
        }
      }

      // Commit the main batch update
      await mainBatch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Enrollment status and sections reset for shs students.'),
          ],
        )),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Row(
          children: [
            Image.asset('balungaonhs.png', scale: 40),
            SizedBox(width: 10),
            Text('Failed to update enrollment status: $error'),
          ],
        )),
      );
    }
  }

  //SHS Configuration

  // Re-Enrolled Students
  Stream<QuerySnapshot> _getReEnrolledStudents() {
    return getReEnrolledStudents(
      selectedLevel, // Add this as first parameter
      _trackIconState,
      _gradeLevelIconState,
      _transfereeIconState,
      _selectedStrand,
      _selectedGrade ?? 'All',
    );
  }

  Future<void> _showReEnrolledAcceptConfirmationDialog(
      BuildContext context, String studentId) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Accept Re-Enrolled Student'),
          content:
              Text('Are you sure you want to accept this Re-Enroll student?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
                updateEnrollmentStatus(studentId);
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _showReEnrolledResetDialog(
      BuildContext context, String studentId) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Reset Student Re-Enrolled'),
          content:
              Text('Are you sure you want to reset this Re-Enroll student?'),
          actions: [
            CupertinoDialogAction(
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.pop(context);
                ResetEnrollmentStatus(studentId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> ResetEnrollmentStatus(String studentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(studentId)
          .update({
        'enrollment_status': 're-enrolled',
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
  Stream<List<Map<String, dynamic>>> _getStudentsWithSubjectnonadviser(
      String subjectName, String subjectCode) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', isEqualTo: 'approved')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> matchingStudents = [];

      for (var studentDoc in snapshot.docs) {
        var studentData = studentDoc.data() as Map<String, dynamic>;
        final studentFullName =
            '${studentData['first_name']} ${studentData['last_name']}'.trim();
        final strand = studentData['seniorHigh_Strand'] ?? '';
        final semester = studentData['semester'] ?? '';
        final studentId = studentData['student_id'] ?? '';

        final educLevel = studentData['educ_level'] ?? '';
        final quarter = studentData['quarter'] ?? '';

        print('Checking student: $studentFullName (ID: $studentId)');
        print('Strand: $strand, Semester: $semester');
        print('Looking for Subject: $subjectName, Code: $subjectCode');

        String collectionName = '';
        String docName = '';

        if (educLevel == 'Junior High School') {
          collectionName = '$quarter Quarter';
          docName = 'Junior High School';

          print('Using Quarter: $quarter for Junior High School');
        } else if (educLevel == 'Senior High School') {
          collectionName = semester;
          docName = strand;

          print(
              'Using Semester: $semester and Strand: $strand for Senior High School');
        }

        print(
            'Checking grades for student: $studentFullName in $collectionName/$docName');

        try {
          final gradesDoc = await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(docName)
              .get();

          if (gradesDoc.exists) {
            final gradesData = gradesDoc.data() as Map<String, dynamic>;

            // Print all available student names in the grades document
            print(
                'Available student names in grades: ${gradesData.keys.toList()}');

            // Check if the student's full name exists in the grades document
            if (gradesData.containsKey(studentFullName)) {
              final studentGradesData =
                  gradesData[studentFullName] as Map<String, dynamic>;

              if (studentGradesData.containsKey('grades')) {
                final gradesList = studentGradesData['grades'] as List;

                // Print all grades for debugging
                print('Grades list for $studentFullName:');
                gradesList.forEach((grade) {
                  print(
                      'Subject: ${grade['subject_name']}, Code: ${grade['subject_code']}, Student ID: ${grade['student_id']}');
                });

                final filteredGrades = gradesList.where((gradeData) {
                  // Check for matching subject_name
                  if (gradeData['subject_name'] == subjectName) {
                    if (educLevel == 'Junior High School') {
                      // For Junior High School, only check subject_name
                      return true;
                    } else if (educLevel == 'Senior High School') {
                      // For Senior High School, check both subject_name and subject_code
                      return gradeData['subject_code'] == subjectCode &&
                          gradeData['student_id'] == studentId;
                    }
                  }
                  return false;
                }).toList();

                for (var matchingGrade in filteredGrades) {
                  matchingStudents.add({
                    ...studentData,
                    'student_id': studentId,
                    'first_name': studentData['first_name'] ?? '',
                    'last_name': studentData['last_name'] ?? '',
                    'middle_name': studentData['middle_name'] ?? '',
                    'section': studentData['section'] ?? '',
                    'subject_Name': matchingGrade['subject_name'] ?? '',
                    'subject_Code': matchingGrade['subject_code'] ?? '',
                    'Grade': matchingGrade['grade'] ?? '',
                  });
                }
              }
            } else {
              print('Student $studentFullName not found in grades document');
            }
          } else {
            print('No grades document found for $collectionName/$docName');
          }
        } catch (e) {
          print('Error fetching grades for student $studentFullName: $e');
          continue;
        }
      }

      print('Total matching students found: ${matchingStudents.length}');
      return matchingStudents;
    });
  }

  Future<void> _loadInstructorSubject() async {
    // Get the current user's subject information from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    setState(() {
      instructorSubjectName = userDoc.data()?['subject_Name'] ?? '';
      instructorSubjectCode = userDoc.data()?['subject_Code'] ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> _getFilteredStudentGrade() async {
    try {
      print('Starting _getFilteredStudentGrade');

      // Get current instructor info
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      final userData = userDoc.data()!;
      final instructorFullName =
          '${userData['first_name']} ${userData['last_name']}';
      final userEducLevel =
          userData['educ_level']; // Get the educ_level from current user
      print('Instructor: $instructorFullName, Educ Level: $userEducLevel');

      // Get sections where instructor is adviser
      final sectionsSnapshot = await FirebaseFirestore.instance
          .collection('sections')
          .where('section_adviser', isEqualTo: instructorFullName)
          .get();

      final sectionNames =
          sectionsSnapshot.docs.map((doc) => doc['section_name']).toList();
      final sectionEducLevels = sectionsSnapshot.docs
          .map(
              (doc) => doc['educ_level']) // Get the educ_level for each section
          .toList();

      print(
          'Found sections: $sectionNames, found educ_level: $sectionEducLevels');

      if (sectionNames.isEmpty) {
        print('No sections found');
        return [];
      }

      // Fetch students in those sections
      final studentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('enrollment_status', isEqualTo: 'approved')
          .where('accountType', isEqualTo: 'student')
          .where('section', whereIn: sectionNames)
          .get();

      List<Map<String, dynamic>> studentsWithGrades = [];
      print('Found ${studentsSnapshot.docs.length} students');

      for (final studentDoc in studentsSnapshot.docs) {
        final studentData = studentDoc.data();
        final studentFullName =
            '${studentData['first_name']} ${studentData['last_name']}';
        print('Checking grades for student: $studentFullName');

        final strand = studentData['seniorHigh_Strand'] ?? '';
        final semester =
            studentData['semester']; // Get semester directly from user document

        // Construct collection name based on grade level and semester
        String collectionName = '';
        String docName = ''; // To hold the document name

        if (userEducLevel == 'Junior High School') {
          // For Junior High School, use the quarter field
          final sectionQuarter = sectionsSnapshot.docs.firstWhere((doc) =>
              doc['section_name'] == studentData['section'])['quarter'];
          collectionName =
              '$sectionQuarter Quarter'; // Create the collection name like '1 Quarter', '2 Quarter'
          docName =
              'Junior High School'; // For Junior High, the doc name is 'Junior High School'
          print('Using Quarter: $sectionQuarter');
        } else if (userEducLevel == 'Senior High School') {
          // For Senior High School, use the semester field
          collectionName =
              semester; // Use semester (e.g., '1st Semester', '2nd Semester')
          docName =
              strand; // For Senior High, the doc name is based on the strand (e.g., 'STEM', 'ABM')

          print('Using Semester: $semester and Strand: $strand');
        }

        print(
            'Checking grades for student: $studentFullName in $collectionName/$docName');

        try {
          // Get the document that contains all grades
          final gradesDoc = await FirebaseFirestore.instance
              .collection(collectionName)
              .doc(docName)
              .get();

          if (gradesDoc.exists) {
            final gradesData = gradesDoc.data();
            if (gradesData != null && gradesData[studentFullName] != null) {
              final studentGradeData = gradesData[studentFullName];
              print('Found grade data for $studentFullName: $studentGradeData');

              final List<dynamic> gradesArray =
                  studentGradeData['grades'] ?? [];

              for (var gradeEntry in gradesArray) {
                studentsWithGrades.add({
                  ...studentData,
                  'student_id': studentData['student_id'] ?? '',
                  'first_name': studentData['first_name'] ?? '',
                  'last_name': studentData['last_name'] ?? '',
                  'middle_name': studentData['middle_name'] ?? '',
                  'section': studentData['section'] ?? '',
                  'subject_Name': gradeEntry['subject_name'] ?? '',
                  'subject_Code': gradeEntry['subject_code'] ?? '',
                  'Grade': gradeEntry['grade']?.toString() ?? '',
                });
                print(
                    'Added grade entry: ${gradeEntry['subject_name']} - ${gradeEntry['grade']}');
              }

              print('Added all grades for student: $studentFullName');
            } else {
              print('No grade data found for student $studentFullName');
            }
          } else {
            print('Grades document does not exist');
          }
        } catch (e) {
          print('Error fetching grades for student $studentFullName: $e');
        }
      }

      print('Yielding ${studentsWithGrades.length} students with grades');
      return studentsWithGrades;
    } catch (e) {
      print('Error in _getFilteredStudentGrade: $e');
      return [];
    }
  }

  Future<List<String>> _getUniqueSubjects() async {
    final students = await _getFilteredStudentGrade();
    // Extract all subject names and create a set to get unique values
    Set<String> uniqueSubjects = {};
    for (var student in students) {
      if (student['subject_Name'] != null &&
          student['subject_Name'].toString().isNotEmpty) {
        uniqueSubjects.add(student['subject_Name']);
      }
    }
    // Convert set to sorted list
    List<String> sortedSubjects = uniqueSubjects.toList()..sort();
    return sortedSubjects;
  }

  //Disabling Drawer
  bool _isItemDisabled(String item) {
    if (_accountType == 'INSTRUCTOR') {
      return item != 'Subject Teacher';
    } else if (_accountType == 'ADMIN') {
      return item == 'Subject Teacher';
    }
    return false;
  }

  Widget _buildDrawerItem(String title, IconData icon, String drawerItem) {
    bool isDisabled = _isItemDisabled(drawerItem);

    if (_accountType == 'INSTRUCTOR') {
      if (drawerItem != 'Subject Teacher') {
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

    if (_accountType == 'INSTRUCTOR') {
      setState(() {
        _selectedDrawerItem = 'Subject Teacher'; // Always set for instructors
        _selectedSubMenu = 'subjects'; // Default submenu for instructors
      });
    } else if (_accountType == 'ADMIN') {
      String? savedItem = prefs.getString('adminDrawerItem');
      String? savedSubMenu = prefs.getString('adminSubMenu'); // Load submenu

      setState(() {
        _selectedDrawerItem = savedItem ?? 'Dashboard';
        _selectedSubMenu =
            savedSubMenu ?? 'junior'; // Default submenu if none is saved
      });
    }
  }

  Future<void> _saveSelectedDrawerItem(String item, String submenu) async {
    if (_accountType == 'ADMIN') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('adminDrawerItem', item);
      await prefs.setString('adminSubMenu', submenu); // Save submenu
    }
  }

  void _onDrawerItemTapped(String item) async {
    // Assuming you have a way to determine the submenu here (like 'junior' or 'senior')
    String submenu =
        _selectedSubMenu; // Set the submenu to the currently selected one

    await _saveSelectedDrawerItem(item, submenu); // Pass both item and submenu
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
          context,
          MaterialPageRoute(
              builder: (builder) => Launcher(
                    scrollToFooter: false,
                  )));
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
    _loadInstructorSubject();

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
      case 'Subject Teacher':
        return _buildStrandTeacherContent();
      case 'Manage Newcomers':
        return _buildNewcomersContent();
      case 'Manage Re-Enrolled Students':
        return _buildReEnrolledStudentContent();
      case 'Manage Subjects':
        if (_selectedSubMenu == 'junior') {
          return _buildJuniorManageSubjects();
        } else if (_selectedSubMenu == 'senior') {
          return _buildManageSubjects();
        } else {
          return Center(child: Text('Body Content Here'));
        }
      case 'Manage Teachers':
        if (_selectedSubMenu == 'junior') {
          return _buildJuniorManageTeachers();
        } else if (_selectedSubMenu == 'senior') {
          return _buildManageTeachersContent();
        } else {
          return Center(child: Text('Body Content Here'));
        }
      case 'Manage Student Report Cards':
        return _buildManageStudentReportCardsContent();
      case 'Configuration':
        if (_selectedSubMenu == 'junior') {
          return _buildJuniorConfiguration();
        } else if (_selectedSubMenu == 'senior') {
          return _buildConfigurationContent();
        } else {
          return Center(child: Text('Body Content Here'));
        }
      case 'Manage Sections':
        if (_selectedSubMenu == 'junior') {
          return _buildJuniorManageSections();
        } else if (_selectedSubMenu == 'senior') {
          return _buildManageSections();
        } else {
          return Center(child: Text('Body Content Here'));
        }
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
      return Center(
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 18.0,
            color: Color(0xFF03b97c),
            fontWeight: FontWeight.bold,
          ),
          child: AnimatedTextKit(
            animatedTexts: [
              WavyAnimatedText('LOADING...'),
            ],
            isRepeatingAnimation: true,
          ),
        ),
      );
    }

    if (_currentInstructorDoc == null) {
      return Center(child: Text('No instructor data found'));
    }

    // Add submenu at the top
    return Expanded(
      child: _buildSubMenuContent(),
    );
  }

  Widget _buildSubMenuContent() {
    switch (_selectedSubMenu) {
      case 'subjects':
        final adviserStatus = _currentInstructorDoc!.get('adviser');
        return adviserStatus == 'yes'
            ? _buildInstructorWithAdviserDrawer(_currentInstructorDoc!)
            : _buildInstructorWithoutAdviserDrawer(_currentInstructorDoc!);

      case 'grades':
        final adviserStatus = _currentInstructorDoc!.get('adviser');
        return adviserStatus == 'yes'
            ? _buildGradePrintadviser()
            : _buildGradePrintnonadviser();

      default:
        return Center(child: Text('Select a menu item'));
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
                          color: Color(0xFF03b97c),
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
                          color: Color(0xFF03b97c),
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
                        color: Color(0xFF03b97c),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('Educational Level: '),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedLevel,
                        items: ['Junior High School', 'Senior High School']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLevel = newValue!;
                            // Reset filters when changing educational level
                            _trackIconState = 0;
                            _selectedStrand = 'ALL';
                          });
                        },
                      ),
                    ],
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getEnrolledStudentsCount(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                                Text('Grade Level'),
                                if (selectedLevel == 'Senior High School')
                                  GestureDetector(
                                    onTap: _toggleGradeLevelIcon,
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 1)
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 2)
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  )
                                else if (selectedLevel == 'Junior High School')
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedGrade = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['All', '7', '8', '9', '10']
                                          .map((String grade) {
                                        return PopupMenuItem<String>(
                                          value: grade,
                                          child: Text('Grade $grade'),
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
                          if (selectedLevel == 'Senior High School') ...[
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
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState == 2)
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
                          ],
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
                                      child: Text(data['grade_level'] ?? '')),
                                  Expanded(
                                      child: Text(data['transferee'] ?? '')),
                                  if (selectedLevel ==
                                      'Senior High School') ...[
                                    Expanded(
                                        child: Text(
                                            data['seniorHigh_Track'] ?? '')),
                                    Expanded(
                                        child: Text(
                                            data['seniorHigh_Strand'] ?? '')),
                                  ],
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
                  )
                else
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: StreamBuilder<List<String>>(
                        stream: _getSchoolYears(selectedLevel),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData)
                            return CircularProgressIndicator();

                          return DropdownButton<String>(
                            value: _selectedSchoolYear,
                            items: snapshot.data!.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSchoolYear = newValue!;
                              });
                            },
                          );
                        },
                      )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('Educational Level: '),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedLevel,
                        items: ['Junior High School', 'Senior High School']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLevel = newValue!;
                            // Reset filters when changing educational level
                            _trackIconState = 0;
                            _selectedStrand = 'ALL';
                                      _selectedSchoolYear = 'All';

                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Add Spacer or Expanded to ensure Search stays on the right
                Spacer(),
                if (_selectedSchoolYear != "All")
                  OutlinedButton(
                    onPressed: () async {
                      // Fetch the filtered students once when the button is pressed
                      final snapshot = await _getFilteredStudents().first;
                      final filteredStudents = snapshot.docs.map((student) {
                        final data = student.data() as Map<String, dynamic>;
                        final fullName =
                            '${data['first_name'] ?? ''} ${data['middle_name'] ?? ''} ${data['last_name'] ?? ''}'
                                .trim();
                        return {
                          'student_id': data['student_id'] ?? '',
                          'full_name': fullName,
                          'seniorHigh_Track': data['seniorHigh_Track'] ?? '',
                          'seniorHigh_Strand': data['seniorHigh_Strand'] ?? '',
                          'grade_level': data['grade_level'] ?? '',
                          'transferee': data['transferee'] ?? '',
                        };
                      }).toList();

                      // Call the PDF download function
                      await _downloadPDF(filteredStudents);
                    },
                    child: Text('Download to PDF',
                        style: TextStyle(color: Colors.black)),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                SizedBox(
                  width: 20,
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                          SizedBox(width: 32), // Checkbox column alignment
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Grade Level'),
                                if (selectedLevel == 'Senior High School')
                                  GestureDetector(
                                    onTap: _toggleGradeLevelIcon,
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 1)
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 2)
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  )
                                else if (selectedLevel == 'Junior High School')
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedGrade = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['All', '7', '8', '9', '10']
                                          .map((String grade) {
                                        return PopupMenuItem<String>(
                                          value: grade,
                                          child: Text('Grade $grade'),
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
                          if (selectedLevel == 'Senior High School') ...[
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
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState == 2)
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
                          ],
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
                                  if (selectedLevel == 'Senior High School') {
                                    // Navigate to StudentDetails for Senior High School
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StudentDetails(
                                          studentData: data,
                                          studentDocId: studentDocId,
                                        ),
                                      ),
                                    );
                                  } else if (selectedLevel ==
                                      'Junior High School') {
                                    // Navigate to a different page for Junior High School
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => JHSStudentDetails(
                                          studentData: data,
                                          studentDocId: studentDocId,
                                        ),
                                      ),
                                    );
                                  }
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
                                          child:
                                              Text(data['grade_level'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['transferee'] ?? '')),
                                      if (selectedLevel ==
                                          'Senior High School') ...[
                                        Expanded(
                                            child: Text(
                                                data['seniorHigh_Track'] ??
                                                    '')),
                                        Expanded(
                                            child: Text(
                                                data['seniorHigh_Strand'] ??
                                                    '')),
                                      ],
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

  Future<void> _downloadPDF(List<Map<String, dynamic>> students) async {
    print("Download PDF function called"); // Debugging line

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat:
            PdfPageFormat.a4.landscape, // Set the page orientation to landscape
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Student Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: pw.FlexColumnWidth(1),
                  1: pw.FlexColumnWidth(2.5),
                  2: pw.FlexColumnWidth(2),
                  3: pw.FlexColumnWidth(2),
                  4: pw.FlexColumnWidth(1),
                  5: pw.FlexColumnWidth(1),
                },
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Student ID',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Full Name',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Track',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Strand',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Grade Level',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Transferee',
                            style:
                                pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      ),
                    ],
                  ),
                  // Table Data
                  ...students.map((student) {
                    final isEvenRow = students.indexOf(student) % 2 == 0;
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: isEvenRow ? PdfColors.white : PdfColors.grey100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(student['student_id'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(student['full_name'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(student['seniorHigh_Track'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(student['seniorHigh_Strand'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(student['grade_level'] ?? ''),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(student['transferee'] ?? ''),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 40), // Add space before the principal section
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Urbano Delos Angeles IV',
                      style: pw.TextStyle(
                          fontSize: 14, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Container(
                      width: 150,
                      child: pw.Divider(thickness: 1),
                    ),
                    pw.Text(
                      'SCHOOL PRINCIPAL',
                      style: pw.TextStyle(
                          fontSize: 12, fontStyle: pw.FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save and share the file
    final pdfBytes = await pdf.save();

    await Printing.sharePdf(bytes: pdfBytes, filename: 'students_report.pdf');
  }

  Future<List<Map<String, dynamic>>> _fetchStudentData() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Widget _buildManageStudentReportCardsContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Student Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Row with Drop button (on the left) and Search Student (fixed on the right)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: StreamBuilder<List<String>>(
                      stream: _getSchoolYears(selectedLevel),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();

                        return DropdownButton<String>(
                          value: _selectedSchoolYear,
                          items: snapshot.data!.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedSchoolYear = newValue!;
                            });
                          },
                        );
                      },
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Text('Educational Level: '),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedLevel,
                        items: ['Junior High School', 'Senior High School']
                            .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedLevel = newValue!;
                            // Reset filters when changing educational level
                            _trackIconState = 0;
                            _selectedStrand = 'ALL';
                                      _selectedSchoolYear = 'All';

                          });
                        },
                      ),
                    ],
                  ),
                ),
                // Add Spacer or Expanded to ensure Search stays on the right
                Spacer(),
                SizedBox(
                  width: 20,
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(
                            child: Row(
                              children: [
                                Text('Grade Level'),
                                if (selectedLevel == 'Senior High School')
                                  GestureDetector(
                                    onTap: _toggleGradeLevelIcon,
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 1)
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 2)
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  )
                                else if (selectedLevel == 'Junior High School')
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedGrade = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['All', '7', '8', '9', '10']
                                          .map((String grade) {
                                        return PopupMenuItem<String>(
                                          value: grade,
                                          child: Text('Grade $grade'),
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
                          if (selectedLevel == 'Senior High School') ...[
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
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState == 2)
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
                          ],
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
                                  if (selectedLevel == 'Senior High School') {
                                    // Navigate to StudentDetails for Senior High School
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            StudentReportCards(
                                          studentData: data,
                                          studentDocId: studentDocId,
                                        ),
                                      ),
                                    );
                                  } else if (selectedLevel ==
                                      'Junior High School') {
                                    // Navigate to a different page for Junior High School
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JHSStudentReportCards(
                                          studentData: data,
                                          studentDocId: studentDocId,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Row(
                                    children: [
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
                                          child:
                                              Text(data['grade_level'] ?? '')),
                                      Expanded(
                                          child:
                                              Text(data['transferee'] ?? '')),
                                      if (selectedLevel ==
                                          'Senior High School') ...[
                                        Expanded(
                                            child: Text(
                                                data['seniorHigh_Track'] ??
                                                    '')),
                                        Expanded(
                                            child: Text(
                                                data['seniorHigh_Strand'] ??
                                                    '')),
                                      ]
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
              'Subject Adviser',
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _getFilteredInstructorStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                    final educLevel = data['educ_level']?.toLowerCase() ??
                        ''; // Define educ_level here

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
                            if (students.isNotEmpty &&
                                students.first.data()['educ_level'] ==
                                    'Senior High School') ...[
                              Expanded(child: Text('Track')),
                              Expanded(child: Text('Strand')),
                            ],
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
                              // Get the educ_level value
                              final educLevel = data['educ_level'] ?? '';

                              // Check the educ_level and navigate accordingly
                              if (educLevel == 'Junior High School') {
                                // Navigate to a different page if educ_level is "Junior High School"
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        JHSSubjectandGrade(studentData: data),
                                  ),
                                );
                              } else if (educLevel == 'Senior High School') {
                                // Navigate to SubjectsandGrade page if educ_level is "Senior High School"
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SubjectsandGrade(studentData: data),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                // Checkbox(
                                //     value: false, onChanged: (bool? value) {}),
                                Expanded(child: Text(data['student_id'] ?? '')),
                                Expanded(
                                    child: Text(
                                        '${data['first_name'] ?? ''} ${data['middle_name'] ?? ''} ${data['last_name'] ?? ''}')),
                                if (data['educ_level'] ==
                                    'Senior High School') ...[
                                  Expanded(
                                      child:
                                          Text(data['seniorHigh_Track'] ?? '')),
                                  Expanded(
                                      child: Text(
                                          data['seniorHigh_Strand'] ?? '')),
                                ],
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

  Widget _buildGradePrintadviser() {
    return Container(
        color: Colors.grey[300],
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: FutureBuilder<List<String>>(
                    future: _getUniqueSubjects(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return CircularProgressIndicator();

                      final subjects = ["All", ...snapshot.data!];

                      return DropdownButton<String>(
                        value:
                            _selectedSubject, // You'll need to add this variable to your state
                        items: subjects.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSubject = newValue!;
                          });
                        },
                      );
                    },
                  ),
                ),
                // Add Spacer or Expanded to ensure Search stays on the right
                Spacer(),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      // Create a PDF document
                      final pdf = pw.Document();

                      // stream builder ito ng adviser
                      final snapshotData = await _getFilteredStudentGrade();

                      // Check if snapshotData is empty
                      if (snapshotData.isEmpty) {
                        print('No student data found for PDF generation.');
                        return; // Exit if there's no data
                      }

                      // Log the selected subject
                      print('Selected Subject: $_selectedSubject');

                      // Filter the snapshotData based on the selected subject
                      final filteredData = _selectedSubject == "All"
                          ? snapshotData
                          : snapshotData.where((student) {
                              // Check if the student has grades for the selected subject
                              final hasSubject =
                                  student['subject_Name'] == _selectedSubject;
                              print(
                                  'Checking student: ${student['first_name']} ${student['last_name']} for subject: $_selectedSubject - Result: $hasSubject');
                              return hasSubject;
                            }).toList();

                      // Check if filteredData is empty
                      if (filteredData.isEmpty) {
                        print(
                            'No data found for the selected subject: $_selectedSubject');
                        return; // Exit if there's no data for the selected subject
                      }

                      // Log the filtered data
                      print('Filtered Data: $filteredData');

                      // Add content to the PDF
                      pdf.addPage(
                        pw.MultiPage(
                          pageFormat: PdfPageFormat.a4.landscape,
                          build: (pw.Context context) {
                            // Section Header
                            final section = filteredData.isNotEmpty
                                ? filteredData[0]['section'] ??
                                    'No section available'
                                : 'No section available';

                            return [
                              pw.Text(
                                'Section: $section',
                                style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.normal),
                              ),
                              pw.SizedBox(height: 20),

                              // Grouping subjects by student
                              ...filteredData
                                  .fold<Map<String, List<Map<String, String>>>>(
                                      {}, (acc, student) {
                                    final fullName =
                                        '${student['first_name'] ?? ''} ${student['middle_name'] ?? ''} ${student['last_name'] ?? ''}';
                                    acc[fullName] = (acc[fullName] ?? [])
                                      ..add({
                                        'subject_Code':
                                            student['subject_Code'] ?? '',
                                        'subject_Name':
                                            student['subject_Name'] ?? '',
                                        'Grade': student['Grade'] ?? '',
                                        'educ_level':
                                            student['educ_level'] ?? '',
                                      });
                                    return acc;
                                  })
                                  .entries
                                  .map((entry) {
                                    final fullName = entry.key;
                                    final subjects = entry.value;

                                    return pw.Column(
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.start,
                                      children: [
                                        // Full Name
                                        pw.Text(
                                          fullName,
                                          style: pw.TextStyle(
                                            fontSize: 16,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.SizedBox(height: 10),

                                        // Subjects Table
                                        pw.Table(
                                          border: pw.TableBorder.all(),
                                          columnWidths: {
                                            0: pw.FlexColumnWidth(2),
                                            1: pw.FlexColumnWidth(3),
                                            2: pw.FlexColumnWidth(2),
                                          },
                                          children: [
                                            // Header Row
                                            pw.TableRow(
                                              decoration: pw.BoxDecoration(
                                                  color: PdfColors.grey300),
                                              children: [
                                                // Conditionally show/hide subject_code based on educ_level
                                                if (entry.value
                                                        .first['educ_level'] ==
                                                    'Senior High School')
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        'Subject Code',
                                                        style: pw.TextStyle(
                                                            fontWeight: pw
                                                                .FontWeight
                                                                .bold)),
                                                  ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          8.0),
                                                  child: pw.Text('Subject Name',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                ),
                                                pw.Padding(
                                                  padding:
                                                      const pw.EdgeInsets.all(
                                                          8.0),
                                                  child: pw.Text('Grade',
                                                      style: pw.TextStyle(
                                                          fontWeight: pw
                                                              .FontWeight
                                                              .bold)),
                                                ),
                                              ],
                                            ),
                                            // Data Rows
                                            ...subjects.map((subject) {
                                              return pw.TableRow(
                                                children: [
                                                  // Conditionally show subject_code based on educ_level
                                                  if (entry.value.first[
                                                          'educ_level'] ==
                                                      'Senior High School')
                                                    pw.Padding(
                                                      padding: const pw
                                                          .EdgeInsets.all(8.0),
                                                      child: pw.Text(subject[
                                                              'subject_Code'] ??
                                                          ''),
                                                    ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(subject[
                                                            'subject_Name'] ??
                                                        ''),
                                                  ),
                                                  pw.Padding(
                                                    padding:
                                                        const pw.EdgeInsets.all(
                                                            8.0),
                                                    child: pw.Text(
                                                        subject['Grade'] ?? ''),
                                                  ),
                                                ],
                                              );
                                            }).toList(),
                                          ],
                                        ),
                                        pw.SizedBox(height: 70),
                                        pw.SizedBox(height: 20),
                                      ],
                                    );
                                  })
                                  .toList(),
                            ];
                          },
                        ),
                      );

                      // Save the PDF to bytes
                      final pdfBytes = await pdf.save();

                      // Check if pdfBytes is empty
                      if (pdfBytes.isEmpty) {
                        print('PDF generation failed: no bytes to save.');
                        return; // Exit if no bytes were generated
                      }

                      // Share the PDF
                      await Printing.sharePdf(
                        bytes: pdfBytes,
                        filename: 'students_report_grade.pdf',
                      );

                      print('PDF generated and shared successfully.');
                    } catch (e) {
                      print('Error generating or sharing PDF: $e');
                    }
                  },
                  child: Text('Download to PDF',
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
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
              border: Border.all(color: Color(0xFF03b97c), width: 2.0),
            ),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future:
                  _getFilteredStudentGrade(), // Use Future instead of Stream
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No students found'),
                  );
                }

                final allStudents = snapshot.data!;
                final userEducLevel =
                    snapshot.data![0]['educ_level']; // Access educ_level here

                final searchQuery = _searchController.text.toLowerCase();
                var searchFilteredStudents = allStudents.where((student) {
                  final studentId =
                      student['student_id']?.toString().toLowerCase() ?? '';
                  final firstName =
                      student['first_name']?.toString().toLowerCase() ?? '';
                  final lastName =
                      student['last_name']?.toString().toLowerCase() ?? '';
                  final middleName =
                      student['middle_name']?.toString().toLowerCase() ?? '';
                  final section =
                      student['section']?.toString().toLowerCase() ?? '';
                  final subjectName =
                      student['subject_Name']?.toString().toLowerCase() ?? '';
                  final subjectCode =
                      student['subject_Code']?.toString().toLowerCase() ?? '';

                  final fullName = '$firstName $middleName $lastName';

                  return studentId.contains(searchQuery) ||
                      fullName.contains(searchQuery) ||
                      section.contains(searchQuery) ||
                      subjectName.contains(searchQuery) ||
                      subjectCode.contains(searchQuery);
                }).toList();

                final List<Map<String, dynamic>> filteredStudents;
                if (_selectedSubject == "All") {
                  filteredStudents = searchFilteredStudents;
                } else {
                  filteredStudents = searchFilteredStudents
                      .where((student) =>
                          student['subject_Name'] == _selectedSubject)
                      .toList();
                }

                // Group students by student ID
                Map<String, List<Map<String, dynamic>>> groupedStudents = {};
                for (var student in filteredStudents) {
                  String studentId = student['student_id'];
                  if (!groupedStudents.containsKey(studentId)) {
                    groupedStudents[studentId] = [];
                  }
                  groupedStudents[studentId]!.add(student);
                }

                return Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // SizedBox(width: 32),
                        Expanded(child: Text('Student ID')),
                        Expanded(child: Text('First Name')),
                        Expanded(child: Text('Last Name')),
                        Expanded(child: Text('Middle Name')),
                        Expanded(child: Text('Section')),
                        if (_selectedSubject == "All") ...[
                          if (userEducLevel == 'Senior High School') ...[
                            Expanded(child: Text('Subject Code')),
                          ] else ...[
                            Expanded(
                                child: Text(
                                    'Subjects')), // Use "Subjects" for Junior High
                          ],
                          Expanded(child: Text('Grade')),
                        ] else ...[
                          Expanded(child: Text('Subject Name')),
                          Expanded(child: Text('Subject Code')),
                          Expanded(child: Text('Grade')),
                        ],
                      ],
                    ),
                    Divider(),

                    // Scrollable rows for student data
                    Expanded(
                      child: ListView.builder(
                        itemCount: groupedStudents.length,
                        itemBuilder: (context, index) {
                          String studentId =
                              groupedStudents.keys.elementAt(index);
                          List<Map<String, dynamic>> studentGrades =
                              groupedStudents[studentId]!;
                          var firstRecord = studentGrades.first;

                          return Column(
                            children: [
                              // Main student row
                              // Main student row
                              Row(
                                children: [
                                  SizedBox(width: 8),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          firstRecord['student_id'] ?? '')),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          firstRecord['first_name'] ?? '')),
                                  Expanded(
                                      flex: 2,
                                      child:
                                          Text(firstRecord['last_name'] ?? '')),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                          firstRecord['middle_name'] ?? '')),
                                  Expanded(
                                      flex: 2,
                                      child:
                                          Text(firstRecord['section'] ?? '')),
                                  if (_selectedSubject == "All") ...[
                                    if (userEducLevel ==
                                        'Senior High School') ...[
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              firstRecord['subject_Code'] ??
                                                  '')),
                                    ] else ...[
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              firstRecord['subject_Name'] ??
                                                  '')),
                                    ],
                                    Expanded(
                                        flex: 2,
                                        child:
                                            Text(firstRecord['Grade'] ?? '')),
                                    SizedBox(
                                      width: 48, // Fixed width for icon button
                                      child: IconButton(
                                        icon: Icon(
                                            _expandedStudents[studentId] == true
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down),
                                        onPressed: () {
                                          setState(() {
                                            _expandedStudents[studentId] =
                                                !(_expandedStudents[
                                                        studentId] ??
                                                    false);
                                          });
                                        },
                                      ),
                                    ),
                                  ] else ...[
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            firstRecord['subject_Name'] ?? '')),
                                    Expanded(
                                        flex: 2,
                                        child: Text(
                                            firstRecord['subject_Code'] ?? '')),
                                    Expanded(
                                        flex: 2,
                                        child:
                                            Text(firstRecord['Grade'] ?? '')),
                                  ],
                                ],
                              ),
// Expandable subject rows
                              if (_selectedSubject == "All" &&
                                  (_expandedStudents[studentId] ?? false))
                                ...studentGrades
                                    .skip(1)
                                    .map((grade) => Row(
                                          // skip(1) to skip the first subject
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child:
                                                    SizedBox()), // Student ID
                                            Expanded(
                                                flex: 2,
                                                child:
                                                    SizedBox()), // First Name
                                            Expanded(
                                                flex: 2,
                                                child: SizedBox()), // Last Name
                                            Expanded(
                                                flex: 2,
                                                child:
                                                    SizedBox()), // Middle Name
                                            Expanded(
                                                flex: 2,
                                                child: SizedBox()), // Section
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    grade['subject_Name'] ??
                                                        '')),
                                            Expanded(
                                                flex: 2,
                                                child: Text(
                                                    grade['subject_Code'] ??
                                                        '')),
                                            Expanded(
                                                flex: 2,
                                                child:
                                                    Text(grade['Grade'] ?? '')),
                                            SizedBox(
                                                width:
                                                    48), // Same width as icon button
                                          ],
                                        ))
                                    .toList(),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ))
        ]));
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
                if (doc['educ_level'] == 'Senior High School')
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<List<DocumentSnapshot>>(
                // Use a custom stream that fetches students with matching subjects
                stream: _getStudentsWithSubject(subjectName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                            if (doc['educ_level'] == 'Senior High School')
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
                                    if (doc['educ_level'] ==
                                        'Senior High School')
                                      Expanded(
                                          child: Text(studentData[
                                                  'seniorHigh_Strand'] ??
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

  Map<String, bool> _selectedSubjectStudents =
      {}; // Store selected students' states

  Widget _buildGradePrintnonadviser() {
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    final snapshotData =
                        await _getStudentsWithSubjectnonadviser(
                                instructorSubjectName, instructorSubjectCode)
                            .first;

                    if (snapshotData != null && snapshotData.isNotEmpty) {
                      // Check if there are selected students
                      final selectedStudents = _selectedSubjectStudents.entries
                          .where(
                              (entry) => entry.value) // Only include selected
                          .map((entry) => entry.key)
                          .toSet();

                      // If no students are selected, use all students
                      final studentsToInclude = selectedStudents.isEmpty
                          ? snapshotData
                          : snapshotData
                              .where((student) => selectedStudents
                                  .contains(student['student_id']))
                              .toList();

                      if (studentsToInclude.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'No students found to generate the PDF')),
                        );
                        return;
                      }

                      final isSeniorHighSchool = studentsToInclude.any(
                          (student) =>
                              student['educ_level'] == 'Senior High School');

                      // Create a PDF document
                      final pdf = pw.Document();

                      pdf.addPage(
                        pw.Page(
                          pageFormat: PdfPageFormat.a4.landscape,
                          build: (pw.Context context) {
                            return pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Student Grades \n$instructorSubjectName',
                                  style: pw.TextStyle(
                                      fontSize: 24,
                                      fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 20),
                                pw.Table(
                                  border: pw.TableBorder.all(),
                                  columnWidths: {
                                    0: pw.FlexColumnWidth(2),
                                    1: pw.FlexColumnWidth(2),
                                    2: pw.FlexColumnWidth(2),
                                    3: pw.FlexColumnWidth(2),
                                    4: pw.FlexColumnWidth(2),
                                    5: pw.FlexColumnWidth(3),
                                    if (isSeniorHighSchool)
                                      6: pw.FlexColumnWidth(2),
                                    7: pw.FlexColumnWidth(1),
                                  },
                                  children: [
                                    pw.TableRow(
                                      decoration: pw.BoxDecoration(
                                          color: PdfColors.grey300),
                                      children: [
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('Student ID',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('First Name',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('Last Name',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('Middle Name',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('Section',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('Subject Name',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                        if (isSeniorHighSchool)
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text('Subject Code',
                                                style: pw.TextStyle(
                                                    fontWeight:
                                                        pw.FontWeight.bold)),
                                          ),
                                        pw.Padding(
                                          padding: const pw.EdgeInsets.all(4),
                                          child: pw.Text('Grade',
                                              style: pw.TextStyle(
                                                  fontWeight:
                                                      pw.FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    ...studentsToInclude.map((student) {
                                      return pw.TableRow(
                                        children: [
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text(
                                                student['student_id'] ?? ''),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text(
                                                student['first_name'] ?? ''),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text(
                                                student['last_name'] ?? ''),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text(
                                                student['middle_name'] ?? ''),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text(
                                                student['section'] ?? ''),
                                          ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child: pw.Text(
                                                student['subject_Name'] ?? ''),
                                          ),
                                          if (isSeniorHighSchool)
                                            pw.Padding(
                                              padding:
                                                  const pw.EdgeInsets.all(4),
                                              child: pw.Text(
                                                  student['subject_Code'] ??
                                                      ''),
                                            ),
                                          pw.Padding(
                                            padding: const pw.EdgeInsets.all(4),
                                            child:
                                                pw.Text(student['Grade'] ?? ''),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      );

                      final pdfBytes = await pdf.save();
                      await Printing.sharePdf(
                          bytes: pdfBytes,
                          filename: 'students_report_grade.pdf');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('PDF downloaded')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('No students found to generate the PDF')),
                      );
                    }
                  },
                  child: Text('Download to PDF',
                      style: TextStyle(color: Colors.black)),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _getStudentsWithSubjectnonadviser(
                  instructorSubjectName,
                  instructorSubjectCode,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No students found'));
                  }

                  final allStudents = snapshot.data!;
                  final searchQuery = _searchController.text.toLowerCase();

                  var searchFilteredStudents = allStudents.where((student) {
                    final studentId =
                        student['student_id']?.toString().toLowerCase() ?? '';
                    final firstName =
                        student['first_name']?.toString().toLowerCase() ?? '';
                    final lastName =
                        student['last_name']?.toString().toLowerCase() ?? '';
                    final middleName =
                        student['middle_name']?.toString().toLowerCase() ?? '';
                    final section =
                        student['section']?.toString().toLowerCase() ?? '';
                    final subjectName =
                        student['subject_Name']?.toString().toLowerCase() ?? '';
                    final subjectCode =
                        student['subject_Code']?.toString().toLowerCase() ?? '';

                    final fullName = '$firstName $middleName $lastName';

                    return studentId.contains(searchQuery) ||
                        fullName.contains(searchQuery) ||
                        section.contains(searchQuery) ||
                        subjectName.contains(searchQuery) ||
                        subjectCode.contains(searchQuery);
                  }).toList();

                  final isSeniorHighSchool = searchFilteredStudents.any(
                      (student) =>
                          student['educ_level'] == 'Senior High School');

                  return Column(
                    children: [
                      _buildHeaderRow(isSeniorHighSchool),
                      Expanded(
                        child: ListView.builder(
                          itemCount: searchFilteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = searchFilteredStudents[index];
                            return _buildStudentRow(
                                student, isSeniorHighSchool);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderRow(bool isSeniorHighSchool) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 32),
            Expanded(child: Text('Student ID')),
            Expanded(child: Text('First Name')),
            Expanded(child: Text('Last Name')),
            Expanded(child: Text('Middle Name')),
            Expanded(child: Text('Section')),
            Expanded(child: Text('Subject Name')),
            if (isSeniorHighSchool)
              Expanded(child: Text('Subject Code')), // Only for SHS
            Expanded(child: Text('Grade')),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _buildStudentRow(
      Map<String, dynamic> student, bool isSeniorHighSchool) {
    return Row(
      children: [
        SizedBox(width: 8),
        StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            return Stack(
              alignment: Alignment.center,
              children: [
                Checkbox(
                  value:
                      _selectedSubjectStudents[student['student_id']] ?? false,
                  onChanged: (bool? value) async {
                    setState(() => isLoading = true);
                    try {
                      await Future.delayed(
                          Duration(milliseconds: 500)); // Simulate processing
                      setState(() {
                        _selectedSubjectStudents[student['student_id']] =
                            value!;
                      });
                    } finally {
                      setState(() => isLoading = false);
                    }
                  },
                ),
                if (isLoading)
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
              ],
            );
          },
        ),
        Expanded(child: Text(student['student_id'] ?? '')),
        Expanded(child: Text(student['first_name'] ?? '')),
        Expanded(child: Text(student['last_name'] ?? '')),
        Expanded(child: Text(student['middle_name'] ?? '')),
        Expanded(child: Text(student['section'] ?? '')),
        Expanded(child: Text(student['subject_Name'] ?? '')),
        if (isSeniorHighSchool)
          Expanded(child: Text(student['subject_Code'] ?? '')), // Only for SHS
        Expanded(child: Text(student['Grade'] ?? '')),
      ],
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Educational Level: '),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedLevel,
                  items: ['Junior High School', 'Senior High School']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLevel = newValue!;
                      // Reset filters when changing educational level
                      _trackIconState = 0;
                      _selectedStrand = 'ALL';
                    });
                  },
                ),
              ],
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: getNewcomersStudents(
                  selectedLevel,
                  _trackIconState,
                  _gradeLevelIconState,
                  _transfereeIconState,
                  _selectedStrand,
                  _selectedGrade ?? 'All', // Add this parameter
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                          if (selectedLevel == 'Senior High School') ...[
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
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState == 2)
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
                          ],
                          Expanded(
                            child: Row(
                              children: [
                                Text('Grade Level'),
                                if (selectedLevel == 'Senior High School')
                                  GestureDetector(
                                    onTap: _toggleGradeLevelIcon,
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 1)
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 2)
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  )
                                else if (selectedLevel == 'Junior High School')
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedGrade = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['All', '7', '8', '9', '10']
                                          .map((String grade) {
                                        return PopupMenuItem<String>(
                                          value: grade,
                                          child: Text('Grade $grade'),
                                        );
                                      }).toList();
                                    },
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

  Widget _buildJuniorManageSubjects() {
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
                  'Manage Junior HS Subjects',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF002f24)),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Filter by Grade Level:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 16),
                    DropdownButton<String>(
                      value: selectedJHSGrade,
                      items: ["All", "7", "8", "9", "10"]
                          .map((grade) => DropdownMenuItem<String>(
                                value: grade,
                                child: Text(
                                    grade == "All" ? "All" : "Grade $grade"),
                              ))
                          .toList(),
                      onChanged: (grade) {
                        setState(() {
                          selectedJHSGrade = grade!;
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
                            4: FixedColumnWidth(100.0),
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
                                  child: Text('Subject Name',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Grade Level',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Quarter',
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
                                .where('educ_level',
                                    isEqualTo:
                                        'Junior High School') // Add this filter
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF03b97c),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        WavyAnimatedText('LOADING...'),
                                      ],
                                      isRepeatingAnimation: true,
                                    ),
                                  ),
                                );
                              }
                              final subjects = snapshot.data!.docs;

                              // Apply grade level filtering
                              final filteredSubjects = selectedJHSGrade == "All"
                                  ? subjects
                                  : subjects
                                      .where((subject) =>
                                          subject['grade_level'] ==
                                          selectedJHSGrade)
                                      .toList();

                              return SingleChildScrollView(
                                child: Table(
                                  border: TableBorder.all(color: Colors.grey),
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FixedColumnWidth(50.0),
                                    1: FlexColumnWidth(),
                                    2: FlexColumnWidth(),
                                    3: FlexColumnWidth(),
                                    4: FixedColumnWidth(100.0),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(filteredSubjects[i]['subject_name']),
                  if (filteredSubjects[i]['subject_name'] == 'MAPEH' &&
                      filteredSubjects[i]['sub_subjects'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text('  ' + 'Subfields:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('     ' + '${filteredSubjects[i]['sub_subjects']['Music'] ?? 'N/A'}'),
                        Text('     ' + '${filteredSubjects[i]['sub_subjects']['Arts'] ?? 'N/A'}'),
                        Text('     ' + '${filteredSubjects[i]['sub_subjects']['Physical Education'] ?? 'N/A'}'),
                        Text('     ' + '${filteredSubjects[i]['sub_subjects']['Health'] ?? 'N/A'}'),
                      ],
                    ),
                ],
              ),
            ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                'Grade ${filteredSubjects[i]['grade_level']}'),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '${filteredSubjects[i]['quarter']} Quarter'),
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
                                    subjectId: selectedSubjectId,
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
                  'Manage Senior HS Subjects',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF002f24)),
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
                                .where('educ_level',
                                    isEqualTo:
                                        'Senior High School') // Add this filter
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
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
                                );
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

  Widget _buildJuniorManageTeachers() {
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
                  'Manage JHS Teachers',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF002f24)),
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
                                  child: Text('Teacher Educational Level',
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
                                .where('educ_level',
                                    isEqualTo: 'Junior High School')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF03b97c),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        WavyAnimatedText('LOADING...'),
                                      ],
                                      isRepeatingAnimation: true,
                                    ),
                                  ),
                                );
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
                                            child: Text(users[i]['educ_level']),
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
                  'Manage SHS Teachers',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF002f24)),
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
                            7: FlexColumnWidth(),
                            8: FixedColumnWidth(160.0),
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
                                  child: Text('Teacher Educational Level',
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
                                .where('educ_level',
                                    isEqualTo: 'Senior High School')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF03b97c),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        WavyAnimatedText('LOADING...'),
                                      ],
                                      isRepeatingAnimation: true,
                                    ),
                                  ),
                                );
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
                                    7: FlexColumnWidth(),
                                    8: FixedColumnWidth(160.0),
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
                                            child: Text(users[i]['educ_level']),
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

  Widget _buildJuniorConfiguration() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('JHS Configuration Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // Left Card
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('jhs configurations')
                                .where('isActive', isEqualTo: true)
                                .where('educ_level',
                                    isEqualTo: 'Junior High School')
                                .snapshots(),
                            builder: (context, snapshot) {
                              String activeSemester = 'None';
                              String activeSchoolYear = 'None';
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                final activeConfig = snapshot.data!.docs.first
                                    .data() as Map<String, dynamic>;
                                activeSemester =
                                    activeConfig['semester'] ?? 'None';
                                activeSchoolYear =
                                    activeConfig['school_year'] ?? 'None';
                              }

                              return Card(
                                color: Color(0xFF03b97c),
                                elevation: 4,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Current Active Quarter',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16),
                                      Text(activeSchoolYear,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      SizedBox(height: 8),
                                      Text(activeSemester,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Configuration History',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedConfigId != null) {
                                    _showJHSActivateConfirmationDialog(
                                        context, _selectedConfigId!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Row(
                                        children: [
                                          Image.asset('balungaonhs.png', scale: 40),
                                          SizedBox(width: 10),
                                          Text(
                                              'Please select a jhs configuration to activate'),
                                        ],
                                      )),
                                    );
                                  }
                                },
                                child: Text('Set as Active'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF002f24),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('jhs configurations')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Center(
                                      child: Text('No configuration history'));
                                }

                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data!.docs[index];
                                    final config =
                                        doc.data() as Map<String, dynamic>;
                                    final timestamp =
                                        config['timestamp'] != null
                                            ? (config['timestamp'] as Timestamp)
                                                .toDate()
                                            : DateTime
                                                .now(); // Handle null timestamp

                                    return Card(
                                      color: Colors.grey.shade200,
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: Radio<String>(
                                          value: doc.id,
                                          groupValue: _selectedConfigId,
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedConfigId = value;
                                            });
                                          },
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(config['school_year']),
                                            Text(config['semester'] +
                                                ' ' +
                                                'Quarter')
                                          ],
                                        ),
                                        subtitle: Text(
                                            'Set on: ${DateFormat('MMM dd, yyyy HH:mm').format(timestamp)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (config['isActive'] == true)
                                              Chip(
                                                label: Text('Active',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                backgroundColor: Colors.green,
                                              ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _showJHSDeleteeConfirmationDialog(
                                                      context, doc.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Space between the cards
                // Right Card
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Stack(children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                            'New School Year & Quarter',
                            style: TextStyle(fontSize: 20, fontFamily: 'SB'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 300,
                                height: 50,
                                child: CupertinoTextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(
                                        r'[0-9\-]')), // Allow digits and dashes
                                  ],
                                  placeholder:
                                      'Enter School Year (e.g 2025-2026)',
                                  onChanged: (value) {
                                    setState(() {
                                      _curriculum = value;
                                      // Update error text based on validation
                                      _errorText = validateInput(value)
                                          ? null
                                          : 'Invalid format. Use YYYY-YYYY';
                                    });
                                  },
                                ),
                              ),
                              if (_errorText !=
                                  null) // Show error text inline if there's a validation error
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorText!,
                                    style: TextStyle(
                                      color: CupertinoColors.destructiveRed,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 16),
                              // Semester Selection Radio Buttons
                              Material(
                                elevation: 5.0, // Adds elevation (shadow)
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      5), // Matches the Container's borderRadius
                                ),
                                color: Colors
                                    .transparent, // Makes the Material widget transparent
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5), // Rounded corners
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text('1st Quarter'),
                                    leading: Radio<String>(
                                      value: '1st',
                                      groupValue: _selectedSemester,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedSemester = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Material(
                                elevation: 5.0, // Adds elevation (shadow)
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      5), // Matches the Container's borderRadius
                                ),
                                color: Colors
                                    .transparent, // Makes the Material widget transparent
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5), // Rounded corners
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text('2nd Quarter'),
                                    leading: Radio<String>(
                                      value: '2nd',
                                      groupValue: _selectedSemester,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedSemester = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Material(
                                elevation: 5.0, // Adds elevation (shadow)
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      5), // Matches the Container's borderRadius
                                ),
                                color: Colors
                                    .transparent, // Makes the Material widget transparent
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5), // Rounded corners
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text('3rd Quarter'),
                                    leading: Radio<String>(
                                      value: '3rd',
                                      groupValue: _selectedSemester,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedSemester = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Material(
                                elevation: 5.0, // Adds elevation (shadow)
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      5), // Matches the Container's borderRadius
                                ),
                                color: Colors
                                    .transparent, // Makes the Material widget transparent
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5), // Rounded corners
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text('4th Quarter'),
                                    leading: Radio<String>(
                                      value: '4th',
                                      groupValue: _selectedSemester,
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedSemester = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              // Save Button
                              SizedBox(height: 16),
                              Container(
                                width: 300,
                                height: 50,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll<Color>(
                                            Color(0xFF002f24)),
                                    elevation:
                                        MaterialStateProperty.all<double>(5),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _errorText = validateInput(_curriculum)
                                          ? null
                                          : 'Invalid format. Use YYYY-YYYY';
                                    });
                                    if (_errorText == null) {
                                      // Only call _saveConfiguration if the input is valid
                                      _showJHSSaveConfirmationDialog(context);
                                    }
                                  },
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationContent() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SHS Configuration Management',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 24),
          Expanded(
            child: Row(
              children: [
                // Left Card
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('shs configurations')
                                .where('isActive', isEqualTo: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              String activeSemester = 'None';
                              String activeSchoolYear = 'None';
                              if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                final activeConfig = snapshot.data!.docs.first
                                    .data() as Map<String, dynamic>;
                                activeSemester =
                                    activeConfig['semester'] ?? 'None';
                                activeSchoolYear =
                                    activeConfig['school_year'] ?? 'None';
                              }

                              return Card(
                                color: Color(0xFF03b97c),
                                elevation: 4,
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Current Active Semester',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 16),
                                      Text(activeSchoolYear,
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.white)),
                                      SizedBox(height: 8),
                                      Text(activeSemester,
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Configuration History',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                onPressed: () {
                                  if (_selectedConfigId != null) {
                                    _showSHSActivateConfirmationDialog(
                                        context, _selectedConfigId!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Row(
                                        children: [
                                          Image.asset('balungaonhs.png', scale: 40),
                                          SizedBox(width: 10),
                                          Text(
                                              'Please select a shs configuration to activate'),
                                        ],
                                      )),
                                    );
                                  }
                                },
                                child: Text('Set as Active'),
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Color(0xFF002f24),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('shs configurations')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Center(
                                      child:
                                          Text('No shs configuration history'));
                                }

                                return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    final doc = snapshot.data!.docs[index];
                                    final config =
                                        doc.data() as Map<String, dynamic>;
                                    final timestamp =
                                        config['timestamp'] != null
                                            ? (config['timestamp'] as Timestamp)
                                                .toDate()
                                            : DateTime
                                                .now(); // Handle null timestamp

                                    return Card(
                                      color: Colors.grey.shade200,
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: Radio<String>(
                                          value: doc.id,
                                          groupValue: _selectedConfigId,
                                          onChanged: (String? value) {
                                            setState(() {
                                              _selectedConfigId = value;
                                            });
                                          },
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(config['school_year']),
                                            Text(config['semester'])
                                          ],
                                        ),
                                        subtitle: Text(
                                            'Set on: ${DateFormat('MMM dd, yyyy HH:mm').format(timestamp)}'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (config['isActive'] == true)
                                              Chip(
                                                label: Text('Active',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                backgroundColor: Colors.green,
                                              ),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red),
                                              onPressed: () =>
                                                  _showSHSDeleteeConfirmationDialog(
                                                      context, doc.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16), // Space between the cards
                // Right Card
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Stack(children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          child: Text(
                            'New School Year',
                            style: TextStyle(fontSize: 20, fontFamily: 'SB'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 300,
                                height: 50,
                                child: CupertinoTextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(
                                        r'[0-9\-]')), // Allow digits and dashes
                                  ],
                                  placeholder:
                                      'Enter School Year (e.g 2024-2025)',
                                  onChanged: (value) {
                                    setState(() {
                                      _curriculum = value;
                                      // Update error text based on validation
                                      _errorText = validateInput(value)
                                          ? null
                                          : 'Invalid format. Use YYYY-YYYY';
                                    });
                                  },
                                ),
                              ),
                              if (_errorText !=
                                  null) // Show error text inline if there's a validation error
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _errorText!,
                                    style: TextStyle(
                                      color: CupertinoColors.destructiveRed,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              SizedBox(height: 16),
                              // Semester Selection Radio Buttons
                              Material(
                                elevation: 5.0, // Adds elevation (shadow)
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      5), // Matches the Container's borderRadius
                                ),
                                color: Colors
                                    .transparent, // Makes the Material widget transparent
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5), // Rounded corners
                                    ),
                                  ),
                                  child: ListTile(
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
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Material(
                                elevation: 5.0, // Adds elevation (shadow)
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                      5), // Matches the Container's borderRadius
                                ),
                                color: Colors
                                    .transparent, // Makes the Material widget transparent
                                child: Container(
                                  width: 300,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(5), // Rounded corners
                                    ),
                                  ),
                                  child: ListTile(
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
                                ),
                              ),
                              // Save Button
                              SizedBox(height: 16),
                              Container(
                                width: 300,
                                height: 50,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStatePropertyAll<Color>(
                                            Color(0xFF002f24)),
                                    elevation:
                                        MaterialStateProperty.all<double>(5),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _errorText = validateInput(_curriculum)
                                          ? null
                                          : 'Invalid format. Use YYYY-YYYY';
                                    });
                                    if (_errorText == null) {
                                      // Only call _saveConfiguration if the input is valid
                                      _showSHSSaveConfirmationDialog(context);
                                    }
                                  },
                                  child: Text(
                                    'Save',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Educational Level: '),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedLevel,
                  items: ['Junior High School', 'Senior High School']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLevel = newValue!;
                      // Reset filters when changing educational level
                      _trackIconState = 0;
                      _selectedStrand = 'ALL';
                    });
                  },
                ),
              ],
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getReEnrolledStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                          if (selectedLevel == 'Senior High School') ...[
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
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState == 2)
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
                          ],
                          Expanded(
                            child: Row(
                              children: [
                                Text('Grade Level'),
                                if (selectedLevel == 'Senior High School')
                                  GestureDetector(
                                    onTap: _toggleGradeLevelIcon,
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 1)
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 2)
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  )
                                else if (selectedLevel == 'Junior High School')
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedGrade = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['All', '7', '8', '9', '10']
                                          .map((String grade) {
                                        return PopupMenuItem<String>(
                                          value: grade,
                                          child: Text('Grade $grade'),
                                        );
                                      }).toList();
                                    },
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
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ReEnrolledValidator(
                                                    studentData: data)));
                                  },
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
                                                _showReEnrolledAcceptConfirmationDialog(
                                                   context, student.id);
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                  Iconsax.close_circle_copy,
                                                  color: Colors.red),
                                              onPressed: () {
                                                _showReEnrolledResetDialog(
                                                   context, student.id);
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

  Widget _buildJuniorManageSections() {
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
                  'Manage JHS Sections',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF002f24)),
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
                                  child: Text('Quarter',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Section Educational Level',
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
                                .where('educ_level',
                                    isEqualTo:
                                        'Junior High School') // Add this filter
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF002f24),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        WavyAnimatedText('LOADING...'),
                                      ],
                                      isRepeatingAnimation: true,
                                    ),
                                  ),
                                );
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
                                    6: FlexColumnWidth(),
                                    7: FixedColumnWidth(160.0),
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
                                            child: Text(sections[i]['quarter']),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child:
                                                Text(sections[i]['educ_level']),
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
                                                            JHSStudentInSection(
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
                  'Manage SHS Sections',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color(0xFF002f24)),
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
                                  child: Text('Section Educational Level',
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
                                .where('educ_level',
                                    isEqualTo:
                                        'Senior High School') // Add this filter
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: DefaultTextStyle(
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      color: Color(0xFF03b97c),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    child: AnimatedTextKit(
                                      animatedTexts: [
                                        WavyAnimatedText('LOADING...'),
                                      ],
                                      isRepeatingAnimation: true,
                                    ),
                                  ),
                                );
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
                                    6: FlexColumnWidth(),
                                    7: FixedColumnWidth(160.0),
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
                                            child:
                                                Text(sections[i]['educ_level']),
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
                                                            SHSStudentInSection(
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text('Educational Level: '),
                SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedLevel,
                  items: ['Junior High School', 'Senior High School']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLevel = newValue!;
                      // Reset filters when changing educational level
                      _trackIconState = 0;
                      _selectedStrand = 'ALL';
                    });
                  },
                ),
              ],
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
                border: Border.all(color: Color(0xFF03b97c), width: 2.0),
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: _getFilteredDropStudents(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 18.0,
                          color: Color(0xFF03b97c),
                          fontWeight: FontWeight.bold,
                        ),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            WavyAnimatedText('LOADING...'),
                          ],
                          isRepeatingAnimation: true,
                        ),
                      ),
                    );
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
                          if (selectedLevel == 'Senior High School') ...[
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
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_trackIconState == 0 ||
                                            _trackIconState == 2)
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
                          ],
                          Expanded(
                            child: Row(
                              children: [
                                Text('Grade Level'),
                                if (selectedLevel == 'Senior High School')
                                  GestureDetector(
                                    onTap: _toggleGradeLevelIcon,
                                    child: Row(
                                      children: [
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 1)
                                          Icon(Iconsax.arrow_up_3_copy,
                                              size: 16),
                                        if (_gradeLevelIconState == 0 ||
                                            _gradeLevelIconState == 2)
                                          Icon(Iconsax.arrow_down_copy,
                                              size: 16),
                                      ],
                                    ),
                                  )
                                else if (selectedLevel == 'Junior High School')
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.arrow_drop_down),
                                    onSelected: (String value) {
                                      setState(() {
                                        _selectedGrade = value;
                                      });
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return ['All', '7', '8', '9', '10']
                                          .map((String grade) {
                                        return PopupMenuItem<String>(
                                          value: grade,
                                          child: Text('Grade $grade'),
                                        );
                                      }).toList();
                                    },
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
                      color: Color(0xFF03b97c)), // Use Iconsax.menu
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
                    'assets/balungaonhs.png', // Replace with your asset image path
                    height: 130,
                  ),
                ],
              ),
            ),
            if (_accountType == 'ADMIN') ...[
              _buildDrawerItem('Dashboard', Iconsax.dash_dash, 'Dashboard'),
              _buildDrawerItem('Students', Iconsax.user, 'Students'),
              _buildDrawerItem('Manage Student Report Cards', Iconsax.task,
                  'Manage Student Report Cards'),
              _buildDrawerItem(
                  'Manage Newcomers', Iconsax.task, 'Manage Newcomers'),
              _buildDrawerItem('Manage Re-Enrolled Students ', Iconsax.task,
                  'Manage Re-Enrolled Students'),
              ExpansionTile(
                leading: Icon(Iconsax.activity, color: Colors.black),
                title: Text('Manage Subjects',
                    style: TextStyle(color: Colors.black)),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('Junior High School'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Manage Subjects';
                        _selectedSubMenu = 'junior';
                      });
                      _saveSelectedDrawerItem('Manage Subjects',
                          'junior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('Senior High School'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Manage Subjects';
                        _selectedSubMenu = 'senior';
                      });
                      _saveSelectedDrawerItem('Manage Subjects',
                          'senior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: Icon(Iconsax.activity, color: Colors.black),
                title: Text('Manage Teachers',
                    style: TextStyle(color: Colors.black)),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('JHS Teachers'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Manage Teachers';
                        _selectedSubMenu = 'junior';
                      });
                      _saveSelectedDrawerItem('Manage Teachers',
                          'junior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('SHS Teacher'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Manage Teachers';
                        _selectedSubMenu = 'senior';
                      });
                      _saveSelectedDrawerItem('Manage Teachers',
                          'senior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ],
              ),
              ExpansionTile(
                leading: Icon(Iconsax.activity, color: Colors.black),
                title: Text('Manage Sections',
                    style: TextStyle(color: Colors.black)),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('JHS Sections'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Manage Sections';
                        _selectedSubMenu = 'junior';
                      });
                      _saveSelectedDrawerItem('Manage Sections',
                          'junior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('SHS Sections'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Manage Sections';
                        _selectedSubMenu = 'senior';
                      });
                      _saveSelectedDrawerItem('Manage Sections',
                          'senior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ],
              ),
              _buildDrawerItem(
                  'Dropped Student', Iconsax.dropbox_copy, 'Dropped Student'),
              ExpansionTile(
                leading: Icon(Iconsax.activity, color: Colors.black),
                title: Text('Configuration',
                    style: TextStyle(color: Colors.black)),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('JHS Configuration'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Configuration';
                        _selectedSubMenu = 'junior';
                      });
                      _saveSelectedDrawerItem('Configuration',
                          'junior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('SHS Configuration'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Configuration';
                        _selectedSubMenu = 'senior';
                      });
                      _saveSelectedDrawerItem('Configuration',
                          'senior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                ],
              ),
              _buildDrawerItem('Banner', Iconsax.image_copy, 'Banner'),
              _buildDrawerItem('News and Updates', Iconsax.activity_copy,
                  'News and Updates'),
              _buildDrawerItem('FAQS', Iconsax.message_2_copy, 'FAQS'),
              _buildDrawerItem('Reports', Iconsax.data_copy, 'Reports'),
            ], // In your drawer ListView, replace the Subject Teacher drawer item with this:

            if (_accountType == 'INSTRUCTOR') ...[
              ExpansionTile(
                leading: Icon(Iconsax.teacher, color: Colors.black),
                title: Text('Subject Teacher',
                    style: TextStyle(color: Colors.black)),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('Grading Students'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Subject Teacher';
                        _selectedSubMenu = 'subjects';
                      });
                      _saveSelectedDrawerItem('Subject Teacher',
                          'junior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.only(left: 72.0),
                    title: Text('Print Grades'),
                    onTap: () {
                      setState(() {
                        _selectedDrawerItem = 'Subject Teacher';
                        _selectedSubMenu = 'grades';
                      });
                      _saveSelectedDrawerItem('Subject Teacher',
                          'senior'); // Save both item and submenu

                      Navigator.pop(context); // Close drawer
                    },
                  ),
                  // Add more submenu items as needed
                ],
              ),
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
                            backgroundColor:
                                Color(0xFF002f24), // Blue background
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
                            side: BorderSide(
                                color: Color(0xFF002f24)), // Blue border
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: Colors.black), // Blue text
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
                  color: Color(0xFF03b97c),
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
