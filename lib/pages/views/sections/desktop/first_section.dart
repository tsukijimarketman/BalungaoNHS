import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/widgets/hover_extensions.dart';
import 'package:balungao_nhs/widgets/text_reveal.dart';
import 'package:balungao_nhs/TermsAndConditions/TAC_Web_View.dart';

class FirstSection extends StatefulWidget {
  final Function onGetStartedPressed;
  const FirstSection({super.key, required this.onGetStartedPressed});

  @override
  State<FirstSection> createState() => _FirstSectionState();
}

class _FirstSectionState extends State<FirstSection>
    with TickerProviderStateMixin {
  late Animation<double> _quoteController;
  late AnimationController _textController;
  late AnimationController _textController2;
  late Animation<double> _textRevealAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _descriptionController;
  late Animation<double> _buttonController;

  Color _textColor5 = Color(0xFF002f24);
  Color _textColor6 = Colors.white;

  @override
  void initState() {
    _textController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 375),
    );
    _textController2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 375),
    );
    _textRevealAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _textController,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _textOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _textController,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _descriptionController = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(
          parent: _textController,
          curve: Interval(0.3, 1, curve: Curves.easeOut)),
    );
    _buttonController = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(
          parent: _textController,
          curve: Interval(0.0, 1, curve: Curves.easeOut)),
    );
    _quoteController = Tween<double>(begin: 0.0, end: 1).animate(
      CurvedAnimation(
          parent: _textController2,
          curve: Interval(0.0, 1, curve: Curves.easeOut)),
    );
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      _textController.forward();
    });
    Future.delayed(Duration(milliseconds: 4000), () {
      _textController2.forward();
    });
  }



  void toggleTAC() {
    widget.onGetStartedPressed();
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Stack(
      children: [
        Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mainDash.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(47, 3, 185, 124),
                Color(0xFF03b97c),
              ],
              stops: [0.5, 1.0],
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(
                  left: screenWidth / 17, right: screenWidth / 17, top: 10),
              height: screenHeight / 9,
              width: screenWidth,
            ),
            SizedBox(
              height: screenHeight / 7,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 30,
                  ),
                  TextReveal(
                      maxHeight: 90,
                      textController: _textController,
                      textOpacityAnimation: _textOpacityAnimation,
                      textRevealAnimation: _textRevealAnimation,
                      child: Text(
                        "Balungao National High School",
                        style: TextStyle(
                            fontFamily: "B",
                            fontSize: screenHeight / 12,
                            color: Colors.yellowAccent),
                      )),
                  
                  FadeTransition(
                    opacity: _descriptionController,
                    child: Text(
                      "If you can do it here, you can do it anywhere",
                      style: TextStyle(
                          fontFamily: "SB",
                          fontSize: screenHeight / 27,
                          color: Colors.yellowAccent),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        _textColor5 = Color(0xFF03b97c);
                        _textColor6 = Colors.white;
                      });
                    },  
                    onExit: (_) {
                      setState(() {
                        _textColor5 = Color(0xFF002f24);
                        _textColor6 = Colors.white;
                      });
                    },
                    child: FadeTransition(
                      opacity: _buttonController,
                      child: Container(
                        height: 60,
                        width: 230,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(_textColor5),
                              shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          onPressed: toggleTAC,
                          child: Center(
                              child: Text(
                            "Get Started",
                            style: TextStyle(
                                color: _textColor6,
                                fontFamily: "B",
                                fontSize: 25),
                          )),
                        ),
                      ).moveUpOnHover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: AnimatedBuilder(
            animation: _quoteController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _quoteController,
                child: Container(
                  height: 90,
                  padding: EdgeInsets.symmetric(horizontal: 80),
                  width: MediaQuery.of(context).size.width,
                  color: Color.fromARGB(25, 158, 158, 158),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '" Education is about igniting a passion for learning and nurturing responsibility, integrity, and compassion in every student. "',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: "SB",
                          fontSize: (screenWidth / 85) + 2,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    "assets/pholder.png",
                                    fit: BoxFit.fill,
                                  )),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "RACHEL T. PANDE,",
                            style: TextStyle(
                                fontFamily: "B",
                                fontSize: (screenWidth / 85) + 2,
                                color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          SizedBox(height: 30),
                          Text(
                            "(Principal IV)",
                            style: TextStyle(
                                fontFamily: "M",
                                fontSize: (screenWidth / 85) + 2,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
