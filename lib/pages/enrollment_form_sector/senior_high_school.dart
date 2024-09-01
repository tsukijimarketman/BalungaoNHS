import 'package:flutter/material.dart';

class SeniorHighSchool extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final double spacing;

  SeniorHighSchool({required this.spacing, required this.onDataChanged});

  @override
  State<SeniorHighSchool> createState() => _SeniorHighSchoolState();
}

class _SeniorHighSchoolState extends State<SeniorHighSchool> with AutomaticKeepAliveClientMixin {
  final FocusNode _gradeLevelFocusNode = FocusNode();

  final TextEditingController _gradeLevel = TextEditingController();
  String _selectedTrack = '';
  String _selectedStrand = '';

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
      void dispose() {
        _gradeLevel.dispose();
        _gradeLevelFocusNode.dispose();
        super.dispose();
    }

  @override
  bool get wantKeepAlive => true;

  void _notifyParent() {
    widget.onDataChanged(getFormData());
  }

  Map<String, dynamic> getFormData() {
    return {
      'grade_level': _gradeLevel.text,
      'seniorHigh_Track': _selectedTrack,
      'seniorHigh_Strand': _selectedStrand,
    };
  }
  

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                'Senior High School (SHS)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                'Grade Level, Track or Strand of your choice below',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 300,
                child: TextFormField(
                  controller: _gradeLevel,
                  focusNode: _gradeLevelFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Grade Level',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_gradeLevelFocusNode.hasFocus || _gradeLevel.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,                             ),
                            ),
                        ],
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    ),
                  ),
                  onChanged: (text) {
                      setState(() {});
                    },
                ),
              ),
            ]
          )
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  width: 500,
                  child: DropdownButtonFormField<String>(
                    value: _selectedTrack.isEmpty ? null : _selectedTrack,
                    decoration: InputDecoration(
                      labelText: 'Select a Track you choose',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    items: [
                      'Academic Track',
                      'Technical-Vocational-Livelihood (TVL)'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTrack = value ?? '';
                        _selectedStrand = '';
                        _notifyParent();
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: widget.spacing),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        width: 500,
                        child: DropdownButtonFormField<String>(
                          value: _selectedStrand.isEmpty ? null : _selectedStrand,
                          decoration: InputDecoration(
                            labelText: 'Select a Strand you choose',
                            labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              borderSide: BorderSide(color: Colors.blue, width: 2.0),
                            ),
                          ),
                          items: _getStrandItems(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStrand = value ?? '';
                        _notifyParent();
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ],
    );
  }
  
  List<DropdownMenuItem<String>> _getStrandItems() {
    if (_selectedTrack == 'Technical-Vocational-Livelihood (TVL)') {
      return [
        'Home Economics (HE)',
        'Information and Communication Technology (ICT)',
        'Industrial Arts (IA)'
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else if (_selectedTrack == 'Academic Track') {
      return [
        'Accountancy, Business, and Management (ABM)',
        'Science, Technology, Engineering and Mathematics (STEM)',
        'Humanities and Social Sciences (HUMSS)',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList();
    } else {
      return [];
    }
  }
}