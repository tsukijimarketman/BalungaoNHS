import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/SignIn_View/SignInDesktopView.dart';
import 'package:pbma_portal/pages/enrollment_form.dart';

class DesktopView extends StatefulWidget {
  const DesktopView({super.key});

  @override
  State<DesktopView> createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  Color _appBarColor = Colors.transparent;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(begin: 920, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 0) {
      setState(() {
        _appBarColor = Colors.teal;
      });
    } else {
      setState(() {
        _appBarColor = Colors.transparent;
      });
    }
  }

  Color _textColor1 = Colors.white;
  Color _textColor2 = Colors.white;
  Color _textColor3 = Colors.white;
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color.fromARGB(255, 1, 93, 168);

  final sectionKey1 = GlobalKey();
  final sectionKey2 = GlobalKey();
  final sectionKey3 = GlobalKey();

  bool _showSignInCard = false;

  void scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut
    );
  }

   void toggleSignInCard() {
    setState(() {
      _showSignInCard = !_showSignInCard;
    });
  }

  void closeSignInCard() {
    setState(() {
      _showSignInCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Stack(
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _animation.value),
                          child: Container(
                            key: sectionKey1,
                            height: screenHeight,
                            width: screenWidth,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/campus.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
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
                            Color.fromARGB(87, 1, 93, 168), // Semi-transparent blue
                            Color.fromARGB(255, 1, 93, 168), // Fully opaque blue
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
                              left: screenWidth / 17,
                              right: screenWidth / 17,
                              top: 10),
                          height: screenHeight / 9,
                          width: screenWidth,
                        ),
                        SizedBox(
                          height: screenHeight / 6,
                        ),
                        Container(
                          width: 1000,
                          padding:
                              EdgeInsets.symmetric(horizontal: screenWidth / 17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Prime Brilliant Minds Academy",
                                style: TextStyle(
                                    fontFamily: "B",
                                    fontSize: screenHeight / 15,
                                    color: Colors.white),
                              ),
                              Text(
                                "TESDA Accredited Training and Assessment Center",
                                style: TextStyle(
                                    fontFamily: "SB",
                                    fontSize: screenHeight / 27,
                                    color: Colors.white),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Be a Dreamer, Achieve Greater, and be a PRIMER",
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                  fontFamily: "L",
                                  fontSize: screenHeight / 30,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(
                                height: 30,
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
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EnrollmentForm()));
                                  },
                                  child: Container(
                                    height: 50,
                                    width: 200,
                                    decoration: BoxDecoration(
                                        color: _textColor5,
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(
                                      "Get Started",
                                      style: TextStyle(
                                          color: _textColor6,
                                          fontFamily: "B",
                                          fontSize: 20),
                                    )),
                                  ),
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
                                    child: Icon(Icons.person,
                                        size: 20, color: Colors.black),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "LIGAYA C. TACBI,",
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
                                  "Ph.D (School Principal)",
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
                    ),
                  ],
                ),
                Container(
                  key: sectionKey2,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromARGB(255, 1, 93, 168),
                  child: Column(
                    children: [
                      Text("Mission"),
                    ],
                  ),
                ),
                Container(
                  key: sectionKey3,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Color.fromARGB(255, 1, 93, 168),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              toolbarHeight: screenWidth / 16,
              elevation: 8,
              backgroundColor: _appBarColor,
              title: Container(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _controller.reverse();
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/pbma.jpg",
                          height: screenWidth / 20,
                          width: screenWidth / 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "PBMA",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "B",
                        fontSize: screenWidth / 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Spacer(),
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _textColor1 = Colors.yellow;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _textColor1 = Colors.white;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Services",
                          style: TextStyle(
                            fontFamily: "SB",
                            fontSize: 14,
                            color: _textColor1,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _textColor2 = Colors.yellow;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _textColor2 = Colors.white;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          "About us",
                          style: TextStyle(
                            fontFamily: "SB",
                            fontSize: 14,
                            color: _textColor2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    MouseRegion(
                      onEnter: (_) {
                        setState(() {
                          _textColor3 = Colors.yellow;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _textColor3 = Colors.white;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {},
                        child: Text(
                          "Contact uss",
                          style: TextStyle(
                            fontFamily: "SB",
                            fontSize: 14,
                            color: _textColor3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    SizedBox(
                      width: screenWidth / 12,
                      height: screenWidth / 35,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              Colors.yellow),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignInDesktop(closeSignInCardCallback: () {  },)));
                        },
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontFamily: "B",
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 25),
                    SizedBox(
                      width: screenWidth / 12,
                      height: screenWidth / 35,
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EnrollmentForm()));
                        },
                        child: Text(
                          "Enroll Now",
                          style: TextStyle(
                            fontFamily: "B",
                            fontSize: 14,
                            color: Color.fromARGB(255, 1, 93, 168),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
