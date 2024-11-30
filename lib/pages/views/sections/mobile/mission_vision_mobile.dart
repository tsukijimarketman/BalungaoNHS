import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MissionAndVisionMobile extends StatelessWidget {
  const MissionAndVisionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
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
                        fontSize: screenWidth / 25,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: screenWidth / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: AssetImage("assets/principal.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Urbano R. Delos Angeles IV,",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 30, 54),
                                        fontFamily: "B",
                                        fontSize: screenWidth / 60,
                                        backgroundColor: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      "School Principal",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 30, 54),
                                        fontFamily: "R",
                                        fontSize: screenWidth / 65,
                                        fontStyle: FontStyle.italic,
                                        backgroundColor: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: screenWidth / 2.5,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    image: AssetImage("assets/schooladmin.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Vannity Kaye S. Tan",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 30, 54),
                                        fontFamily: "B",
                                        fontSize: screenWidth / 60,
                                        backgroundColor: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      "School Administrator",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 30, 54),
                                        fontFamily: "R",
                                        fontSize: screenWidth / 65,
                                        fontStyle: FontStyle.italic,
                                        backgroundColor: Colors.white.withOpacity(0.5),
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
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  width: screenWidth / 2.5,
                  child: Column(
                    children: [
                      Center(
                        child: Icon(
                          Icons.remove_red_eye_outlined,
                          color: Color.fromARGB(255, 216, 194, 0),
                          size: screenWidth / 10,
                        ),
                      ),
                      Text(
                        "PBMA'S VISION",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 30, 54),
                          fontFamily: "B",
                          fontSize: screenWidth / 25,
                        ),
                      ),
                      SizedBox(height: screenWidth / 30),
                      Text(
                        "To become a premier learner-centered institution upholding excellence in education, inquiry, and training attuned with the needs of dynamic society towards the betterment of the quality of life.",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 30, 54),
                          fontFamily: "M",
                          fontSize: screenWidth / 40,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20,)
          ,                  Container(
                  width: screenWidth / 2.5,
                  child: Column(
                    children: [
                      Center(
                        child: Icon(
                          Icons.school,
                          color: Color.fromARGB(255, 216, 194, 0),
                          size: screenWidth / 10,
                        ),
                      ),
                      Text(
                        "PBMA'S MISSION",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 30, 54),
                          fontFamily: "B",
                          fontSize: screenWidth / 25,
                        ),
                      ),
                      SizedBox(height: screenWidth / 30),
                      Text(
                        "Achieving excellence by committing ourselves to be holistic, who devote in the pursuit of wisdom which flows from research, innovation and transformation while upholding principles of a morally upright individual.",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 30, 54),
                          fontFamily: "M",
                          fontSize: screenWidth / 40,
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
    );
  }
}
