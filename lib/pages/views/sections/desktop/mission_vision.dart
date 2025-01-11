import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balungao_nhs/widgets/scroll_offset.dart';
import 'package:balungao_nhs/widgets/text_reveal.dart';

class MissionAndVision extends StatefulWidget {
  const MissionAndVision({super.key});

  @override
  State<MissionAndVision> createState() => _MissionAndVisionState();
}

class _MissionAndVisionState extends State<MissionAndVision>
    with TickerProviderStateMixin {
  late Animation<double> _SHSAnimation;
  late Animation<double> _SHSOpacityAnimation;
  late AnimationController _SHS;
  late Animation<double> _ContainerBlueAnimation;
  late Animation<double> _ContainerBlueOpacityAnimation;
  late AnimationController _ContainerBlue;
  late Animation<double> _PrincipalAnimation;
  late Animation<double> _PrincipalOpacityAnimation;
  late AnimationController _Principal;

  @override
  void initState() {
    _Principal = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _PrincipalAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _Principal,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _PrincipalOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _Principal,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _ContainerBlue = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _ContainerBlueAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _ContainerBlue,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _ContainerBlueOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _ContainerBlue,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _SHS = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _SHSAnimation = Tween<double>(begin: 100, end: 0).animate(CurvedAnimation(
        parent: _SHS,
        curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _SHSOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _SHS, curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _SHS.dispose();
    _ContainerBlue.dispose();
    _Principal.dispose();
    // TODO: implement dispose
    super.dispose();
  }

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
                  BlocBuilder<DisplayOffset, ScrollOffset>(
                    buildWhen: (previous, current) {
                      if ((current.scrollOffsetValue >= 2000 ||
                              current.scrollOffsetValue < 2500) ||
                          _ContainerBlue.isAnimating) {
                        return true;
                      } else {
                        return false;
                      }
                    },
                    builder: (context, state) {
                      if (state.scrollOffsetValue >= 2000) {
                        _ContainerBlue.forward();
                      } else {
                        _ContainerBlue.reverse();
                      }
                      return AnimatedBuilder(
                        animation: _ContainerBlueAnimation,
                        builder: (BuildContext context, Widget? child) {
                          return FadeTransition(
                            opacity: _ContainerBlueOpacityAnimation,
                            child: Container(
                              margin:
                                  const EdgeInsets.only(bottom: 20, right: 40),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: const Color.fromARGB(255, 0, 83, 56),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  children: [
                                    BlocBuilder<DisplayOffset, ScrollOffset>(
                                        buildWhen: (previous, current) {
                                      if ((current.scrollOffsetValue >= 2000 ||
                                              current.scrollOffsetValue <
                                                  2500) ||
                                          _SHS.isAnimating) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    }, builder: (context, state) {
                                      if (state.scrollOffsetValue >= 2000) {
                                        _SHS.forward();
                                      } else {
                                        _SHS.reverse();
                                      }
                                      return TextReveal(
                                        maxHeight: 70,
                                        textController: _SHS,
                                        textRevealAnimation: _SHSAnimation,
                                        textOpacityAnimation:
                                            _SHSOpacityAnimation,
                                        child: Text(
                                          "HIGH SCHOOL",
                                          style: TextStyle(
                                            fontFamily: "R",
                                            fontSize: screenWidth / 50,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    }),
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
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Container(
                                                      height: screenWidth / 4.6,
                                                      width: screenWidth / 4.6,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            "assets/placeholder.png",
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
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            40,
                                                    color: Color.fromARGB(
                                                            255, 255, 230, 0)
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
                                                        BorderRadius.circular(
                                                            20),
                                                    child: Container(
                                                      height: screenWidth / 4.6,
                                                      width: screenWidth / 4.6,
                                                      decoration:
                                                          const BoxDecoration(
                                                        image: DecorationImage(
                                                          image: AssetImage(
                                                            "assets/placeholder.png",
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
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            40,
                                                    color: Color.fromARGB(
                                                            255, 255, 230, 0)
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
                          );
                        },
                      );
                    },
                  ),
                  BlocBuilder<DisplayOffset, ScrollOffset>(
                      buildWhen: (previous, current) {
                    if ((current.scrollOffsetValue >= 2350 ||
                            current.scrollOffsetValue < 2500) ||
                        _Principal.isAnimating) {
                      return true;
                    } else {
                      return false;
                    }
                  }, builder: (context, state) {
                    if (state.scrollOffsetValue >= 2350) {
                      _Principal.forward();
                    } else {
                      _Principal.reverse();
                    }
                    return AnimatedBuilder(
                        animation: _PrincipalAnimation,
                        builder: (BuildContext context, Widget? child) {
                          return FadeTransition(
                              opacity: _PrincipalOpacityAnimation,
                              child: Row(
                                children: [
                                  Container(
                                    width: screenWidth / 4.4,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Lorem Ipsum Dolor,",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 30, 54),
                                            fontFamily: "B",
                                            fontSize: screenWidth / 68,
                                          ),
                                        ),
                                        Text(
                                          "School Principal",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 30, 54),
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
                                          "Lorem Ipsum Dolor",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 30, 54),
                                            fontFamily: "B",
                                            fontSize: screenWidth / 68,
                                          ),
                                        ),
                                        Text(
                                          "School Administrator",
                                          style: TextStyle(
                                            color:
                                                Color.fromARGB(255, 0, 30, 54),
                                            fontFamily: "R",
                                            fontSize: screenWidth / 95,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                        });
                  })
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
                          "BNHS VISION",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 54),
                            fontFamily: "B",
                            fontSize: screenWidth / 55,
                          ),
                        ),
                        Text(
                          "Lorem ipsum dolor sit amet. Et illum dignissimos est exercitationem nulla id nihil dolores ut harum repellendus ea corrupti sunt qui recusandae sint. Sit consectetur Quis et sunt quasi vel voluptas tempora. Cum vero veniam ut porro eius id illo molestiae qui veritatis laudantium.",
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
                          "BNHS MISION",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 30, 54),
                            fontFamily: "B",
                            fontSize: screenWidth / 55,
                          ),
                        ),
                        Text(
                          "Lorem ipsum dolor sit amet. Et illum dignissimos est exercitationem nulla id nihil dolores ut harum repellendus ea corrupti sunt qui recusandae sint. Sit consectetur Quis et sunt quasi vel voluptas tempora. Cum vero veniam ut porro eius id illo molestiae qui veritatis laudantium.",
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
