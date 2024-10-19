import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/views/sections/desktop/contact_us.dart';
import 'package:pbma_portal/pages/views/sections/desktop/ribbon.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Ribbon(),
              ContactUs()
            ],
          ),
    );
  }
}
