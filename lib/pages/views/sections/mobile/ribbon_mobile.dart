import 'package:flutter/material.dart';
import 'package:balungao_nhs/widgets/hover_extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RibbonMobile extends StatefulWidget {
  const RibbonMobile({super.key});

  @override
  State<RibbonMobile> createState() => _RibbonMobileState();
}

class _RibbonMobileState extends State<RibbonMobile> {
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color.fromARGB(255, 1, 93, 168);

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
      color: Color.fromARGB(255, 0, 30, 54),
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/15, vertical:MediaQuery.of(context).size.width/15),
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
                      fontSize: MediaQuery.of(context).size.width / 35,
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
                _textColor5 = Colors.white;
                _textColor6 = Color.fromARGB(255, 1, 93, 168);
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.width / 15,
              width: MediaQuery.of(context).size.width/5,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(_textColor5),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
                onPressed: () {
                  _launchEmail(
                      "mailto:pbmindsacademy@gmail.com?subject=Concerns&body=My concern is about?");
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
