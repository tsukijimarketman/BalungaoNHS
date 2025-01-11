import 'package:flutter/material.dart';

class JuniorHighSchoolEnrollment extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final double spacing;

  JuniorHighSchoolEnrollment({
    required this.spacing,
    required this.onDataChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<JuniorHighSchoolEnrollment> createState() =>
      JuniorHighSchoolEnrollmentState();
}

class JuniorHighSchoolEnrollmentState extends State<JuniorHighSchoolEnrollment>
    with AutomaticKeepAliveClientMixin {
  String? _selectedGradeLevel; // Change to nullable
  String? _selectedTransferee; // Change to nullable

  void resetFields() {
    setState(() {
      _selectedGradeLevel = null; // Reset to null
      _selectedTransferee = null; // Reset to null
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  void _notifyParent() {
    widget.onDataChanged(getFormData());
  }

  Map<String, dynamic> getFormData() {
    return {
      'grade_level': _selectedGradeLevel,
      'transferee': _selectedTransferee,
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
            'Junior High School (JHS)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Grade Level of your choice below',
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
                  value: _selectedGradeLevel, // Allow null
                  decoration: InputDecoration(
                    labelText: 'Grade Level',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(255, 101, 100, 100),
                      fontSize: 16,
                    ),
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
                  items: ['7', '8', '9', '10']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGradeLevel = value;
                      _notifyParent();
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your grade level';
                    }
                    return null;
                  },
                ),
              ),
              Container(
                width: fieldWidth,
                child: DropdownButtonFormField<String>(
                  value: _selectedTransferee, // Allow null
                  decoration: InputDecoration(
                    labelText: 'Are you a transferee?',
                    labelStyle:
                        TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
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
                  items: ['yes', 'no']
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTransferee = value;
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
}
