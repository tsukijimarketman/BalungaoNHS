import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pbma_portal/pages/SignInScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Color _textColor1 = Colors.white;
  Color _textColor2 = Colors.white;
  Color _textColor3 = Colors.white;
  Color _textColor4 = Colors.white;
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color.fromARGB(255, 1, 93, 168);
  // Default text color

  final sectionKey1 = new GlobalKey();
  final sectionKey2 = new GlobalKey();
  final sectionKey3 = new GlobalKey();

  void scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  key: sectionKey1,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
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
                  color: Color.fromARGB(
                      150, 1, 93, 168), // Semi-transparent blue tint
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      color: Colors.transparent,
                      padding: EdgeInsets.only(
                          left: 80, right: 80, top: 10, bottom: 5),
                      height: 80,
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.asset(
                              "assets/pbma.jpg",
                              height: 50,
                              width: 50,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "PBMA",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "B",
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 60),
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
                              onTap: () {
                                scrollToSection(sectionKey1);
                              },
                              child: Text(
                                "Dashboard",
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
                              onTap: () {
                                scrollToSection(sectionKey2);
                              },
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
                              onTap: () {
                                scrollToSection(sectionKey3);
                              },
                              child: Text(
                                "Contact us",
                                style: TextStyle(
                                  fontFamily: "SB",
                                  fontSize: 14,
                                  color: _textColor3,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
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
                              onTap: () {},
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.login_outlined,
                                        color: _textColor4),
                                    SizedBox(width: 5),
                                    TextButton(onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
                                    }, 
                                    child: Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontFamily: "SB",
                                        fontSize: 14,
                                        color: _textColor4,
                                      ),
                                    ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Divider(color: Color.fromARGB(83, 158, 158, 158),),
                    SizedBox(
                      height: 80,
                    ),
                    Container(
                      width: 800,
                      padding: EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Prime Brilliant\nMinds Academy",
                            style: TextStyle(
                                fontFamily: "B",
                                fontSize: 50,
                                color: Colors.white),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            "This will be the introductory line of the prime brilliant minds academy whether they want to write the mission or vision or the encouragement sentence.",
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: "L",
                              fontSize: 20,
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
                              onTap: () {},
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
                    height: 120,
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
                            fontSize: 17,
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
                                  fontSize: 14,
                                  color: Colors.white),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Ph.D (School Principal)",
                              style: TextStyle(
                                  fontFamily: "M",
                                  fontSize: 14,
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
    );
  }
}
