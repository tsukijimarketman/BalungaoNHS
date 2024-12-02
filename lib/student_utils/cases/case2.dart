import 'package:flutter/material.dart';

class EnrollmentStatusWidget extends StatelessWidget {
  final String? enrollmentStatus;
  final String? studentId;
  final String? fullName;
  final String? strand;
  final String? track;
  final String? gradeLevel;
  final String? semester;
  final List<String> sections;
  final List<Map<String, dynamic>> subjects;
  final bool isFinalized;
  final String? selectedSection;
  final Function(String?)? onSectionChanged;
  final VoidCallback? onLoadSubjects;
  final VoidCallback? onFinalize;

  const EnrollmentStatusWidget({
    Key? key,
    required this.enrollmentStatus,
    required this.studentId,
    required this.fullName,
    required this.strand,
    required this.track,
    required this.gradeLevel,
    required this.semester,
    required this.sections,
    required this.subjects,
    required this.isFinalized,
    required this.selectedSection,
    this.onSectionChanged,
    this.onLoadSubjects,
    this.onFinalize,
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
    final double imageSize = isMobile ? screenWidth / 3 : (isTablet ? screenWidth / 4 : screenWidth / 5);
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
              crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
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
                  const CircularProgressIndicator()
                else if (enrollmentStatus == 'reEnrollSubmitted')
                  _buildReEnrollSubmittedContent(imageSize, textFontSize)
                else if (enrollmentStatus == 'approved')
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
              TextSpan(text: 'currently under review', style: TextStyle(color: Colors.yellow)),
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

  Widget _buildApprovedContent(BuildContext context, double textFontSize) {
    return Column(
      children: [
        _buildStudentDataRow('Student ID no:', studentId, textFontSize),
        _buildStudentDataRow('Student Full Name:', fullName, textFontSize),
        _buildStudentDataRow('Strand:', strand, textFontSize),
        _buildStudentDataRow('Track:', track, textFontSize),
        _buildStudentDataRow('Grade Level:', gradeLevel, textFontSize),
        _buildStudentDataRow('Semester:', semester, textFontSize),
        _buildSectionDropdown(),
        if (!isFinalized)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: onLoadSubjects,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 1, 93, 168),
                backgroundColor: Colors.white,
              ),
              child: const Text('Load Section'),
            ),
          ),
        const SizedBox(height: 20),
        _buildSubjectsTable(),
        _buildFinalizeButton(),
      ],
    );
  }

  Widget _buildStudentDataRow(String label, String? value, double textFontSize) {
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

  Widget _buildSubjectsTable() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Table(
        border: TableBorder.all(color: Colors.black),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(4),
          2: FlexColumnWidth(2),
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
          child: Text(subject['subject_code'], style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(subject['subject_name'], style: const TextStyle(color: Colors.white)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(subject['category'] ?? 'N/A', style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  TableRow _buildPlaceholderRow() {
    return const TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('No subjects available', style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic)),
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
        foregroundColor: const Color.fromARGB(255, 1, 93, 168),
        backgroundColor: Colors.white,
      ),
      child: const Text('Finalize'),
    );
  }
}
