import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color.fromARGB(132, 1, 93, 168),
          ),
    );
  }
}
