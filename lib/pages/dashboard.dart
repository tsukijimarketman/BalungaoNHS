import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final VideoPlayerController videoPlayerController =
      VideoPlayerController.asset("assets/vid.mp4");
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: 16 / 9,
      autoPlay: true,
    looping: true,
    autoInitialize: true,
    showControls: false);
  }

  @override
void dispose() {
  videoPlayerController.dispose();
  chewieController!.dispose();
  super.dispose();
}

  Color _textColor1 = Colors.white;
  Color _textColor2 = Colors.white;
  Color _textColor3 = Colors.white;
  Color _textColor4 = Colors.white;
  Color _textColor5 = Colors.white;
  Color _textColor6 = Color.fromARGB(255, 1, 93, 168);
  // Default text color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  color: const Color.fromARGB(255, 1, 93, 168),
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                            left: 80, right: 80, top: 10, bottom: 5),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                        ),
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
                                onTap: () {},
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
                                      Text(
                                        "Sign In",
                                        style: TextStyle(
                                          fontFamily: "SB",
                                          fontSize: 14,
                                          color: _textColor4,
                                        ),
                                      ),
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
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
