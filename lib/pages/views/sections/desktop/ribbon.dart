import 'package:flutter/material.dart';
import 'package:balungao_nhs/widgets/hover_extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Ribbon extends StatefulWidget {
  const Ribbon({super.key});

  @override
  State<Ribbon> createState() => _RibbonState();
}

class _RibbonState extends State<Ribbon> {
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color(0xFF002f24);

  void _launchEmail(String email) async {
    if (await canLaunchUrlString(email)) {
      await launchUrlString(email);
    } else {
      throw 'Could not launch email client';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF002f24),
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Do you have any concerns or inquiries? \t Get in touch with us.",
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width / 39,
                      color: Colors.white,
                      fontFamily: "BL"),
                ),
              ],
            ),
          ),
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _textColor5 = Colors.yellow;
                _textColor6 = Colors.black;
              });
            },
            onExit: (_) {
              setState(() {
                _textColor5 = Color(0xFFa1f9d0);
                _textColor6 = Color(0xFF002f24);
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.width / 23,
              width: MediaQuery.of(context).size.width/6,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(_textColor5),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
                onPressed: () {
                  _launchEmail(
                      "mailto:300281@deped.gov.ph?subject=Concerns&body=My concern is about?");
                },
                child: Center(
                    child: Text(
                  "Contact us",
                  style: TextStyle(
                      color: _textColor6, fontFamily: "B", fontSize: MediaQuery.of(context).size.width/60),
                )),
              ),
            ).moveUpOnHover,
          )
        ],
      ),
    );
  }
}
