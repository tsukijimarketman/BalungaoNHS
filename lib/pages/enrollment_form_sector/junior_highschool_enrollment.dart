import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JuniorHighSchoolEnrollment extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final double spacing;
  
  JuniorHighSchoolEnrollment({
    required this.spacing,
    required this.onDataChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<JuniorHighSchoolEnrollment> createState() => JuniorHighSchoolEnrollmentState();
}

class JuniorHighSchoolEnrollmentState extends State<JuniorHighSchoolEnrollment>  with AutomaticKeepAliveClientMixin  {
  final FocusNode _gradeLevelFocusNode = FocusNode();
  final TextEditingController _gradeLevel = TextEditingController();
  String _selectedTransferee = '';

  void resetFields() {
    setState(() {
      _gradeLevel.clear();
      _selectedTransferee = '';
    });
  }

  @override
  void initState() {
    super.initState();
    _gradeLevel.addListener(_notifyParent);
    _gradeLevelFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {});
  }

      @override
    bool get wantKeepAlive => true;

  @override
  void dispose() {
    _gradeLevel.dispose();
    _gradeLevelFocusNode.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onDataChanged(getFormData());
  }

  Map<String, dynamic> getFormData() {
    return {
      'grade_level': _gradeLevel.text,
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
                child: TextFormField(
                  controller: _gradeLevel,
                  focusNode: _gradeLevelFocusNode,
                  decoration: InputDecoration(
                    label: RichText(
                      text: TextSpan(
                        text: 'Grade Level',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_gradeLevelFocusNode.hasFocus ||
                              _gradeLevel.text.isNotEmpty)
                            TextSpan(
                              text: '*',
                              style: TextStyle(color: Colors.red),
                            ),
                        ],
                      ),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your grade level';
                    }
                    return null;
                  },
                  onChanged: (text) {
                    setState(() {});
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                      _selectedTransferee = value!;
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
