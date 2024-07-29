import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pbma_portal/pages/SignIn_View/SignInMobileView.dart';
import 'package:pbma_portal/pages/enrollment_form.dart';

class MobileView extends StatefulWidget {
  const MobileView({super.key});

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
  Color _textColor4 = Colors.white;
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color.fromARGB(255, 1, 93, 168);

  final sectionKey1 = GlobalKey();
  final sectionKey2 = GlobalKey();
  final sectionKey3 = GlobalKey();

  bool _showSignInCard = false;

  void scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(key.currentContext!,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 1, 93, 168),
              ),
              child: Text(
                'PBMA Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                scrollToSection(sectionKey1);
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About us'),
              onTap: () {
                Navigator.pop(context);
                scrollToSection(sectionKey2);
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail),
              title: Text('Contact us'),
              onTap: () {
                Navigator.pop(context);
                scrollToSection(sectionKey3);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(150, 1, 93, 168),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                "assets/pbma.jpg",
                height: screenWidth / 13,
                width: screenWidth / 13,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "PBMA",
          style: TextStyle(
            color: Colors.white,
            fontFamily: "B",
            fontSize: screenWidth / 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _textColor4 = Colors.yellow;
              });
            },
            onExit: (_) {
              setState(() {
                _textColor4 = Colors.white;
              });
            },
            child: GestureDetector(
              onTap: toggleSignInCard,
              child: Row(
                children: [
                  Icon(Icons.login_outlined, size: screenWidth / 35, color: _textColor4),
                  Text(
                    "Sign In",
                    style: TextStyle(
                      fontFamily: "SB",
                      fontSize: screenWidth / 35,
                      color: _textColor4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [ SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
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
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                    color: Color.fromARGB(150, 1, 93, 168), // Semi-transparent blue tint
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenWidth / 5),
                      Container(
                        width: 800,
                        padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Prime Brilliant\nMinds Academy",
                              style: TextStyle(
                                  fontFamily: "B",
                                  fontSize: screenWidth / 13,
                                  color: Colors.white),
                            ),
                            SizedBox(height: 30),
                            Text(
                              "This will be the introductory line of the prime brilliant minds academy whether they want to write the mission or vision or the encouragement sentence.",
                              textAlign: TextAlign.justify,
                              style: TextStyle(
                                fontFamily: "L",
                                fontSize: screenWidth / 35,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 30),
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
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => EnrollmentForm()));
                                },
                                child: Container(
                                  height: 50,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      color: _textColor5,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                    child: Text(
                                      "Enroll Now",
                                      style: TextStyle(
                                          color: _textColor6,
                                          fontFamily: "B",
                                          fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 70,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 90,
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      width: MediaQuery.of(context).size.width,
                      color: const Color.fromARGB(122, 158, 158, 158),
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
                          SizedBox(height: 10),
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
                                  child: Icon(Icons.person, size: 20, color: Colors.black),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "LIGAYA C. TACBI,",
                                style: TextStyle(
                                    fontFamily: "B",
                                    fontSize: (screenWidth / 85) + 2,
                                    color: Colors.white),
                              ),
                              SizedBox(width: 10),
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
                color: Colors.white30,
                child: Column(
                  children: [],
                ),
              ),
              Container(
                key: sectionKey3,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.yellow,
              ),
            ],
          ),
        ),
        if (_showSignInCard)
            GestureDetector(
              onTap: () { closeSignInCard(); },
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: GestureDetector(
                      onTap: (){},
                      child: Container(
                        padding: EdgeInsets.all(20),
                        width: screenWidth / 1,
                        height: screenHeight / 1.1,
                        child: SignInMobile(closeSignInCardCallback: closeSignInCard,),
                      ),
                    ),
                  ),
                ),
                ),
              ),
        ],
      ),
    );
  }
}