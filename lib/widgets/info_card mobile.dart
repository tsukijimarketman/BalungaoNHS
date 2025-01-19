import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/models/infos.dart';

class InfoCardMobile extends StatelessWidget {
  final Info info;
  const InfoCardMobile({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    String firstLetter = info.title.substring(0, 1);
    String remainingText = info.title.substring(1);

    return Center(
      child: Container(
        margin: EdgeInsets.all(MediaQuery.of(context).size.width / 52),
        width: MediaQuery.of(context).size.width/1.15,
        height: MediaQuery.of(context).size.height / 2.4,
        decoration: BoxDecoration(
          color: Color(0xFF002f24),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.of(context).size.width / 10,
                width: MediaQuery.of(context).size.width / 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.yellow,
                ),
                child: Icon(
                  info.iconData,
                  color: Colors.black,
                  size: MediaQuery.of(context).size.width / 20,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width / 70,
              ),
              // Use RichText to color the first letter differently
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: firstLetter,
                      style: TextStyle(
                        fontFamily: "SB",
                        fontSize: MediaQuery.of(context).size.width / 20,
                        color: Colors.yellow,
                      ),
                    ),
                    TextSpan(
                      text: remainingText,
                      style: TextStyle(
                        fontFamily: "SB",
                        fontSize: MediaQuery.of(context).size.width / 25,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.width / 70,
              ),
              Text(
                info.description,
                style: TextStyle(
                  fontFamily: "M",
                  fontSize: MediaQuery.of(context).size.width / 30,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
