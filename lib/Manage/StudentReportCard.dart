import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:printing/printing.dart';

class StudentReportCards extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final String studentDocId;

  const StudentReportCards({
    super.key, 
    required this.studentData, 
    required this.studentDocId
    }
    );

  @override
  State<StudentReportCards> createState() => _StudentReportCardsState();
}

class _StudentReportCardsState extends State<StudentReportCards> {
    String _email = '';
  String _accountType = '';
  String _firstName = '';
  String _lastName = '';
  List<Map<String, dynamic>> subjects = [];
  List<bool> isEditing = [];
  bool _hovering = false;
  bool _isLoading = true;


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

  Future<List<Map<String, dynamic>>> _fetchGrades() async {
  List<Map<String, dynamic>> allGrades = [];

  List<String> collections = [
    'Grade 11 - 1st Semester',
    'Grade 11 - 2nd Semester',
    'Grade 12 - 1st Semester',
    'Grade 12 - 2nd Semester'
  ];

  // Construct the full name from studentData
  String fullName = '${widget.studentData['first_name']} ${widget.studentData['last_name']}';

  for (String collection in collections) {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(collection)
        .doc(widget.studentData['seniorHigh_Strand']) // Ensure this is the correct document ID
        .get(); // Get the document

    print('Querying collection: $collection'); // Debugging line
    if (snapshot.exists) { // Check if the document exists
      var gradesData = snapshot.data() as Map<String, dynamic>; // Cast to Map
      print('Document data: $gradesData'); // Log the document data

      // Access the grades array for the student
      if (gradesData.containsKey(fullName)) {
        var studentGrades = gradesData[fullName]['grades']; // Access the grades array
        for (var gradeEntry in studentGrades) {
          allGrades.add({
            'subject_name': gradeEntry['subject_name'], // Fetch subject name
            'subject_code': gradeEntry['subject_code'], // Fetch subject code
            'grade': gradeEntry['grade'], // Fetch grade
          });
        }
      } else {
        print('No grades found for student: $fullName in collection: $collection');
      }
    } else {
      print('No document found in collection: $collection'); // Improved logging
    }
  }

  return allGrades;
}


@override
void initState() {
  super.initState();
  _fetchUserData();
  _fetchGrades().then((grades) {
    setState(() {
      subjects = grades;
      _isLoading = false; // Set loading to false after fetching
    });
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
                          _accountType,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Reports Card',
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
                          Navigator.pop(
                              context); // Go back to the previous page (Student List)
                        },
                        child: Text(
                          'Student Reports',
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
                      'Student Reports Card',
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
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 16),
                                    GestureDetector(
                                      onTap: () {},
                                      child: widget.studentData['image_url'] !=
                                              null
                                          ? CircleAvatar(
                                              radius: 100,
                                              backgroundImage: NetworkImage(
                                                  widget.studentData[
                                                      'image_url']),
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
                                    Text(widget.studentData['email_Address'] ??
                                        ''),
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
                              _buildDetailRow(Icons.location_on, 'Address',
                                  combinedAddress),
                              _buildDetailRow(Icons.phone, 'Contact Number',
                                  widget.studentData['phone_number'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Birthday',
                                  widget.studentData['birthdate'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Age',
                                  widget.studentData['age'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Gender',
                                  widget.studentData['gender'] ?? ''),
                              _buildDetailRow(Icons.grade, 'Grade',
                                  widget.studentData['grade_level'] ?? ''),
                              _buildDetailRow(Icons.track_changes, 'Track',
                                  widget.studentData['seniorHigh_Track'] ?? ''),
                              _buildDetailRow(
                                  Icons.track_changes,
                                  'Strand',
                                  widget.studentData['seniorHigh_Strand'] ??
                                      ''),
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
                              _buildDetailRow(
                                  Icons.cake,
                                  'Relationship to Guardian',
                                  widget.studentData['relationshipGuardian'] ??
                                      ''),
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
                                      color: Colors.grey[300],
                                    ),
                                    children: [
                                      TableCell(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'Subject Code',
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
                                            'Subject Name',
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
                                            'Grade',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Grades Rows
                                  for (var grade in subjects) // Display each grade
                                    TableRow(
                                      children: [
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(grade['subject_code'] ?? ''),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(grade['subject_name'] ?? ''),
                                          ),
                                        ),
                                        TableCell(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(grade['grade'] ?? ''),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                            Container(
                              height: 30,
                              width: 300,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.blue),
                                  elevation:
                                      MaterialStateProperty.all<double>(5),
                                  shape: MaterialStateProperty.all<
                                      OutlinedBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                onPressed: _generatePDF,

                                child: Text(
                                  'Download to PDF',
                                  style: TextStyle(color: Colors.white),
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
  void _generatePDF() async {
  final pdf = pw.Document();
  
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4.landscape,
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Student Report Card',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${widget.studentData['first_name']} ${widget.studentData['last_name']}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.normal),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Subject Code', 'Subject Name', 'Grade'],
              data: subjects.map((grade) {
                return [
                  grade['subject_code'] ?? '',
                  grade['subject_name'] ?? '',
                  grade['grade'] ?? '',
                ];
              }).toList(),
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

  final pdfBytes = await pdf.save();
      await Printing.sharePdf(
          bytes: pdfBytes, filename: 'report_grade.pdf');
  }
}