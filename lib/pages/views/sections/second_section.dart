import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pbma_portal/pages/models/infos.dart';
import 'package:pbma_portal/widgets/footer.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';
import 'package:pbma_portal/widgets/info_card.dart';
import 'package:pbma_portal/widgets/mission_vision.dart';
import 'package:pbma_portal/widgets/scroll_offset.dart';
import 'package:pbma_portal/widgets/text_reveal.dart';

class SecondSection extends StatefulWidget {
  const SecondSection({super.key});

  @override
  State<SecondSection> createState() => _SecondSectionState();
}

class _SecondSectionState extends State<SecondSection>
    with TickerProviderStateMixin {
  late AnimationController imageController;
  late Animation<double> imageReveal;
  late Animation<double> imageOpacity;
  late AnimationController _WHY;
  late AnimationController _PBMAoffers;
  late Animation<double> _PBMAoffersAnimation;
  late Animation<double> _PBMAoffersOpacityAnimation;
  late Animation<double> _WHYAnimation;
  late Animation<double> _HeaderAnimation;
  late Animation<double> _HeaderOpacityAnimation;
  late AnimationController _Header;
  late Animation<double> _descAnimation;
  late Animation<double> _descOpacityAnimation;
  late AnimationController _desc;
  late Animation<double> _WHYOpacityAnimation;
  late AnimationController _section2TextController;
  late AnimationController coreValues;

  @override
  void initState() {
    _WHY = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _WHYAnimation = Tween<double>(begin: 100, end: 0).animate(CurvedAnimation(
        parent: _WHY,
        curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _WHYOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _WHY, curve: Interval(0.0, 0.3, curve: Curves.easeOut)));

    _PBMAoffers = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _PBMAoffersAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _PBMAoffers,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _PBMAoffersOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _PBMAoffers,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _Header = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _HeaderAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _Header,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _HeaderOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _Header, curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _desc = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _descAnimation = Tween<double>(begin: 100, end: 0).animate(CurvedAnimation(
        parent: _desc,
        curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _descOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _desc, curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    coreValues = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 375));
    imageController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1500),
        reverseDuration: Duration(milliseconds: 500));
    imageReveal = Tween<double>(begin: 0, end: 170).animate(CurvedAnimation(
        parent: imageController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut)));
    imageOpacity = Tween<double>(begin: 0.0, end: 1).animate(CurvedAnimation(
        parent: imageController,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut)));
    _section2TextController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        reverseDuration: Duration(milliseconds: 375));
    super.initState();
    Future.delayed(Duration(milliseconds: 1000), () {
      coreValues.forward();
    });
  }

  @override
  void dispose() {
    _WHY.dispose();
    _PBMAoffers.dispose();
    imageController.dispose();
    _Header.dispose();
    _desc.dispose();
    _section2TextController.dispose();
    coreValues.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.fromARGB(255, 1, 93, 168), Colors.white],
        stops: [0.1, 1],
      )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: BlocBuilder<DisplayOffset, ScrollOffset>(
              buildWhen: (previous, current) {
                print('refreshed in ${current.scrollOffsetValue}');
                if ((current.scrollOffsetValue >= 800 ||
                        current.scrollOffsetValue < 900) ||
                    _WHY.isAnimating) {
                  return true;
                } else {
                  return false;
                }
              },
              builder: (context, state) {
                if (state.scrollOffsetValue >= 800) {
                  print("forward");
                  _WHY.forward();
                } else {
                  print("reverse");
                  _WHY.reverse();
                }
                return TextReveal(
                  textOpacityAnimation: _WHYOpacityAnimation,
                  textRevealAnimation: _WHYAnimation,
                  maxHeight: 70,
                  textController: _section2TextController,
                  child: Text(
                    "Why Prime Brilliant Minds Academy?",
                    style: TextStyle(
                        fontSize: screenWidth / 35,
                        fontFamily: "B",
                        color: Colors.white),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: BlocBuilder<DisplayOffset, ScrollOffset>(
              buildWhen: (previous, current) {
                print('refreshed in ${current.scrollOffsetValue}');
                if ((current.scrollOffsetValue >= 900 ||
                        current.scrollOffsetValue < 1000) ||
                    _PBMAoffers.isAnimating) {
                  return true;
                } else {
                  return false;
                }
              },
              builder: (context, state) {
                if (state.scrollOffsetValue >= 900) {
                  print("forward");
                  _PBMAoffers.forward();
                } else {
                  print("reverse");
                  _PBMAoffers.reverse();
                }
                return TextReveal(
                  textOpacityAnimation: _PBMAoffersOpacityAnimation,
                  textRevealAnimation: _PBMAoffersAnimation,
                  maxHeight: 70,
                  textController: _section2TextController,
                  child: Text(
                    "PBMA offers Senior High School program as well as different TESDA Courses and is now an accredited assesment center. A wide array of courses to choose from depending on your preferred skill and craft.",
                    style: TextStyle(
                        fontFamily: "R",
                        fontSize: screenWidth / 70,
                        color: Colors.white),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
            child: BlocBuilder<DisplayOffset, ScrollOffset>(
                buildWhen: (previous, current) {
              print('refreshed in ${current.scrollOffsetValue}');
              if ((current.scrollOffsetValue >= 1000 ||
                      current.scrollOffsetValue < 2000) ||
                  imageController.isAnimating) {
                return true;
              } else {
                return false;
              }
            }, builder: (context, state) {
              if (state.scrollOffsetValue >= 1000) {
                print("forward");
                imageController.forward();
              } else {
                print("reverse");
                imageController.reverse();
              }
              return AnimatedBuilder(
                animation: imageController,
                builder: (BuildContext context, Widget? child) {
                  return FadeTransition(
                    opacity: imageOpacity,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              children: [
                                Container(
                                    height: screenWidth / 4,
                                    width: screenWidth / 2.4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        image: DecorationImage(
                                            image: AssetImage("assets/shs.jpg"),
                                            fit: BoxFit.cover))),
                                Container(
                                    height: screenWidth / 4,
                                    width: screenWidth / 2.4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Color.fromARGB(255, 255, 231, 11)
                                            .withOpacity(0.4))),
                                Positioned(
                                  bottom: 65,
                                  left: 20,
                                  child: Container(
                                    child: BlocBuilder<DisplayOffset,
                                            ScrollOffset>(
                                        buildWhen: (previous, current) {
                                      print(
                                          'refreshed in ${current.scrollOffsetValue}');
                                      if ((current.scrollOffsetValue >= 1160 ||
                                              current.scrollOffsetValue <
                                                  2000) ||
                                          _Header.isAnimating) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    }, builder: (context, state) {
                                      if (state.scrollOffsetValue >= 1160) {
                                        print("forward header1");
                                        _Header.forward();
                                      } else {
                                        print("reverse header1");
                                        _Header.reverse();
                                      }
                                      return TextReveal(
                                        maxHeight: 60,
                                        textController: coreValues,
                                        textRevealAnimation: _HeaderAnimation,
                                        textOpacityAnimation:
                                            _HeaderOpacityAnimation,
                                        child: Text(
                                          "Senior High School Program",
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontFamily: "BL",
                                              color: Colors.white),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                                Positioned(
                                  bottom: 36,
                                  left: 20,
                                  child: Container(
                                    child: Icon(
                                      Icons.school,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 40,
                                    left: 60,
                                    child: BlocBuilder<DisplayOffset,
                                            ScrollOffset>(
                                        buildWhen: (previous, current) {
                                      print(
                                          'refreshed in ${current.scrollOffsetValue}');
                                      if ((current.scrollOffsetValue >= 1210 ||
                                              current.scrollOffsetValue <
                                                  2000) ||
                                          _desc.isAnimating) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    }, builder: (context, state) {
                                      if (state.scrollOffsetValue >= 1210) {
                                        print("forward header1");
                                        _desc.forward();
                                      } else {
                                        print("reverse header1");
                                        _desc.reverse();
                                      }
                                      return TextReveal(
                                        maxHeight: 60,
                                        textController: coreValues,
                                        textRevealAnimation: _descAnimation,
                                        textOpacityAnimation:
                                            _descOpacityAnimation,
                                        child: Text(
                                          "PBMA offers various track and strands",
                                          style: TextStyle(
                                              fontFamily: "M", fontSize: 15),
                                        ),
                                      );
                                    })),
                                Positioned(
                                  right: 20,
                                  bottom: 20,
                                  child: Container(
                                    child: BlocBuilder<DisplayOffset,
                                            ScrollOffset>(
                                        buildWhen: (previous, current) {
                                      print(
                                          'refreshed in ${current.scrollOffsetValue}');
                                      if ((current.scrollOffsetValue >= 1210 ||
                                              current.scrollOffsetValue <
                                                  2000) ||
                                          _desc.isAnimating) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    }, builder: (context, state) {
                                      if (state.scrollOffsetValue >= 1210) {
                                        print("forward header1");
                                        _desc.forward();
                                      } else {
                                        print("reverse header1");
                                        _desc.reverse();
                                      }
                                      return TextReveal(
                                        maxHeight: 60,
                                        textController: coreValues,
                                        textRevealAnimation: _descAnimation,
                                        textOpacityAnimation:
                                            _descOpacityAnimation,
                                        child: Text(
                                          "See Program",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontFamily: "B",
                                              color: Colors.black),
                                        ).moveUpOnHover,
                                      );
                                    }),
                                  ),
                                )
                              ],
                            ).showCursorOnHover,
                            Stack(
                              children: [
                                Container(
                                    height: screenWidth / 4,
                                    width: screenWidth / 2.4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        image: DecorationImage(
                                            image:
                                                AssetImage("assets/tesda.jpg"),
                                            fit: BoxFit.cover))),
                                Container(
                                    height: screenWidth / 4,
                                    width: screenWidth / 2.4,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Color.fromARGB(255, 255, 231, 11)
                                            .withOpacity(0.4))),
                                Positioned(
                                    bottom: 65,
                                    left: 20,
                                    child: Container(
                                      child: BlocBuilder<DisplayOffset,
                                              ScrollOffset>(
                                          buildWhen: (previous, current) {
                                        print(
                                            'refreshed in ${current.scrollOffsetValue}');
                                        if ((current.scrollOffsetValue >=
                                                    1160 ||
                                                current.scrollOffsetValue <
                                                    2000) ||
                                            _Header.isAnimating) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      }, builder: (context, state) {
                                        if (state.scrollOffsetValue >= 1160) {
                                          print("forward header1");
                                          _Header.forward();
                                        } else {
                                          print("reverse header1");
                                          _Header.reverse();
                                        }
                                        return TextReveal(
                                          maxHeight: 60,
                                          textController: coreValues,
                                          textRevealAnimation: _HeaderAnimation,
                                          textOpacityAnimation:
                                              _HeaderOpacityAnimation,
                                          child: Text(
                                            "TESDA Program",
                                            style: TextStyle(
                                                fontSize: 30,
                                                fontFamily: "BL",
                                                color: Colors.white),
                                          ),
                                        );
                                      }),
                                    )),
                                Positioned(
                                  bottom: 36,
                                  left: 20,
                                  child: Container(
                                    child: Icon(
                                      Icons.school,
                                      color: Colors.black,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                Positioned(
                                    bottom: 40,
                                    left: 60,
                                    child: Text(
                                      "PBMA offers different courses and NC's",
                                      style: TextStyle(
                                          fontFamily: "M", fontSize: 15),
                                    )),
                                Positioned(
                                  right: 20,
                                  bottom: 20,
                                  child: Container(
                                    child: Text(
                                      "See Program",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: "B",
                                          color: Colors.black),
                                    ).moveUpOnHover,
                                  ),
                                )
                              ],
                            ).showCursorOnHover,
                          ]),
                    ),
                  );
                },
              );
            }),
          ),
          SizedBox(
            height: 70,
          ),
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                  child: TextReveal(
                    maxHeight: 60,
                    textController: coreValues,
                    textRevealAnimation: _WHYAnimation,
                    textOpacityAnimation: _WHYOpacityAnimation,
                    child: Text(
                      "Core Values",
                      style: TextStyle(
                          fontSize: screenWidth / 35,
                          fontFamily: "B",
                          color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                //THIS IS THE CORE VALUES
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: infos
                      .map<Widget>((info) => InfoCard(info: info))
                      .toList(),
                ),
                SizedBox(
                  height: 50,
                ),
                //THIS IS THE MISION AND VISION
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                  child: MissionAndVision(),
                ),
                SizedBox(
                  height: 50,
                ),
                //THIS IS THE FOOTER
                Footer()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
