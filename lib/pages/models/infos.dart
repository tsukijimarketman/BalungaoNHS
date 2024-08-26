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
      title: "Professionalism",
      description:
          "Professionalism at Prime Brilliant Minds Academy involves demonstrating responsibility, integrity, and dedication in every task. Preparing our students to uphold these values.",
      iconData: Icons.work_history_sharp),
  Info(
      title: "Respect",
      description:
          "At Prime Brilliant Minds Academy, Respect is a cornerstone of our culture. We prioritize valuing oneself, others, and our community, fostering empathy, understanding, and cooperation.",
      iconData: Icons.diversity_3_outlined),
  Info(
      title: "Integrity",
      description:
          "Integrity at Prime Brilliant Minds Academy means being honest, ethical, and accountable. We encourage our students to uphold strong moral principles in all their actions.",
      iconData: Icons.verified_user),
  Info(
      title: "Modesty",
      description:
          "Modesty is about humility and self-awareness. At Prime Brilliant Minds Academy, we teach students to value modesty, recognizing their strengths while remaining grounded.",
      iconData: Icons.self_improvement),
  Info(
      title: "Excellence",
      description:
          "Excellence is striving for the highest quality in all endeavors. At Prime Brilliant Minds Academy, we encourage our students to pursue excellence in their academic and personal lives.",
      iconData: Icons.star),
];
