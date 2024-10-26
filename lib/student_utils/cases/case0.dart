import 'package:flutter/material.dart';

class Case0 extends StatefulWidget {
  const Case0({super.key});

  @override
  State<Case0> createState() => _Case0State();
}

class _Case0State extends State<Case0> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 1, 93, 168),
      child: Center(
        child: Text("Home"),
      ),
    );
  }
}
