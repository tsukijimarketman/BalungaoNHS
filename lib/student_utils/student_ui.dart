// ignore_for_file: unused_element

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbma_portal/launcher.dart';
import 'package:pbma_portal/student_utils/cases/case0.dart';
import 'package:pbma_portal/student_utils/cases/case2.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';
import 'package:sidebarx/sidebarx.dart';

class StudentUI extends StatefulWidget {
  const StudentUI({super.key});

  @override
  State<StudentUI> createState() => _StudentUIState();
}

class _StudentUIState extends State<StudentUI> {
  final SidebarXController _sidebarController =
      SidebarXController(selectedIndex: 0);
  final ValueNotifier<String?> _imageNotifier = ValueNotifier<String?>(null);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  String selectedSemester = 'SELECT SEMESTER';

  @override
  void initState() {
    super.initState();
    _loadInitialProfileImage();
  }

  Future<void> _loadInitialProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
      final docSnapshot = await userDoc.get();
      final imageUrl = docSnapshot.data()?['image_url'];
      _imageNotifier.value = imageUrl; // Set initial profile picture URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _key,
      appBar: isSmallScreen
          ? AppBar(
              backgroundColor: canvasColor,
              title: Text(
                "Student Dashboard",
                style: TextStyle(color: Colors.white),
              ),
              leading: IconButton(
                onPressed: () {
                  _key.currentState?.openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
            )
          : null,
      drawer: isSmallScreen
          ? ExampleSidebarX(
              controller: _sidebarController,
              imageNotifier: _imageNotifier, // Pass imageNotifier here
            )
          : null,
      body: Row(
        children: [
          if (!isSmallScreen)
            ExampleSidebarX(
              controller: _sidebarController,
              imageNotifier: _imageNotifier, // Pass imageNotifier here as well
            ),
          Expanded(
            child: Center(
              child: _ScreensExample(
                controller: _sidebarController,
                selectedSemester: selectedSemester,
                onSemesterChanged: (newValue) {
                  setState(() {
                    selectedSemester = newValue;
                  });
                },
                imageNotifier:
                    _imageNotifier, // Pass imageNotifier to _ScreensExample
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ExampleSidebarX extends StatefulWidget {
  const ExampleSidebarX({
    Key? key,
    required SidebarXController controller,
    required this.imageNotifier,
  })  : _controller = controller,
        super(key: key);

  final SidebarXController _controller;
  final ValueNotifier<String?> imageNotifier;

  @override
  State<ExampleSidebarX> createState() => _ExampleSidebarXState();
}

class _ExampleSidebarXState extends State<ExampleSidebarX> {
  @override
  void initState() {
    super.initState();
    _loadStudentData();

    // Listen to changes in imageNotifier
    widget.imageNotifier.addListener(() {
      setState(() {}); // Rebuild when imageNotifier updates
    });
  }

  String? _studentId;
  String? _imageUrl; // Variable to store the student's image URL

  Future<void> _loadStudentData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          setState(() {
            _studentId = userDoc['student_id'];
            widget.imageNotifier.value = userDoc['image_url'];
          });
        } else {
          print('No matching student document found.');
        }
      } catch (e) {
        print('Failed to load student data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 1, 93, 168),
      child: SidebarX(
        controller: widget._controller,
        theme: SidebarXTheme(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: canvasColor,
            borderRadius: BorderRadius.circular(20),
          ),
          hoverColor: scaffoldBackgroundColor,
          textStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
          selectedTextStyle: const TextStyle(color: Colors.white),
          hoverTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          itemTextPadding: const EdgeInsets.only(left: 30),
          selectedItemTextPadding: const EdgeInsets.only(left: 30),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: canvasColor),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: actionColor.withOpacity(0.37),
            ),
            gradient: const LinearGradient(
              colors: [accentCanvasColor, canvasColor],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.28),
                blurRadius: 30,
              )
            ],
          ),
          iconTheme: IconThemeData(
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          selectedIconTheme: const IconThemeData(
            color: Colors.white,
            size: 20,
          ),
        ),
        extendedTheme: const SidebarXTheme(
          width: 200,
          decoration: BoxDecoration(
            color: canvasColor,
          ),
        ),
        footerDivider: divider,
        headerBuilder: (context, extended) {
          return SizedBox(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CircleAvatar(
                    radius: 100,
                    backgroundImage: widget.imageNotifier.value != null
                        ? NetworkImage(widget.imageNotifier.value!)
                        : NetworkImage(
                            'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                  ),
                ),
                if (extended)
                  Text(
                    _studentId ?? "No ID", // Display student ID if available
                    style: TextStyle(color: Colors.white),
                  ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          );
        },
        items: [
          SidebarXItem(
            icon: Icons.home,
            label: 'Home',
          ),
          const SidebarXItem(
            icon: Icons.assessment_sharp,
            label: 'View Grades',
          ),
          const SidebarXItem(
            icon: Icons.how_to_reg_sharp,
            label: 'Check Enrollment',
          ),
          const SidebarXItem(
            icon: Icons.settings,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _ScreensExample extends StatefulWidget {
  const _ScreensExample({
    Key? key,
    required this.controller,
    required this.selectedSemester,
    required this.onSemesterChanged,
    required this.imageNotifier,
  }) : super(key: key);

  final SidebarXController controller;
  final String selectedSemester;
  final ValueChanged<String> onSemesterChanged;
  final ValueNotifier<String?> imageNotifier;

  @override
  State<_ScreensExample> createState() => _ScreensExampleState();
}

class _ScreensExampleState extends State<_ScreensExample> {
  List<String> _sections = [];
  List<Map<String, dynamic>> _subjects = []; // To store the fetched subjects

  String? _studentId;
  String? _fullName;
  late String _strand;
  String? _track;
  String? _gradeLevel;
  String? _semester;
  String? _selectedSection;
  String? _enrollmentStatus;

  @override
  void initState() {
    super.initState();

    // Call all necessary functions during widget initialization
    _fetchSections();
    _loadStudentData();
    _imageGetterFromExampleState();
    _loadSubjects(); // Ensure _selectedSection is checked before calling this
    _fetchEnrollmentStatus();
  }

  Future<void> _fetchEnrollmentStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return; // Handle user not logged in

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: user.uid)
          .limit(1) // Assuming there's one document per user
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        setState(() {
          // Assuming enrollment_status is a field in your document
          _enrollmentStatus = docSnapshot.docs.first['enrollment_status'];
          // Also fetch other student details if needed
          _studentId = docSnapshot.docs.first['student_id'];
          _fullName = docSnapshot.docs.first['full_name'];
          _strand = docSnapshot.docs.first['strand'];
          _track = docSnapshot.docs.first['track'];
          _gradeLevel = docSnapshot.docs.first['grade_level'];
          _semester = docSnapshot.docs.first['semester'];
        });
      }
    } catch (e) {
      // Handle errors (e.g., network issues)
      print('Error fetching enrollment status: $e');
    }
  }

  Future<void> _loadStudentData() async {
    User? user =
        FirebaseAuth.instance.currentUser; // Get the current logged-in user

    if (user != null) {
      try {
        // Query the 'users' collection where the 'uid' field matches the current user's UID
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Assuming only one document will be returned, get the first document
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          setState(() {
            _studentId = userDoc['student_id'];
            _fullName =
                '${userDoc['first_name']} ${userDoc['middle_name'] ?? ''} ${userDoc['last_name']} ${userDoc['extension_name'] ?? ''}'
                    .trim();
            _strand = userDoc['seniorHigh_Strand'];
            _track = userDoc['seniorHigh_Track'];
            _gradeLevel = userDoc['grade_level'];
            _semester = userDoc['semester'];
          });

          // Load grades based on the selected semester
          await _loadGrades();
        } else {
          print('No matching student document found.');
        }
      } catch (e) {
        print('Failed to load student data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  Map<String, List<Map<String, String>>> semesterGrades = {};

  // Case 1
  Future<void> _loadGrades() async {
    try {
      List<String> collectionsToCheck = [
        'Grade 11 - 1st Semester',
        'Grade 11 - 2nd Semester',
        'Grade 12 - 1st Semester',
        'Grade 12 - 2nd Semester',
      ];

      // Clear previous grades
      semesterGrades.clear(); // Make sure to clear previous data

      // Loop through collections to fetch grades
      for (String collectionName in collectionsToCheck) {
        QuerySnapshot gradeSnapshot =
            await FirebaseFirestore.instance.collection(collectionName).get();

        print('Checking collection: $collectionName');

        if (gradeSnapshot.docs.isNotEmpty) {
          List<Map<String, String>> gradesList =
              []; // Temporary list for grades in this semester

          for (var gradeDoc in gradeSnapshot.docs) {
            var studentData = gradeDoc.data() as Map<String, dynamic>;

            // Loop through each student in the document
            studentData.forEach((studentKey, studentValue) {
              // Get the list of grades for the student
              List<dynamic> gradesListFromDoc = studentValue['grades'] ?? [];

              // Check each grade entry for matching UID
              for (var gradeEntry in gradesListFromDoc) {
                if (gradeEntry is Map<String, dynamic>) {
                  String uid = gradeEntry['uid'] ??
                      ''; // Get the uid from the grade entry

                  // Check if the uid matches the current user's uid
                  if (uid == FirebaseAuth.instance.currentUser?.uid) {
                    String subjectCode = gradeEntry['subject_code'] ?? '';
                    String subjectName = gradeEntry['subject_name'] ?? '';
                    String grade = gradeEntry['grade']?.toString() ?? '';

                    // Add to temporary grades list
                    gradesList.add({
                      'subject_code': subjectCode,
                      'subject_name': subjectName,
                      'grade': grade,
                    });

                    print('Added grade: $grade for subject: $subjectName');
                  }
                }
              }
            });
          }

          if (gradesList.isNotEmpty) {
            semesterGrades[collectionName] =
                gradesList; // Save to the semesterGrades map
          }
        }
      }

      setState(() {
        // Update UI
      });

      if (semesterGrades.isEmpty) {
        print('No grades found for the current user UID across all semesters.');
      }
    } catch (e) {
      print('Error loading grades: $e');
    }
  }

  // Case 1

  // Case 2
  Future<void> _saveandfinalization() async {
    if (_selectedSection != null) {
      try {
        await _saveSection();
        await _finalizeSelection();
        setState(() {}); // Update UI to show loaded subjects
      } catch (e) {
        print('Error saving and loading subjects: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving and loading subjects: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a section first.')),
      );
    }
  }

  Future<void> _saveSection() async {
  if (_selectedSection != null && _selectedSection!.isNotEmpty) {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Query Firestore for the document where 'uid' matches the logged-in user's UID
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        // Check if any documents were returned
        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          // Fetch the selected section document
          QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
              .collection('sections')
              .where('section_name', isEqualTo: _selectedSection)
              .get();

          // Check if any section documents were returned
          if (sectionSnapshot.docs.isNotEmpty) {
            DocumentSnapshot sectionDoc = sectionSnapshot.docs.first;

            // Update the 'section' field in the user's document
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userDoc.id)
                .update({
              'section': _selectedSection,
            });

            // No need to increment capacityCount anymore

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Section saved successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Section document not found.')),
            );
          }
        } else {
          print('No document found for the current user.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User document not found.')),
          );
        }
      } else {
        print('No user is logged in.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No user is logged in. Please log in to save the section.')),
        );
      }
    } catch (e) {
      print('Error saving section: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving section: $e')),
      );
    }
  } else {
    // Show an error message if no section is selected
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please select a section before saving.')),
    );
  }
}


  Future<void> _loadSubjects() async {
    if (_selectedSection != null) {
      try {
        // Fetch the selected section's document
        QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
            .collection('sections')
            .where('section_name', isEqualTo: _selectedSection)
            .get();

        if (sectionSnapshot.docs.isNotEmpty) {
          DocumentSnapshot sectionDoc = sectionSnapshot.docs.first;
          String sectionSemester = sectionDoc[
              'semester']; // Assuming 'semester' field exists in 'sections'

          // Query subjects that have the same semester as the selected section
          QuerySnapshot subjectSnapshot = await FirebaseFirestore.instance
              .collection('subjects')
              .where('semester', isEqualTo: sectionSemester)
              .get();

          setState(() {
            _subjects = subjectSnapshot.docs
                .where((doc) {
                  String strandCourse =
                      doc['strandcourse']; // Assuming this field exists

                  // Call the getStrandCourse method to check if the courses match
                  return strandCourse == getStrandCourse(_strand);
                })
                .map((doc) => {
                      'subject_code': doc[
                          'subject_code'], // Adjust field names if necessary
                      'subject_name': doc['subject_name'],
                      'category':
                          doc['category'], // Assuming 'category' field exists
                    })
                .toList();
          });

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Subjects loaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No matching section found.')),
          );
        }
      } catch (e) {
        print('Error loading subjects: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subjects: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a section before loading subjects.')),
      );
    }
  }

  bool _isFinalized = false;

  Future<void> _fetchSubjects() async {
    try {
      // Get the user document reference using the student ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('student_id', isEqualTo: _studentId)
          .limit(1)
          .get();

      if (userDoc.docs.isNotEmpty) {
        final userDocId = userDoc.docs.first.id;

        // Fetch subjects data from the sections subcollection for the selected section
        final sectionDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userDocId)
            .collection('sections')
            .doc(_selectedSection)
            .get();

        if (sectionDoc.exists) {
          setState(() {
            _subjects = List<Map<String, dynamic>>.from(
                sectionDoc.data()?['subjects'] ?? []);
            _isFinalized = sectionDoc.data()?['isFinalized'] ?? false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: User not found.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subjects: $e')),
      );
    }
  }

  Future<void> _finalizeSelection() async {
    if (_selectedSection != null && _subjects.isNotEmpty) {
      try {
        // Get the user document reference using the student ID
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .where('student_id', isEqualTo: _studentId)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty) {
          final userDocId = userDoc.docs.first.id;

          // Set the data in the sections subcollection inside this user's document
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userDocId)
              .collection('sections')
              .doc(_selectedSection!)
              .set({
            'selectedSection': _selectedSection,
            'subjects': _subjects,
            'isFinalized': true,
          });

          setState(() {
            _isFinalized = true; // Disable further editing
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Section and subjects finalized successfully!')),
          );

          // Fetch subjects again to update the table view with the saved data
          _fetchSubjects();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: User not found.')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error finalizing selection: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please select a section and load subjects first.')),
      );
    }
  }

  Future<void> _fetchSections() async {
    try {
      // Define the mapping between seniorHigh_Strand descriptive names and abbreviations
      Map<String, String> strandMap = {
        'Science, Technology, Engineering and Mathematics (STEM)': 'STEM',
        'Humanities and Social Sciences (HUMSS)': 'HUMSS',
        'Accountancy, Business, and Management (ABM)': 'ABM',
        'Information and Communication Technology (ICT)': 'ICT',
        'Home Economics (HE)': 'HE',
        'Industrial Arts (IA)': 'IA'
      };

      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Fetch the user document to get seniorHigh_Strand and grade_level
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = userSnapshot.docs.first;
          String userStrand = userDoc['seniorHigh_Strand'];
          String userGradeLevel = userDoc['grade_level'];

          // Get the abbreviation for the user's strand
          String? strandAbbreviation = strandMap[userStrand];

          if (strandAbbreviation != null) {
            // Fetch sections that match the user's grade level and strand abbreviation
            final snapshot = await FirebaseFirestore.instance
                .collection('sections')
                .where('section_name',
                    isGreaterThanOrEqualTo:
                        '$userGradeLevel-$strandAbbreviation')
                .where('section_name',
                    isLessThanOrEqualTo:
                        '$userGradeLevel-$strandAbbreviation\uf8ff')
                .get();

            setState(() {
              _sections = snapshot.docs
                  .map((doc) => doc['section_name'] as String)
                  .toList();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Strand abbreviation not found.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User document not found.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user is logged in.')),
        );
      }
    } catch (e) {
      print('Error fetching sections: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sections: $e')),
      );
    }
  }
  // Case 2

  Future<bool> _canSelectSection() async {
    if (_selectedSection != null) {
      // Fetch the section's document to check the capacity
      final sectionDoc = await FirebaseFirestore.instance
          .collection('sections')
          .doc(_selectedSection)
          .get();

      if (sectionDoc.exists) {
        int capacityCount = sectionDoc['capacityCount'] ?? 0;
        int capacity = sectionDoc['capacity'] ?? 0;
        return capacityCount <
            capacity; // Return true if there's available capacity
      }
    }
    return true; // Default to true if no section is selected
  }

  String getStrandCourse(String seniorHighStrand) {
    switch (seniorHighStrand) {
      case 'Accountancy, Business, and Management (ABM)':
        return 'ABM';
      case 'Information and Communication Technology (ICT)':
        return 'ICT';
      case 'Science, Technology, Engineering and Mathematics (STEM)':
        return 'STEM';
      case 'Humanities and Social Sciences (HUMSS)':
        return 'HUMSS';
      case 'Home Economics (HE)':
        return 'HE';
      case 'Industrial Arts (IA)':
        return 'IA';
      default:
        return ''; // Return an empty string or some default value if there's no match
    }
  }

  File? _imageFile; // For mobile (Android/iOS)
  Uint8List? _imageBytes; // For web

  String? _imageUrl;

  Future<void> _imageGetterFromExampleState() async {
    User? user =
        FirebaseAuth.instance.currentUser; // Get the current logged-in user

    if (user != null) {
      try {
        // Query the 'users' collection where the 'uid' field matches the current user's UID
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          // Assuming only one document will be returned, get the first document
          DocumentSnapshot userDoc = userSnapshot.docs.first;

          setState(() {
            _imageUrl = userDoc['image_url'];
          });
        } else {
          print('No matching student document found.');
        }
      } catch (e) {
        print('Failed to load student data: $e');
      }
    } else {
      print('User is not logged in.');
    }
  }

  final ImagePicker picker = ImagePicker();

  bool _isHovered = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, store the image as Uint8List
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageFile = null; // Clear mobile file if on web
        });
      } else {
        // For mobile, store the image as File
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null; // Clear web bytes if on mobile
        });
      }
    }
  }

  Future<void> replaceProfilePicture() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("No user is currently signed in.");
        return;
      }

      final userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (userQuerySnapshot.docs.isEmpty) {
        print("User document not found for UID: ${currentUser.uid}");
        return;
      }

      final userDoc = userQuerySnapshot.docs.first;
      final userDocRef = userDoc.reference;

      String? oldImageUrl = userDoc.data()['image_url'];
      print("Old Image URL: $oldImageUrl");

      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          final oldImageRef = FirebaseStorage.instance.refFromURL(oldImageUrl);
          await oldImageRef.delete();
          print("Old profile picture deleted successfully.");
        } catch (e) {
          print("Failed to delete old profile picture: $e");
        }
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('student_pictures')
          .child('${DateTime.now().toIso8601String()}.png');

      if (_imageBytes != null) {
        await storageRef.putData(_imageBytes!);
      } else if (_imageFile != null) {
        await storageRef.putFile(_imageFile!);
      } else {
        print("No image selected.");
        return;
      }

      final newImageUrl = await storageRef.getDownloadURL();
      print("New Image URL: $newImageUrl");

      await userDocRef.update({'image_url': newImageUrl});
      print("Profile picture updated successfully.");

      // Update the imageNotifier with the new URL to trigger a rebuild in ExampleSidebarX
      if (mounted) {
        widget.imageNotifier.value = newImageUrl;
      }
    } catch (e) {
      print("Failed to replace profile picture: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        final pageTitle = _getTitleByIndex(widget.controller.selectedIndex);
        switch (widget.controller.selectedIndex) {
          case 0:
            return Case0();
          case 1:
  if (semesterGrades.isEmpty) {
    return Container(
      padding: EdgeInsets.all(16.0),
      color: Color.fromARGB(255, 1, 93, 168),
      child: Center(
        child: Text(
          'No grades found.',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
  return LayoutBuilder(
    builder: (context, constraints) {
      double screenWidth = MediaQuery.of(context).size.width;

      // Adjust font sizes dynamically
      double titleFontSize = screenWidth < 600 ? 18 : 24;
      double semesterFontSize = screenWidth < 600 ? 14 : 20;
      double tableFontSize = screenWidth < 600 ? 12 : 14;
      double principalFontSize = screenWidth < 600 ? 10 : 12;
      double buttonPadding = screenWidth < 600 ? 20 : 30;

      return Container(
        width: double.infinity,
        height: double.infinity, // Fill the screen height
        color: Color.fromARGB(255, 1, 93, 168),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REPORT CARD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                ...semesterGrades.entries.map((entry) {
                  String semester = entry.key;
                  List<Map<String, String>> grades = entry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        semester,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: semesterFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Table(
                          border: TableBorder.all(color: Colors.black),
                          columnWidths: {
                            0: FlexColumnWidth(2),
                            1: FlexColumnWidth(4),
                            2: FlexColumnWidth(2),
                          },
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Course Code',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: tableFontSize,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Subject',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: tableFontSize,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Grade',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: tableFontSize,
                                  ),
                                ),
                              ),
                            ]),
                            ...grades.map((subject) {
                              return TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    subject['subject_code'] ?? '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: tableFontSize,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    subject['subject_name'] ?? '',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: tableFontSize,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    subject['grade'] ?? 'N/A',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: tableFontSize,
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                }).toList(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Print Button on the left
                    ElevatedButton(
                      onPressed: () {
                        // Handle print result functionality
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.yellow,
                        padding: EdgeInsets.symmetric(
                          horizontal: buttonPadding,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Print Result',
                        style: TextStyle(fontSize: tableFontSize),
                      ),
                    ),
                    // Principal's Section on the right
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Text(
                            'Urbano Delos Angeles IV',
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 12 : 18,
                              fontFamily: "B",
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: screenWidth < 600 ? 150 : 250,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.blue, Colors.yellow],
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SCHOOL PRINCIPAL',
                          style: TextStyle(
                            fontSize: principalFontSize,
                            color: Colors.white,
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
      );
    },
  );

          case 2:
             return EnrollmentStatusWidget(
        enrollmentStatus: _enrollmentStatus,
        studentId: _studentId,
        fullName: _fullName,
        strand: _strand,
        track: _track,
        gradeLevel: _gradeLevel,
        semester: _semester,
        sections: _sections,
        subjects: _subjects,
        isFinalized: _isFinalized,
        selectedSection: _selectedSection,
        onSectionChanged: (newValue) {
          setState(() {
            _selectedSection = newValue;
          });
        },
        onLoadSubjects: _loadSubjects,
        onFinalize: _saveandfinalization,
      );
          case 3:
            return SingleChildScrollView(
              child: Container(
                color: Color.fromARGB(255, 1, 93, 168),
                width: screenWidth,
                child: Container(
                  margin: EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await _pickImage(); // Open image picker to select a new image

                                  if (_imageBytes != null ||
                                      _imageFile != null) {
                                    await replaceProfilePicture(); // Upload and replace the profile picture

                                    // Reload the new image URL from Firestore after uploading
                                    await _imageGetterFromExampleState();

                                    setState(
                                        () {}); // Refresh the UI after updating the image URL
                                  }
                                },
                                child: MouseRegion(
                                  onEnter: (_) {
                                    setState(() {
                                      _isHovered = true;
                                    });
                                  },
                                  onExit: (_) {
                                    setState(() {
                                      _isHovered = false;
                                    });
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 85,
                                        backgroundImage: _imageBytes != null
                                            ? MemoryImage(_imageBytes!)
                                                as ImageProvider
                                            : _imageFile != null
                                                ? FileImage(_imageFile!)
                                                    as ImageProvider
                                                : _imageUrl != null
                                                    ? NetworkImage(_imageUrl!)
                                                        as ImageProvider
                                                    : const NetworkImage(
                                                        'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png',
                                                      ),
                                      ),
                                      if (_isHovered)
                                        Container(
                                          width: 170,
                                          height: 170,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.5),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.image,
                                            color: Colors.white,
                                            size: 60,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ).showCursorOnHover,
                              SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Gerick",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "B",
                                            fontSize: 30),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Molina",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "B",
                                            fontSize: 30),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Velasquez",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "B",
                                            fontSize: 30),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          await _pickImage(); // Open image picker to select a new image

                                          if (_imageBytes != null ||
                                              _imageFile != null) {
                                            await replaceProfilePicture(); // Upload and replace the profile picture

                                            // Reload the new image URL from Firestore after uploading
                                            await _imageGetterFromExampleState();

                                            setState(
                                                () {}); // Refresh the UI after updating the image URL
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Edit Profile",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontFamily: "B",
                                                    fontSize: 15),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Colors.black,
                                              )
                                            ],
                                          ),
                                        ),
                                      ).showCursorOnHover.moveUpOnHover,
                                      SizedBox(
                                        width: 15,
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          logout();
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 150,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Logout",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 1, 93, 168),
                                                    fontFamily: "B",
                                                    fontSize: 15),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Icon(
                                                Icons.logout_rounded,
                                                size: 20,
                                                color: Color.fromARGB(
                                                    255, 1, 93, 168),
                                              )
                                            ],
                                          ),
                                        ),
                                      ).showCursorOnHover.moveUpOnHover,
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Student Information",
                        style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 25,
                            fontFamily: "SB"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "First Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 309,
                                child: TextFormField(
                                  initialValue: "Gerick",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Middle Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 309,
                                child: TextFormField(
                                  initialValue: "Molina",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Last Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 309,
                                child: TextFormField(
                                  initialValue: "Velasquez",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Extension Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 150,
                                child: TextFormField(
                                  initialValue: "",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Age",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 100,
                                child: TextFormField(
                                  initialValue: "21",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Gender",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 100,
                                child: TextFormField(
                                  initialValue: "Male",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Birthdate",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 100,
                                child: TextFormField(
                                  initialValue: "06/11/2003",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Email Address",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 300,
                                child: TextFormField(
                                  initialValue: "teenbritish11@gmail.com",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Phone Number",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 150,
                                child: TextFormField(
                                  initialValue: "09919382645",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Student Number",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 150,
                                child: TextFormField(
                                  initialValue: "2024-PBMA-0011",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "LRN",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 150,
                                child: TextFormField(
                                  initialValue: "101815080468",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Home Address",
                        style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 25,
                            fontFamily: "SB"),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "House Number",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 125,
                                child: TextFormField(
                                  initialValue: "81",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Street Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 125,
                                child: TextFormField(
                                  initialValue: "Zone 2",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Subdivision/Barangay",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 200,
                                child: TextFormField(
                                  initialValue: "Tebag",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "City/Municipality",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 200,
                                child: TextFormField(
                                  initialValue: "Mangaldan",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Province",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 200,
                                child: TextFormField(
                                  initialValue: "Pangasinan",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Country",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 200,
                                child: TextFormField(
                                  initialValue: "Philippines",
                                  enabled: true,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Parent Guardian Information",
                        style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 25,
                            fontFamily: "SB"),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "Father's Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 309,
                                child: TextFormField(
                                  initialValue: "Gerry A. Velasquez",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Mother's Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 309,
                                child: TextFormField(
                                  initialValue: "Glenda M. Velasquez",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Guardian's Name",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 309,
                                child: TextFormField(
                                  initialValue: "Glenda M. Velasquez",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                "Relationship",
                                style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 13),
                              Container(
                                width: 150,
                                child: TextFormField(
                                  initialValue: "Mother",
                                  enabled: false,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontFamily: "R",
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[300],
                                  ),
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
            );
          default:
            return Text(
              pageTitle,
              style: theme.textTheme.headlineSmall,
            );
        }
      },
    );
  }

  String _getTitleByIndex(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'View Grades';
      case 2:
        return 'Check Enrollment';
      case 3:
        return 'Settings';
      default:
        return 'Not found page';
    }
  }
}

// Your colors here, replace with actual color values if needed
const canvasColor = Color(0xFF1D3557);
const scaffoldBackgroundColor = Color(0xFF457B9D);
const accentCanvasColor = Color(0xFFA8DADC);
const actionColor = Color(0xFFF4A261);
const divider = Divider(color: Colors.white54, thickness: 1);
