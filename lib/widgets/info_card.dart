import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/models/infos.dart';

class InfoCard extends StatefulWidget {
  final Info info;
  final double scrollOffset;
  const InfoCard({super.key, required this.info, required this.scrollOffset});

  @override
  State<InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  @override
  Widget build(BuildContext context) {
    String firstLetter = widget.info.title.substring(0, 1);
    String remainingText = widget.info.title.substring(1);

    return AnimatedCrossFade(
      crossFadeState: widget.scrollOffset >= 1530 ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: Duration(milliseconds: 575),
      reverseDuration: Duration(milliseconds: 375),
      alignment: Alignment.center,
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeOut,
      firstChild: Container(
        width: MediaQuery.of(context).size.width / 5.5,
        height: MediaQuery.of(context).size.height / 1.65,
        margin: EdgeInsets.symmetric(vertical: 25, horizontal: 5),
      ),
      secondChild: Container(
        margin: EdgeInsets.all(MediaQuery.of(context).size.width / 52),
        width: MediaQuery.of(context).size.width / 5.3,
        height: MediaQuery.of(context).size.height / 1.8,
        decoration: BoxDecoration(
            color: Color(0xFF002f24),
            borderRadius: BorderRadius.circular(15)),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.width/28,
                width: MediaQuery.of(context).size.width/28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.yellow,
                ),
                child: Icon(
                  widget.info.iconData,
                  color: Colors.black,
                  size: MediaQuery.of(context).size.width/50,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width/150,
              ),
              // Use RichText to color the first letter differently
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: firstLetter,
                      style: TextStyle(
                        fontFamily: "SB",
                        fontSize: MediaQuery.of(context).size.width/75,
                        color: Colors.yellow,
                      ),
                    ),
                    TextSpan(
                      text: remainingText,
                      style: TextStyle(
                        fontFamily: "SB",
                        fontSize: MediaQuery.of(context).size.width/75,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width/100,
              ),
              Text(
                widget.info.description,
                style: TextStyle(
                    fontFamily: "M", fontSize: MediaQuery.of(context).size.width/75, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}