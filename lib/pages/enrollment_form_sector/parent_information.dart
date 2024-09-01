import 'package:flutter/material.dart';

class ParentInformation extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final double spacing;

  ParentInformation({required this.spacing, required this.onDataChanged});

  @override
  State<ParentInformation> createState() => _ParentInformationState();
}

class _ParentInformationState extends State<ParentInformation> with AutomaticKeepAliveClientMixin{
  final FocusNode fathersNameFocusNode = FocusNode();
  final FocusNode mothersNameFocusNode = FocusNode();
  final FocusNode guardianNameFocusNode = FocusNode();
  final FocusNode guardianFocusNode = FocusNode();

  final TextEditingController _fathersName = TextEditingController();
  final TextEditingController _mothersName = TextEditingController();
  final TextEditingController _guardianName = TextEditingController();
  final TextEditingController _relationshipGuardian = TextEditingController();
   
  @override
  void initState() {
    super.initState();
    _fathersName.addListener(_notifyParent);
    _mothersName.addListener(_notifyParent);
    _guardianName.addListener(_notifyParent);
    _relationshipGuardian.addListener(_notifyParent);

    fathersNameFocusNode.addListener(_onFocusChange);
    mothersNameFocusNode.addListener(_onFocusChange);
    guardianNameFocusNode.addListener(_onFocusChange);
    guardianFocusNode.addListener(_onFocusChange);
  }

  @override
      void dispose() {
        _fathersName.dispose();
        fathersNameFocusNode.dispose();
        _mothersName.dispose();
        mothersNameFocusNode.dispose();
        _guardianName.dispose();
        guardianNameFocusNode.dispose();
        _relationshipGuardian.dispose();
        guardianFocusNode.dispose();
        super.dispose();
    }

    @override
    bool get wantKeepAlive => true;

    void _onFocusChange() {
    setState(() {});
    }

  void _notifyParent() {
    widget.onDataChanged(getFormData());
  }

   Map<String, dynamic> getFormData() {
    return {
      'fathersName': _fathersName.text,
      'mothersName': _mothersName.text,
      'guardianName': _guardianName.text,
      'relationshipGuardian': _relationshipGuardian.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Parent\'s Guardian Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  width: 300,
                  child: TextFormField(
                    controller: _fathersName,
                    focusNode: fathersNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: "Father's Name",
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (fathersNameFocusNode.hasFocus || _fathersName.text.isNotEmpty)
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter father\'s name';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Flexible(
                child: Container(
                  width: 300,
                  child: TextFormField(
                    controller: _mothersName,
                    focusNode: mothersNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: "Mother's Name",
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (mothersNameFocusNode.hasFocus || _mothersName.text.isNotEmpty)
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mother\'s name';
                      }
                      return null;
                    },
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
                  width: 300,
                  child: TextFormField(
                    controller: _guardianName,
                    focusNode: guardianNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: "Guardian's Name",
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (guardianNameFocusNode.hasFocus || _guardianName.text.isNotEmpty)
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter guardian name';
                      }
                      return null;
                    },
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(width: widget.spacing),
              Flexible(
                child: Container(
                  width: 300,
                  child: TextFormField(
                    controller: _relationshipGuardian,
                    focusNode: guardianFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Relationship to Guardian',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (guardianFocusNode.hasFocus || _relationshipGuardian.text.isNotEmpty)
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter relationship to guardian';
                      }
                      return null;
                    },
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
