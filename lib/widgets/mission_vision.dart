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
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: SizedBox(
        height: screenWidth / 2.27,
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              height: screenWidth / 2,
              width: screenWidth / 1.985,
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: Color.fromARGB(255, 216, 194, 0),
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 20, right: 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 0, 30, 54),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Text(
                            "SENIOR HIGH SCHOOL",
                            style: TextStyle(
                              fontFamily: "R",
                              fontSize: screenWidth / 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: screenWidth / 4.3,
                                  width: screenWidth / 4.53,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 20,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            height: screenWidth / 4.6,
                                            width: screenWidth / 4.6,
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
                                      Positioned(
                                        right: screenWidth / 20,
                                        left: screenWidth / 20,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              40,
                                          color:
                                              Color.fromARGB(255, 255, 230, 0)
                                                  .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Container(
                                  height: screenWidth / 4.3,
                                  width: screenWidth / 4.53,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 20,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            height: screenWidth / 4.6,
                                            width: screenWidth / 4.6,
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
                                      Positioned(
                                        right: screenWidth / 20,
                                        left: screenWidth / 20,
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              40,
                                          color:
                                              Color.fromARGB(255, 255, 230, 0)
                                                  .withOpacity(0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: screenWidth / 4.4,
                        child: Column(
                          children: [
                            Text(
                              "Ligaya C. Tacbi",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 30, 54),
                                fontFamily: "B",
                                fontSize: screenWidth / 68,
                              ),
                            ),
                            Text(
                              "School Principal",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 30, 54),
                                fontFamily: "R",
                                fontSize: screenWidth / 95,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: screenWidth / 80),
                      Container(
                        width: screenWidth / 4.4,
                        child: Column(
                          children: [
                            Text(
                              "Urbano R. Delos Angeles IV",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 30, 54),
                                fontFamily: "B",
                                fontSize: screenWidth / 68,
                              ),
                            ),
                            Text(
                              "Assistant School Principal",
                              style: TextStyle(
                                color: Color.fromARGB(255, 0, 30, 54),
                                fontFamily: "R",
                                fontSize: screenWidth / 95,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Color.fromARGB(255, 216, 194, 0),
                            size: screenWidth / 25,
                          ),
                        ),
                        Text(
                          "PBMA'S VISION",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 54),
                            fontFamily: "B",
                            fontSize: screenWidth / 55,
                          ),
                        ),
                        Text(
                          "To become a premier learner-centered institution upholding excellence in education, inquiry, and training attuned with the needs of dynamic society towards the betterment of the quality of life.",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 54),
                            fontFamily: "M",
                            fontSize: screenWidth / 70,
                          ),
                        ),
                        Center(
                          child: Icon(
                            Icons.school,
                            color: Color.fromARGB(255, 216, 194, 0),
                            size: screenWidth / 25,
                          ),
                        ),
                        Text(
                          "PBMA'S MISION",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 54),
                            fontFamily: "B",
                            fontSize: screenWidth / 55,
                          ),
                        ),
                        Text(
                          "Achieving excellence by committing ourselves to be holistic, who devote in the pursuit of wisdom which flows from research, innovation and transformation while upholding principles of a morally upright individual.",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 54),
                            fontFamily: "M",
                            fontSize: screenWidth / 68,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
