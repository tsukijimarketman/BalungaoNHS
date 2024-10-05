import 'package:flutter/material.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';

class Ribbon extends StatefulWidget {
  const Ribbon({super.key});

  @override
  State<Ribbon> createState() => _RibbonState();
}

class _RibbonState extends State<Ribbon> {
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color.fromARGB(255, 1, 93, 168);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: Color.fromARGB(255, 0, 30, 54),
      padding: EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Do you have any concerns or inquiries? \t Get in touch with us.",
                  style: TextStyle(
                      fontSize: 35, color: Colors.white, fontFamily: "BL"),
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
              height: 60,
              width: 210,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(_textColor5),
                    shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
                onPressed: () {},
                child: Center(
                    child: Text(
                  "Contact us",
                  style: TextStyle(
                      color: _textColor6, fontFamily: "B", fontSize: 20),
                )),
              ),
            ).moveUpOnHover,
          )
        ],
      ),
    );
  }
}
