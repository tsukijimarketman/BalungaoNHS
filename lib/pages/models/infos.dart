import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Info {
  String title;
  String description;
  IconData iconData;

  Info(
      {required this.title, required this.description, required this.iconData});
}

List<Info> infos = [
  Info(
      title: "Maka-Diyos",
      description: "We prioritize producing students who are God-fearing, nurturing a strong sense of faith, spirituality, and moral responsibility in all aspects of life.",
      iconData: Icons.church),
  Info(
      title: "Maka-tao",
      description: "We aim to develop students who are environmentally conscious, promoting a deep respect for nature and a commitment to sustainable living.",
      iconData: Icons.people_alt),
  Info(
      title: "Maka-kalikasan",
      description: "We aim to develop students who are environmentally conscious, promoting a deep respect for nature and a commitment to sustainable living.",
      iconData: Icons.nature_people),
  Info(
      title: "Maka-bansa",
      description: "We strive to create students who are passionate about their country, fostering a sense of patriotism and a strong commitment to contributing to the nation's progress.",
      iconData: Icons.flag),
];
