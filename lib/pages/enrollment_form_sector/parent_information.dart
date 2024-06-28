import 'package:flutter/material.dart';

class ParentInformation extends StatelessWidget {
  final double spacing;

  ParentInformation({required this.spacing});

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
                  child: Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Father's Name",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter father\'s name';
                        }
                        return null;
                      },
                    ),
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
                  child: Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Mother's Name",
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter mother\'s name';
                        }
                        return null;
                      },
                    ),
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
                  child: Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Guardian's Name",
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
                    ),
                  ),
                ),
              ),
              SizedBox(width: spacing),
              Flexible(
                child: Container(
                  width: 300,
                  child: Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Relationship to Guardian',
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
                    ),
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
