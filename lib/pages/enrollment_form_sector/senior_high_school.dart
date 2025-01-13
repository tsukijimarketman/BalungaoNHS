import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SeniorHighSchool extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final double spacing;

  SeniorHighSchool({
    required this.spacing,
    required this.onDataChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<SeniorHighSchool> createState() => SeniorHighSchoolState();
}

class SeniorHighSchoolState extends State<SeniorHighSchool>
    with AutomaticKeepAliveClientMixin {
  String _selectedGradeLevel = '';
  String _selectedTrack = '';
  String _selectedStrand = '';
  String _selectedTransferee = '';
  String _selectedSemester = '';

  void resetFields() {
    setState(() {
      _selectedGradeLevel = '';
      _selectedTrack = '';
      _selectedStrand = '';
      _selectedTransferee = '';
      _selectedSemester = '';
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _notifyParent() {
    widget.onDataChanged(getFormData());
  }

  Map<String, dynamic> getFormData() {
    return {
      'grade_level': _selectedGradeLevel,
      'seniorHigh_Track': _selectedTrack,
      'seniorHigh_Strand': _selectedStrand,
      'transferee': _selectedTransferee,
      'semester': 'Grade $_selectedGradeLevel - $_selectedSemester',
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double fieldWidth = screenWidth >= 1200
        ? 300
        : screenWidth >= 800
            ? 250
            : screenWidth * 0.8;
    double spacing = screenWidth >= 800 ? 16.0 : 8.0;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Senior High School (SHS)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Grade Level, Track or Strand of your choice below',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              Container(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value: _selectedGradeLevel.isEmpty ? null : _selectedGradeLevel,
                  decoration: InputDecoration(
                    labelText: 'Grade Level',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 101, 100, 100),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                  ),
                  items: ['11', '12']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGradeLevel = value!;
                      _notifyParent();
                    });
                  },
                ),
              ),
              Container(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value:
                      _selectedTransferee.isEmpty ? null : _selectedTransferee,
                  decoration: InputDecoration(
                    labelText: 'Are you a transferee?',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                  ),
                  items: ['yes', 'no']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTransferee = value!;
                      _notifyParent();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              Container(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value: _selectedTrack.isEmpty ? null : _selectedTrack,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select a Track',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                  ),
                  items: [
                    'Academic Track',
                    'Technical-Vocational-Livelihood (TVL)'
                  ].map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTrack = value!;
                      _selectedStrand = '';
                      _notifyParent();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              Container(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value: _selectedStrand.isEmpty ? null : _selectedStrand,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Select a Strand',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                  ),
                  items: _getStrandItems(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStrand = value!;
                      _notifyParent();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              Container(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value: _selectedSemester.isEmpty ? null : _selectedSemester,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Please select Semester',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Color(0xFF03b97c), width: 1.0),
                    ),
                  ),
                  items: ['1st Semester', '2nd Semester']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value!;
                      _notifyParent();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getStrandItems() {
    if (_selectedTrack == 'Academic Track') {
      return [
        'Accountancy, Business, and Management (ABM)',
        'Science, Technology, Engineering and Mathematics (STEM)',
        'Humanities and Social Sciences (HUMSS)',
      ].map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          )).toList();
    } else if (_selectedTrack == 'Technical-Vocational-Livelihood (TVL)') {
      return [
        'Home Economics (HE)',
        'Information and Communication Technology (ICT)',
        'Industrial Arts (IA)'
      ].map((String value) => DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          )).toList();
    }
    return [];
  }
}
