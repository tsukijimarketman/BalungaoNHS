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
      title: "Mastery",
      description: "We strive for excellence in academics, skills, and character, ensuring every student reaches their full potential through continuous learning and improvement.",
      iconData: Icons.work_history_sharp),
  Info(
      title: "Nurturing",
      description: "We provide a caring and inclusive environment that fosters respect, empathy, and personal growth for all members of our school community.",
      iconData: Icons.diversity_3_outlined),
  Info(
      title: "Honor",
      description: "We uphold integrity, accountability, and ethical behavior, inspiring students to lead with honesty and dignity in all endeavors",
      iconData: Icons.verified_user),
  Info(
      title: "Service",
      description: "We instill the value of service to others, encouraging students to contribute positively to society and be proactive in building better communities",
      iconData: Icons.self_improvement),
];
