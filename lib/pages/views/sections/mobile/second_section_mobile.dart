import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/models/infos.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/mission_vision_mobile.dart';
import 'package:balungao_nhs/widgets/info_card%20mobile.dart';
import 'package:balungao_nhs/widgets/info_card.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/mission_vision.dart';

class SecondSectionMobile extends StatelessWidget {
  const SecondSectionMobile({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(255, 1, 93, 168), Colors.white],
          stops: [0.1, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Text(
              "Why Prime Brilliant Minds Academy?",
              style: TextStyle(
                fontSize: screenWidth / 15,
                fontFamily: "B",
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Text(
              "PBMA offers Senior High School program as well as different TESDA Courses and is now an accredited assessment center. A wide array of courses to choose from depending on your preferred skill and craft.",
              style: TextStyle(
                fontFamily: "R",
                fontSize: screenWidth / 30,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgramCard(
                  context,
                  imagePath: "assets/primeshs.jpg",
                  title: "Senior High School Program",
                  description: "PBMA offers various track and strands",
                ),
                SizedBox(height: screenWidth/45),
                _buildProgramCard(
                  context,
                  imagePath: "assets/primetesda.jpg",
                  title: "TESDA Program",
                  description: "PBMA offers different courses and NC's",
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Text(
              "Core Values",
              style: TextStyle(
                fontSize: screenWidth / 15,
                fontFamily: "B",
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: infos.map((info) => InfoCardMobile(info: info)).toList(),
          ),
          const SizedBox(height: 50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: const MissionAndVisionMobile(),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context,
      {required String imagePath, required String title, required String description}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth - (screenWidth / 17 * 2), // Adjust for the horizontal padding
      height: MediaQuery.of(context).size.width/2, // Set a fixed height
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: const Color.fromARGB(255, 255, 231, 11).withOpacity(0.4),
            ),
          ),
          Positioned(
            bottom: 50, // Adjust for padding within the card
            left: 10, // Adjust for padding within the card
            child: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth / 20,
                fontFamily: "BL",
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 30, // Adjust for padding within the card
            left: 10, // Adjust for padding within the card
            child: Text(
              description,
              style: TextStyle(
                fontFamily: "M",
                fontSize: screenWidth / 30,
              ),
            ),
          ),
          Positioned(
            right: 10, // Adjust for padding within the card
            bottom: 10, // Adjust for padding within the card
            child: Text(
              "See Program",
              style: TextStyle(
                fontSize: screenWidth / 35,
                fontFamily: "B",
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
