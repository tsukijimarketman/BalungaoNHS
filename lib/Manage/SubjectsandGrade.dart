import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SubjectsandGrade extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const SubjectsandGrade({
    super.key, 
    required this.studentData
    });

  @override
  State<SubjectsandGrade> createState() => _SubjectsandGradeState();
}

class _SubjectsandGradeState extends State<SubjectsandGrade> {

  String _email = '';
  String _accountType = '';
  String _firstName = '';
  String _lastName = '';
  List<Map<String, dynamic>> subjects = [];
  List<bool> isEditing = [];
    bool _hovering = false;
      bool _isLoading = true;



  // Toggle the edit mode of a specific grade
  void toggleEdit(int index) {
    setState(() {
      isEditing[index] = !isEditing[index];
    });
  }

  // Save the grades and exit edit mode
  void submitGrades() async {
  try {
    // Ensure all edits are toggled off
    for (int i = 0; i < isEditing.length; i++) {
      isEditing[i] = false;
    }

    // Fetch the semester from the sections collection
    String sectionName = widget.studentData['section'];

    // Get the corresponding section document
    QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
        .collection('sections')
        .where('section_name', isEqualTo: sectionName)
        .where('section_adviser', isEqualTo: '$_firstName $_lastName')
        .get();

    if (sectionSnapshot.docs.isNotEmpty) {
      String semester = sectionSnapshot.docs.first['semester'];
      String seniorHighStrand = widget.studentData['seniorHigh_Strand'];

      // Get student's full name and UID
      String studentFullName = '${widget.studentData['first_name']} ${widget.studentData['last_name']}';
      String studentUID = widget.studentData['uid']; // Assuming uid is part of studentData

      // Create a new collection for the strand
      CollectionReference strandCollection = FirebaseFirestore.instance.collection(semester);

      // Create or reference the document for the seniorHigh_Strand
      DocumentReference strandDocument = strandCollection.doc(seniorHighStrand);

      // Prepare the data to save
      List<Map<String, dynamic>> gradesToSave = subjects.map((subject) {
        return {
          'student_id': widget.studentData['student_id'],
          'full_name': studentFullName,
          'uid': studentUID, // Include UID here
          'subject_code': subject['subject_code'],
          'subject_name': subject['subject_name'],
          'grade': subject['grade'],
          'semester': semester,
        };
      }).toList();

      // Save the grades to the nested document named after the student's full name
      await strandDocument.set({
        studentFullName: {
          'grades': gradesToSave,
        },
      }, SetOptions(merge: true)); // Merge to update existing grades if the document already exists

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(
        children: [
          Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
          Text('Grades submitted successfully!'),
        ],
      )));
    } else {
      print('No section found for section name: $sectionName and adviser: $_firstName $_lastName');
    }
  } catch (e) {
    print('Error submitting grades: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Row(
      children: [
        Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
        Text('Error submitting grades: $e'),
      ],
    )));
  } finally {
    setState(() {}); // Update the UI if needed
  }
}


  @override
void initState() {
  super.initState();
  _fetchUserData().then((_) {
    print('First Name: $_firstName, Last Name: $_lastName'); // Debug output
    _fetchStudentSectionAndSubjects(widget.studentData);
  });
}

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
          _firstName = data['first_name']; // Get first name
          _lastName = data['last_name']; // Get last name
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

  Future<void> _fetchStudentSectionAndSubjects(Map<String, dynamic> userData) async {
  try {
    setState(() {
        _isLoading = true; // Set loading to true when fetching starts
      });
    print('First Name: $_firstName, Last Name: $_lastName');
    String sectionName = userData['section'] ?? '';
    String seniorHighStrand = userData['seniorHigh_Strand'] ?? '';
    
    // Combine first and last names to create full name
    String studentFullName = '${userData['first_name']} ${userData['last_name']}';

    // Get the corresponding course strand
    String courseStrand = getStrandCourse(seniorHighStrand);

    // Log section name and adviser
    print('Fetching section for: Section Name: $sectionName, Adviser: $_firstName $_lastName');

    // Fetch the section document based on the section name and the logged-in user's name
    QuerySnapshot sectionSnapshot = await FirebaseFirestore.instance
        .collection('sections')
        .where('section_name', isEqualTo: sectionName)
        .where('section_adviser', isEqualTo: '$_firstName $_lastName')
        .get();

    if (sectionSnapshot.docs.isNotEmpty) {
      // Get the semester of the section
      String semester = sectionSnapshot.docs.first['semester'];
      print('Found semester: $semester');

      // Fetch subjects that match the semester and course strand
      QuerySnapshot subjectsSnapshot = await FirebaseFirestore.instance
          .collection('subjects')
          .where('semester', isEqualTo: semester)
          .where('strandcourse', isEqualTo: courseStrand)
          .get();

      print('Number of subjects found: ${subjectsSnapshot.docs.length}');

      // Store subjects in the list
      subjects = subjectsSnapshot.docs.map((doc) {
        return {
          'subject_code': doc['subject_code'],
          'subject_name': doc['subject_name'],
          'grade': '', // Initialize with an empty string
        };
      }).toList();

      // Now, fetch the existing grades for the student
      String studentUID = userData['uid']; // Get the UID from userData

      // Fetch the grades for this student from Firestore
      DocumentReference gradesDocument = FirebaseFirestore.instance
          .collection(semester)
          .doc(seniorHighStrand);

      DocumentSnapshot gradesSnapshot = await gradesDocument.get();

      if (gradesSnapshot.exists) {
        // Cast to Map<String, dynamic>
        Map<String, dynamic> gradesData = gradesSnapshot.data() as Map<String, dynamic>? ?? {};
        
        // Accessing the grades for the specific student using their full name
        Map<String, dynamic>? studentGrades = gradesData[studentFullName] as Map<String, dynamic>?;

        if (studentGrades != null) {
          List<dynamic> existingGrades = studentGrades['grades'] ?? [];

          // Update subjects with existing grades
          for (var subject in subjects) {
            var existingGrade = existingGrades.firstWhere(
              (grade) => grade['subject_code'] == subject['subject_code'],
              orElse: () => null,
            );

            if (existingGrade != null) {
              subject['grade'] = existingGrade['grade']; // Assign existing grade
            }
          }
        }
      }

      // Initialize editing states
            isEditing = List<bool>.filled(subjects.length, false);

      setState(() {
                _isLoading = false; // Set loading to false when done

      });
    } else {
      print('No section found for section name: $sectionName and adviser: $_firstName $_lastName');
      setState(() {
        subjects = [];
        isEditing = [];
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error fetching student section and subjects: $e');
    setState(() {
      _isLoading = false;
      subjects = []; // Initialize as empty list on error
      isEditing = []; // Initialize as empty list on error
    });
  }
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor:
              Colors.white, // Set the background color to match the image
          title: Padding(
            padding: const EdgeInsets.only(
                left: 16.0, top: 16.0, bottom: 16.0, right: 30),
            child: Row(
              children: [
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
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
                          'TEACHER',
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
      body: Column(
        children: [
            // Breadcrumb Container (unchanged)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Details & Grading',
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
                          Navigator.pop(context); // Go back to the previous page (Student List)
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
                      'Student Details & Grading',
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
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '${widget.studentData['accountType']?.toUpperCase()}',
                                      style: TextStyle(
                                          fontSize: 24, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {},
                                      child: widget.studentData['image_url'] != null
                                          ? CircleAvatar(
                                              radius: 100,
                                              backgroundImage: NetworkImage(
                                                  widget.studentData['image_url']),
                                            )
                                          : CircleAvatar(
                                              radius: 100,
                                              backgroundImage: NetworkImage(
                                                  'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                                            ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      '${widget.studentData['first_name']} ${widget.studentData['middle_name']} ${widget.studentData['last_name']} ${widget.studentData['extension_name']}',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    Text(widget.studentData['email_Address'] ?? ''),
                                  ],
                                ),
                              ),
                              Text(
                                'Student Details',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              _buildDetailRow(Icons.tag, 'Student Number',
                                  widget.studentData['student_id'] ?? ''),
                              _buildDetailRow(Icons.email, 'Email Address',
                                  widget.studentData['email_Address'] ?? ''),
                              _buildDetailRow(
                                  Icons.location_on, 'Address', combinedAddress),
                              _buildDetailRow(Icons.phone, 'Contact Number',
                                  widget.studentData['phone_number'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Birthday',
                                  widget.studentData['birthdate'] ?? ''),
                              _buildDetailRow(
                                  Icons.cake, 'Age', widget.studentData['age'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Gender',
                                  widget.studentData['gender'] ?? ''),
                              _buildDetailRow(Icons.grade, 'Grade',
                                  widget.studentData['grade_level'] ?? ''),
                              _buildDetailRow(Icons.track_changes, 'Track',
                                  widget.studentData['seniorHigh_Track'] ?? ''),
                              _buildDetailRow(Icons.track_changes, 'Strand',
                                  widget.studentData['seniorHigh_Strand'] ?? ''),
                              _buildDetailRow(
                                  Icons.track_changes,
                                  'Belonging to Indigenous People (IP) Group',
                                  widget.studentData['indigenous_group'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Father`s Name',
                                  widget.studentData['fathersName'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Mother`s Name',
                                  widget.studentData['mothersName'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Guardian`s Name',
                                  widget.studentData['guardianName'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Relationship to Guardian',
                                  widget.studentData['relationshipGuardian'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Junior High School',
                                  widget.studentData['juniorHS'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Address of JHS',
                                  widget.studentData['schoolAdd'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Transferee',
                                  widget.studentData['transferee'] ?? ''),
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
                            Expanded(
                              child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Table(
                                  border: TableBorder.all(),
                                  children: [
                                    // Header Row
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[
                                            300], // Light gray background for header
                                      ),
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Subject Code', // Header for Subject Code
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Subject Name', // Header for Subject Name
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Grade', // Header for Grade
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                
                                    // Data Rows
                                    ...List.generate(subjects.length, (index) {
                                      return TableRow(
                                        children: [
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(subjects[index]
                                                      ['subject_code'] ??
                                                  'No Code'), // Display subject code
                                            ),
                                          ),
                                          TableCell(
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(subjects[index]
                                                      ['subject_name'] ??
                                                  'No Subject'), // Display subject name
                                            ),
                                          ),
                                          TableCell(
                                            child: isEditing[index]
                                                ? CupertinoTextField(
                                                  keyboardType: TextInputType.number,
                                                    placeholder: subjects[index]
                                                            ['grade'] ??
                                                        'Enter Grade',
                                                    onChanged: (value) {
                                                      setState(() {
                                                        subjects[index]['grade'] =
                                                            value; // Update grade in subjects list
                                                      });
                                                    },
                                                  )
                                                : GestureDetector(
                                                    onTap: () => toggleEdit(index),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(
                                                        subjects[index]['grade'] ??
                                                            'No Grade',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 30,
                                  width: 150,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.blue),
                                        elevation:
                                            MaterialStateProperty.all<double>(5),
                                        shape:
                                            MaterialStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                  onPressed: () {
                                    setState(() {
                                      // Toggle all fields to edit mode
                                      for (int i = 0; i < isEditing.length; i++) {
                                        isEditing[i] = true;
                                      }
                                    });
                                  },
                                  child: Text('Edit', style: TextStyle(color: Colors.white),),
                                ),
                                ),
                                Container(
                                  height: 30,
                                  width: 150,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green.shade500),
                                        elevation:
                                            MaterialStateProperty.all<double>(5),
                                        shape:
                                            MaterialStateProperty.all<OutlinedBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      ),
                                  onPressed: submitGrades,
                                  child: Text('Submit', style: TextStyle(color: Colors.white),),
                                ),
                                )
                              ],
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
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}