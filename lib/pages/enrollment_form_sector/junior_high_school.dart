import 'package:flutter/material.dart';

class JuniorHighSchool extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;

  JuniorHighSchool({required this.onDataChanged});

  @override
  State<JuniorHighSchool> createState() => _JuniorHighSchoolState();
}

class _JuniorHighSchoolState extends State<JuniorHighSchool> {
  final FocusNode _juniorHSFocusNode = FocusNode();
  final FocusNode _schoolAddFocusNode = FocusNode();


  final TextEditingController _juniorHS = TextEditingController();
  final TextEditingController _schoolAdd = TextEditingController();

  @override
  void initState() {
    super.initState();
    _juniorHS.addListener(_notifyParent);
    _schoolAdd.addListener(_notifyParent);

    _juniorHSFocusNode.addListener(_onFocusChange);
    _schoolAddFocusNode.addListener(_onFocusChange);
    
  }
   @override
      void dispose() {
        _juniorHS.dispose();
        _juniorHSFocusNode.dispose();
        _schoolAdd.dispose();
        _schoolAddFocusNode.dispose();

        super.dispose();
    }

    void _onFocusChange() {
    setState(() {});
    }

   void _notifyParent() {
    widget.onDataChanged(getFormData());
  }

   Map<String, dynamic> getFormData() {
    return {
      'juniorHS': _juniorHS.text,
      'schoolAdd': _schoolAdd.text,
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
                'Junior High School (JHS)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                'Indicate where student completed fourth year high school/Grade 10. Fill in only APPLICABLE',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  width: 500,
                  child: TextFormField(
                    controller: _juniorHS,
                    focusNode: _juniorHSFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'JHS Name (do not abbreviate)',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_juniorHSFocusNode.hasFocus || _juniorHS.text.isNotEmpty)
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
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  width: 500,
                  child: TextFormField(
                    controller: _schoolAdd,
                    focusNode: _schoolAddFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'School Address',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_schoolAddFocusNode.hasFocus || _schoolAdd.text.isNotEmpty)
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
