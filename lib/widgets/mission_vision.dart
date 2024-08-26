import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MissionAndVision extends StatefulWidget {
  const MissionAndVision({super.key});

  @override
  State<MissionAndVision> createState() => _MissionAndVisionState();
}

class _MissionAndVisionState extends State<MissionAndVision> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      child: Row(
        children: [
          Column(children: [
            Container(
              height: 560,
              margin: EdgeInsets.all(20),
              decoration: BoxDecoration(border: Border(right: BorderSide(color: Colors.yellow, width: 4))),
              child: Stack(
                children: [
                  Container(
                    margin: EdgeInsets.all(40),
                    height: 600,
                    width: 700,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color: const Color.fromARGB(255, 0, 30, 54),),
                  ),
                ],
              ))
          ],),
          Column(children: [],),
        ],
      ),
    );
  }
}
