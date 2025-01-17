import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnrollmentStatusWidget extends StatelessWidget {
  final String? enrollmentStatus;
  final String? studentId;
  final String? fullName;
  final String? strand;
  final String? track;
  final String? gradeLevel;
  final String? semester;
  final String? quarter;
  final List<String> sections;
  final List<Map<String, dynamic>> subjects;
  final bool isFinalized;
  final String? selectedSection;
  final VoidCallback? FinalizedData;
  final Function(String?)? onSectionChanged;
  final VoidCallback? onLoadSubjects;
  final VoidCallback? onFinalize;
  final VoidCallback? checkEnrollmentStatus; // Add this line
  final String? educLevel;


  const EnrollmentStatusWidget({
    Key? key,
    required this.enrollmentStatus,
    required this.studentId,
    required this.fullName,
    required this.strand,
    required this.track,
    required this.gradeLevel,
    required this.semester,
        required this.quarter,

    required this.sections,
    required this.subjects,
    required this.isFinalized,
    required this.selectedSection,
    this.onSectionChanged,
    this.onLoadSubjects,
    this.onFinalize,
    this.checkEnrollmentStatus, // Add this line
    this.FinalizedData,
      required this.educLevel, // Add this

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define breakpoints
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1200;
    final bool isWeb = screenWidth >= 1200;
    

    // Define styles and dimensions based on device type
    final double padding = isMobile ? 10 : (isTablet ? 20 : 30);
    final double imageSize = isMobile
        ? screenWidth / 3
        : (isTablet ? screenWidth / 4 : screenWidth / 5);
    final double textFontSize = isMobile ? 14 : (isTablet ? 18 : 22);
    final double titleFontSize = isMobile ? 20 : (isTablet ? 20 : 24);

    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 1, 93, 168),
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to the left
              children: [
                // Title Text
                Text(
                  "Check Enrollment",
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20), // Add spacing below the title
                if (enrollmentStatus == null)
                  Center(
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
                else if (enrollmentStatus == 'reEnrollSubmitted')
                  _buildReEnrollSubmittedContent(imageSize, textFontSize)
                else if (enrollmentStatus == 'approved')
                  if (isFinalized)
                    _buildFinalizedContent(context, textFontSize)
                  else
                    _buildApprovedContent(context, textFontSize),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReEnrollSubmittedContent(double imageSize, double textFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'assets/PBMA.png',
            width: imageSize,
            height: imageSize,
          ),
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(fontSize: textFontSize, color: Colors.white),
            children: const [
              TextSpan(text: 'Your enrollment is '),
              TextSpan(
                  text: 'currently under review',
                  style: TextStyle(color: Colors.yellow)),
              TextSpan(
                text:
                    '. Please be patient as the admin processes your application.\n If you have any questions or need further assistance, feel free to reach out to the admin office.\n Thank you for your understanding!',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinalizedContent(BuildContext context, double textFontSize) {
  return Column(
    children: [
      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('student_id', isEqualTo: studentId)
            .limit(1)
            .snapshots()
            .asyncMap((snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            String docId = snapshot.docs.first.id;
            return await FirebaseFirestore.instance
                .collection('users')
                .doc(docId)
                .collection('sections')
                .doc(docId)
                .get();
          }
          throw Exception('User not found');
        }),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;

            if (data != null && data['finalizationTimestamp'] != null) {
              final Timestamp timestamp =
                  data['finalizationTimestamp'] as Timestamp;
              final DateTime dateTime = timestamp.toDate();
              final String formattedDate =
                  DateFormat('MMMM dd, yyyy hh:mm a').format(dateTime);

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Finalized on: $formattedDate',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
          }
          return const SizedBox(); // Return empty widget if no data
        },
      ),
      _buildStudentDataRow('Student ID no:', studentId, textFontSize),
      _buildStudentDataRow('Student Full Name:', fullName, textFontSize),

      // Conditionally show strand, track, and semester based on educLevel
      if (educLevel == 'Senior High School') ...[
        _buildStudentDataRow('Strand:', strand, textFontSize),
        _buildStudentDataRow('Track:', track, textFontSize),
        _buildStudentDataRow('Semester:', semester, textFontSize),
      ] else if (educLevel == 'Junior High School') ...[
        _buildStudentDataRow('Quarter:', quarter, textFontSize),
      ],

      // Show selected section as text
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Section: ${selectedSection}',
            style: TextStyle(
              color: Colors.black,
              fontSize: textFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      // Conditionally show the subjects table for Senior High School
      if (educLevel == 'Senior High School')
        Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            border: TableBorder.all(color: Colors.white.withOpacity(0.3)),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(4),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
                children: [
                  _buildHeaderCell('Subject Code'),
                  _buildHeaderCell('Subject Name'),
                  _buildHeaderCell('Category'),
                ],
              ),
              ...subjects
                  .map((subject) => TableRow(
                        children: [
                          _buildCell(subject['subject_code'] ?? ''),
                          _buildCell(subject['subject_name'] ?? ''),
                          _buildCell(subject['category'] ?? ''),
                        ],
                      ))
                  .toList(),
            ],
          ),
        ),
              if (educLevel == 'Junior High School')
Container(
          margin: EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Table(
            border: TableBorder.all(color: Colors.white.withOpacity(0.3)),
            columnWidths: const {
                      0: FlexColumnWidth(2),  // Only one column for Junior High
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                ),
                children: [
                  _buildHeaderCell('Subject Name'),
                ],
              ),
              ...subjects
                  .map((subject) => TableRow(
                        children: [
                          _buildCell(subject['subject_name'] ?? ''),
                        ],
                      ))
                  .toList(),
            ],
          ),
        ),
    ],
  );
}

  Widget _buildApprovedContent(BuildContext context, double textFontSize) {
  return Column(
    children: [
      _buildStudentDataRow('Student ID no:', studentId, textFontSize),
      _buildStudentDataRow('Student Full Name:', fullName, textFontSize),
      
      // Conditionally show Strand, Track, and Semester for Senior High School
      if (educLevel == 'Senior High School') ...[
        _buildStudentDataRow('Strand:', strand, textFontSize),
        _buildStudentDataRow('Track:', track, textFontSize),
        _buildStudentDataRow('Semester:', semester, textFontSize),
      ],

      _buildStudentDataRow('Grade Level:', gradeLevel, textFontSize),
      _buildSectionDropdown(),
      
      if (!isFinalized)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: onLoadSubjects,
            style: ElevatedButton.styleFrom(
              foregroundColor: Color.fromARGB(255, 1, 93, 168),
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              minimumSize: Size(80, 20),
            ),
            child: const Text('Load Section'),
          ),
        ),
      const SizedBox(height: 20),
     if (educLevel == 'Junior High School') 
        _buildJHSSubjectsTable(), // Show Junior High School Table
      if (educLevel == 'Senior High School') 
        _buildSubjectsTable(), // Show Senior High School Table

      _buildFinalizeButton(),
    ],
  );
}

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildStudentDataRow(
      String label, String? value, double textFontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: textFontSize),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value ?? '',
              style: TextStyle(color: Colors.white, fontSize: textFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDropdown() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black, width: 1.0),
        ),
        child: DropdownButton<String>(
          value: selectedSection,
          hint: const Text('Select a section'),
          items: sections.map((String section) {
            return DropdownMenuItem<String>(
              value: section,
              child: Text(section),
            );
          }).toList(),
          onChanged: isFinalized ? null : onSectionChanged,
        ),
      ),
    );
  }

  Widget _buildJHSSubjectsTable() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(2),  // Only one column for Junior High
      },
      children: [
        _buildJHSTableHeaderRow(),
        if (subjects.isNotEmpty)
          ...subjects.map((subject) => _buildJHSSubjectRow(subject))
        else
          _buildJHSPlaceholderRow(),
      ],
    ),
  );
}

TableRow _buildJHSTableHeaderRow() {
  return const TableRow(
    children: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Subject', style: TextStyle(color: Colors.white)),
      ),
    ],
  );
}

TableRow _buildJHSSubjectRow(Map<String, dynamic> subject) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(subject['subject_name'],
            style: const TextStyle(color: Colors.white)),
      ),
    ],
  );
}

TableRow _buildJHSPlaceholderRow() {
    return const TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No subjects available',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }

  Widget _buildSubjectsTable() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20.0),
    child: Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: const {
        0: FlexColumnWidth(2), // Course Code
        1: FlexColumnWidth(4), // Subject Name
        2: FlexColumnWidth(2), // Category
      },
      children: [
        _buildTableHeaderRow(),
        if (subjects.isNotEmpty)
          ...subjects.map((subject) => _buildSubjectRow(subject))
        else
          _buildPlaceholderRow(),
      ],
    ),
  );
}

TableRow _buildTableHeaderRow() {
  return const TableRow(
    children: [
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Course Code', style: TextStyle(color: Colors.white)),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Subject', style: TextStyle(color: Colors.white)),
      ),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Category', style: TextStyle(color: Colors.white)),
      ),
    ],
  );
}

TableRow _buildSubjectRow(Map<String, dynamic> subject) {
  return TableRow(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(subject['subject_code'] ?? 'N/A',
            style: const TextStyle(color: Colors.white)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(subject['subject_name'],
            style: const TextStyle(color: Colors.white)),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(subject['category'] ?? 'N/A',
            style: const TextStyle(color: Colors.white)),
      ),
    ],
  );
}

  TableRow _buildPlaceholderRow() {
    return const TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No subjects available',
              style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
        ),
        SizedBox(),
        SizedBox(),
      ],
    );
  }

  Widget _buildFinalizeButton() {
    return ElevatedButton(
      onPressed: isFinalized ? null : onFinalize,
      style: ElevatedButton.styleFrom(
        foregroundColor: Color.fromARGB(255, 1, 93, 168),
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: Size(80, 20),
      ),
      child: const Text('Finalize'),
    );
  }
}
