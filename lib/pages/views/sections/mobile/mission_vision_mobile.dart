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
                color: Color(0xFF002f24),
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
                                    image: AssetImage("assets/pholder.png"),
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
                                      "Rachel T. Pande",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 30, 54),
                                        fontFamily: "B",
                                        fontSize: screenWidth / 60,
                                        backgroundColor: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      "Principal IV",
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
                                    image: AssetImage("assets/pholder.png"),
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
                                      "Candido V. Pollante",
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 0, 30, 54),
                                        fontFamily: "B",
                                        fontSize: screenWidth / 60,
                                        backgroundColor: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                    Text(
                                      "ASST. School Principal II",
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
                        "BNHS VISION",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 30, 54),
                          fontFamily: "B",
                          fontSize: screenWidth / 25,
                        ),
                      ),
                      SizedBox(height: screenWidth / 30),
                      Text(
                        "The BNHS is envisioned to be a child friendly school through the provision of an excellent educational delivery system and the necessary school facilities towards quality education.",
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
                        "BNHS MISSION",
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 30, 54),
                          fontFamily: "B",
                          fontSize: screenWidth / 25,
                        ),
                      ),
                      SizedBox(height: screenWidth / 30),
                      Text(
                        "The school aims to ensure effective instructional delivery system through the expertise of highly -competent teaching staff and to provide essential school facilities towards the attainment of quality education for academic excellence.",
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
