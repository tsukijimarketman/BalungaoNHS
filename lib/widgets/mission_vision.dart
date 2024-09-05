import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MissionAndVision extends StatefulWidget {
  const MissionAndVision({super.key});

  @override
  State<MissionAndVision> createState() => _MissionAndVisionState();
}

class _MissionAndVisionState extends State<MissionAndVision> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 600,
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                border:
                    Border(right: BorderSide(color: Color.fromARGB(255, 216, 194, 0), width: 4))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 20, right: 40),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 0, 30, 54)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Text(
                          "SENIOR HIGH SCHOOL",
                          style: TextStyle(
                            fontFamily: "R",
                            fontSize: 30,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 320,
                              width: 300,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 20,
                                    child: Container(
                                      height: 300,
                                      width: 300,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                "assets/principal1.jpg",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 75,
                                    left: 75,
                                    child: Container(
                                      height: 40,
                                      color: Color.fromARGB(255, 255, 230, 0)
                                          .withOpacity(0.6),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Container(
                              height: 320,
                              width: 300,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 20,
                                    child: Container(
                                      height: 300,
                                      width: 300,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                "assets/principal2.jpg",
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 75,
                                    left: 75,
                                    child: Container(
                                      height: 40,
                                      color: Color.fromARGB(255, 255, 230, 0)
                                          .withOpacity(0.6),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 40),
                  height: 50,
                  width: 640,
                  child: Row(
                    children: [
                      Container(
                        width: 320,
                        child: Column(
                          children: [
                            Text(
                              "Ligaya C. Tacbi",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 30, 54),
                                  fontFamily: "B",
                                  fontSize: 20),
                            ),
                            Text("School Principal",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 30, 54),
                                    fontFamily: "R",
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic))
                          ],
                        ),
                      ),
                      Container(
                        width: 320,
                        child: Column(
                          children: [
                            Text(
                              "Urbano R. Delos Angeles IV",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 30, 54),
                                  fontFamily: "B",
                                  fontSize: 20),
                            ),
                            Text("Assistant School Principal",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 0, 30, 54),
                                    fontFamily: "R",
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic))
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Placeholder for the second Column
          Expanded(
            child: Container(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom:20, top: 20),
                    
                    height: 560,
                    width: 450,
                    child: Column(
                      children: [
                        Center(
                            child: Icon(
                          Icons.remove_red_eye_outlined,
                          color: Color.fromARGB(255, 216, 194, 0),
                          size: 70,
                        )),
                        Text(
                          "PBMA'S VISION",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 30, 54),
                              fontFamily: "B",
                              fontSize: 25),
                        ),
                        Text(
                          "To become a premier learner-centered institution upholding excellence in education, inquiry, and training attuned with the needs of dynamic society towards the betterment of the quality of life.",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 30, 54),
                              fontFamily: "M",
                              fontSize: 20),
                        ),
                        SizedBox(height: 20,),
                        Center(
                            child: Icon(
                          Icons.school,
                          color: Color.fromARGB(255, 216, 194, 0),
                          size: 70,
                        )),
                        Text(
                          "PBMA'S MISION",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 30, 54),
                              fontFamily: "B",
                              fontSize: 25),
                        ),
                        Text(
                          "Achieving excellence by commiting ourselves to be holistic, who devote in the pursuit of wisdom which flows from research, innovation and transformation while upholding principles of a morally upright individual.",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 30, 54),
                              fontFamily: "M",
                              fontSize: 20),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
