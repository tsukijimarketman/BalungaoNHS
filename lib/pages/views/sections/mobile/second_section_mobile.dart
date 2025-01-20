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
          colors: [Color(0xFF03b97c), Colors.white],
          stops: [0.1, 1],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Text(
              "Why Balungao National High School?",
              style: TextStyle(
                fontSize: screenWidth / 15,
                fontFamily: "B",
                color: Colors.yellowAccent,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Text(
              "At Balungao National High School, we are committed to providing quality education, fostering holistic development, and empowering students to achieve academic excellence and personal growth in a nurturing and inclusive environment, with a wide array of strands to choose from that cater to every student's unique interests and career aspirations.",
              style: TextStyle(
                fontFamily: "R",
                fontSize: screenWidth / 30,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width/50),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgramCard(
                  context,
                  imagePath: "assets/primeshs.jpg",
                  title: "Junior High School Program",
                  description: "BNHS offers various special programs",
                ),
                SizedBox(height: screenWidth/45),
                _buildProgramCard(
                  context,
                  imagePath: "assets/primetesda.jpg",
                  title: "Senior High School Program",
                  description: "BNHS offers various track and strands",
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Text(
              "Core Values",
              style: TextStyle(
                fontSize: screenWidth / 15,
                fontFamily: "B",
                color: Color(0xFF002f24),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.width/50),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: infos.map((info) => InfoCardMobile(info: info)).toList(),
          ),
          SizedBox(height: MediaQuery.of(context).size.width/15),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: MissionAndVisionMobile(),
          ),
          SizedBox(height: MediaQuery.of(context).size.width/15),
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
        borderRadius:  BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width/50)),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width/50)),
              color: const Color(0xFF002f24).withOpacity(0.4),
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
                color: Colors.white,
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
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
