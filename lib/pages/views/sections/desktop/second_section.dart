import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balungao_nhs/pages/models/infos.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/footer.dart';
import 'package:balungao_nhs/widgets/hover_extensions.dart';
import 'package:balungao_nhs/widgets/info_card.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/mission_vision.dart';
import 'package:balungao_nhs/widgets/scroll_offset.dart';
import 'package:balungao_nhs/widgets/text_reveal.dart';

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
  late Animation<double> _seeProgramAnimation;
  late Animation<double> _seeProgramOpacityAnimation;
  late AnimationController _seeProgram;
  late Animation<double> _coreValuesAnimation;
  late Animation<double> _coreValuesOpacityAnimation;
  late AnimationController _coreValues;
  late Animation<double> _AppearAnimation;
  late Animation<double> _AppearOpacityAnimation;
  late AnimationController _Appear;
  late Animation<double> _WHYOpacityAnimation;

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
    _seeProgram = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _seeProgramAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _seeProgram,
            curve: Interval(0.0, 0.7, curve: Curves.fastEaseInToSlowEaseOut)));
    _seeProgramOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _seeProgram,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _coreValues = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _coreValuesAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _coreValues,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _coreValuesOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _coreValues,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
    _Appear = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 1000),
    );
    _AppearAnimation = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _Appear,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _AppearOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _Appear, curve: Interval(0.0, 0.3, curve: Curves.easeOut)));
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
    super.initState();
  }

  @override
  void dispose() {
    _WHY.dispose();
    _PBMAoffers.dispose();
    imageController.dispose();
    _Header.dispose();
    _desc.dispose();
    _coreValues.dispose();
    _seeProgram.dispose();
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
        colors: [Color(0xFF03b97c), Colors.white],
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
                //print('The height is around $screenHeight');
                if ((current.scrollOffsetValue >= 800 ||
                        current.scrollOffsetValue < 900) ||
                    _WHY.isAnimating) {
                  return true;
                } else {
                  return false;
                }
              },
              builder: (context, state) {
                if (state.scrollOffsetValue >= (800)) {
                  _WHY.forward();
                } else {
                  _WHY.reverse();
                }
                return TextReveal(
                  textOpacityAnimation: _WHYOpacityAnimation,
                  textRevealAnimation: _WHYAnimation,
                  maxHeight: 70,
                  textController: _WHY,
                  child: Text(
                    "Why Balungao National High School?",
                    style: TextStyle(
                        fontSize: screenWidth / 35,
                        fontFamily: "B",
                        color: Colors.yellowAccent),
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
                  _PBMAoffers.forward();
                } else {
                  _PBMAoffers.reverse();
                }
                return TextReveal(
                  textOpacityAnimation: _PBMAoffersOpacityAnimation,
                  textRevealAnimation: _PBMAoffersAnimation,
                  maxHeight: 110,
                  textController: _PBMAoffers,
                  child: Text(
                    "At Balungao National High School, we are committed to providing quality education, fostering holistic development, and empowering students to achieve academic excellence and personal growth in a nurturing and inclusive environment, with a wide array of strands to choose from that cater to every student's unique interests and career aspirations.",
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
              if ((current.scrollOffsetValue >= 1000 ||
                      current.scrollOffsetValue < 2000) ||
                  imageController.isAnimating) {
                return true;
              } else {
                return false;
              }
            }, builder: (context, state) {
              if (state.scrollOffsetValue >= 1000) {
                imageController.forward();
              } else {
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    image: DecorationImage(
                                      image: AssetImage("assets/primeshs.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: screenWidth / 4,
                                  width: screenWidth / 2.4,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Color(0xFF002f24)
                                        .withOpacity(0.4),
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth * 0.065,
                                  left: screenWidth * 0.02,
                                  child: Container(
                                    child: BlocBuilder<DisplayOffset,
                                        ScrollOffset>(
                                      buildWhen: (previous, current) {
                                        if ((current.scrollOffsetValue >=
                                                    1160 ||
                                                current.scrollOffsetValue <
                                                    2000) ||
                                            _Header.isAnimating) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state.scrollOffsetValue >= 1160) {
                                          _Header.forward();
                                        } else {
                                          _Header.reverse();
                                        }
                                        return TextReveal(
                                          maxHeight: screenWidth * 0.06,
                                          textController: _Header,
                                          textRevealAnimation: _HeaderAnimation,
                                          textOpacityAnimation:
                                              _HeaderOpacityAnimation,
                                          child: Text(
                                            "Junior High School Program",
                                            style: TextStyle(
                                              fontSize: screenWidth / 45,
                                              fontFamily: "BL",
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth * 0.036,
                                  left: screenWidth * 0.02,
                                  child: Container(
                                    child: Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: screenWidth / 45,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth * 0.04,
                                  left: screenWidth * 0.06,
                                  child:
                                      BlocBuilder<DisplayOffset, ScrollOffset>(
                                    buildWhen: (previous, current) {
                                      if ((current.scrollOffsetValue >= 1210 ||
                                              current.scrollOffsetValue <
                                                  2000) ||
                                          _desc.isAnimating) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state.scrollOffsetValue >= 1210) {
                                        _desc.forward();
                                      } else {
                                        _desc.reverse();
                                      }
                                      return TextReveal(
                                        maxHeight: screenWidth * 0.06,
                                        textController: _desc,
                                        textRevealAnimation: _descAnimation,
                                        textOpacityAnimation:
                                            _descOpacityAnimation,
                                        child: Text(
                                          "BNHS offers various special programs",
                                          style: TextStyle(
                                            fontFamily: "M",
                                            fontSize: screenWidth / 85,
                                            color: Colors.white
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: screenWidth * 0.02,
                                  bottom: screenWidth * 0.02,
                                  child:
                                      BlocBuilder<DisplayOffset, ScrollOffset>(
                                    buildWhen: (previous, current) {
                                      if ((current.scrollOffsetValue >= 1210 ||
                                              current.scrollOffsetValue <
                                                  2000) ||
                                          _seeProgram.isAnimating) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state.scrollOffsetValue >= 1210) {
                                        _seeProgram.forward();
                                      } else {
                                        _seeProgram.reverse();
                                      }
                                      return TextReveal(
                                        maxHeight: screenWidth * 0.06,
                                        textController: _seeProgram,
                                        textRevealAnimation:
                                            _seeProgramAnimation,
                                        textOpacityAnimation:
                                            _seeProgramOpacityAnimation,
                                        child: Text(
                                          "See Program",
                                          style: TextStyle(
                                            fontSize: screenWidth / 75,
                                            fontFamily: "B",
                                            color: Colors.white,
                                          ),
                                        ).moveUpOnHover,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ).showCursorOnHover,
                            Stack(
                              children: [
                                Container(
                                  height: screenWidth / 4,
                                  width: screenWidth / 2.4,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    image: DecorationImage(
                                      image: AssetImage("assets/primetesda.jpg"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: screenWidth / 4,
                                  width: screenWidth / 2.4,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: Color(0xFF002f24)
                                        .withOpacity(0.4),
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth * 0.065,
                                  left: screenWidth * 0.02,
                                  child: Container(
                                    child: BlocBuilder<DisplayOffset,
                                        ScrollOffset>(
                                      buildWhen: (previous, current) {
                                        if ((current.scrollOffsetValue >=
                                                    1160 ||
                                                current.scrollOffsetValue <
                                                    2000) ||
                                            _Header.isAnimating) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state.scrollOffsetValue >= 1160) {
                                          _Header.forward();
                                        } else {
                                          _Header.reverse();
                                        }
                                        return TextReveal(
                                          maxHeight: screenWidth * 0.06,
                                          textController: _Header,
                                          textRevealAnimation: _HeaderAnimation,
                                          textOpacityAnimation:
                                              _HeaderOpacityAnimation,
                                          child: Text(
                                            "Senior High School Program",
                                            style: TextStyle(
                                              fontSize: screenWidth / 45,
                                              fontFamily: "BL",
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth * 0.036,
                                  left: screenWidth * 0.02,
                                  child: Container(
                                    child: Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: screenWidth / 45,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: screenWidth * 0.04,
                                  left: screenWidth * 0.06,
                                  child:
                                      BlocBuilder<DisplayOffset, ScrollOffset>(
                                    buildWhen: (previous, current) {
                                      print(
                                          'refreshed in ${current.scrollOffsetValue}');
                                      if ((current.scrollOffsetValue >= 1210 ||
                                          current.scrollOffsetValue < 2000)) {
                                        return true;
                                      } else {
                                        return false;
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state.scrollOffsetValue >= 1210) {
                                        print("forward");
                                        _desc.forward();
                                      } else {
                                        print("reverse");
                                        _desc.reverse();
                                      }
                                      return TextReveal(
                                        textOpacityAnimation:
                                            _descOpacityAnimation,
                                        textRevealAnimation: _descAnimation,
                                        maxHeight: screenWidth * 0.07,
                                        textController: _desc,
                                        child: Text(
                                          "BNHS offers different strand and track",
                                          style: TextStyle(
                                            fontFamily: "M",
                                            fontSize: screenWidth / 85,
                                            color: Colors.white
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: screenWidth * 0.02,
                                  bottom: screenWidth * 0.02,
                                  child: Container(
                                    child: BlocBuilder<DisplayOffset,
                                        ScrollOffset>(
                                      buildWhen: (previous, current) {
                                        if ((current.scrollOffsetValue >=
                                                    1210 ||
                                                current.scrollOffsetValue <
                                                    2000) ||
                                            _seeProgram.isAnimating) {
                                          return true;
                                        } else {
                                          return false;
                                        }
                                      },
                                      builder: (context, state) {
                                        if (state.scrollOffsetValue >= 1210) {
                                          _seeProgram.forward();
                                        } else {
                                          _seeProgram.reverse();
                                        }
                                        return TextReveal(
                                          maxHeight: screenWidth * 0.06,
                                          textController: _seeProgram,
                                          textRevealAnimation:
                                              _seeProgramAnimation,
                                          textOpacityAnimation:
                                              _seeProgramOpacityAnimation,
                                          child: Text(
                                            "See Program",
                                            style: TextStyle(
                                              fontSize: screenWidth / 75,
                                              fontFamily: "B",
                                              color: Colors.white,
                                            ),
                                          ).moveUpOnHover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
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
            height: 40,
          ),
          Container(
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                    child: BlocBuilder<DisplayOffset, ScrollOffset>(
                        buildWhen: (previous, current) {
                      print('refreshed in ${current.scrollOffsetValue}');
                      if ((current.scrollOffsetValue >= 1360 ||
                              current.scrollOffsetValue < 2000) ||
                          _coreValues.isAnimating) {
                        return true;
                      } else {
                        return false;
                      }
                    }, builder: (context, state) {
                      if (state.scrollOffsetValue >= 1360) {
                        _coreValues.forward();
                      } else {
                        _coreValues.reverse();
                      }
                      return TextReveal(
                        textOpacityAnimation: _coreValuesOpacityAnimation,
                        textRevealAnimation: _coreValuesAnimation,
                        maxHeight: 70,
                        textController: _coreValues,
                        child: Text(
                          "Core Values",
                          style: TextStyle(
                              fontSize: screenWidth / 35,
                              fontFamily: "B",
                              color: Color(0xFF002f24)),
                        ),
                      );
                    })),
                SizedBox(
                  height: 20,
                ),
                //THIS IS THE CORE VALUES
                BlocBuilder<DisplayOffset, ScrollOffset>(
                  buildWhen: (previous, current) {
                    if ((current.scrollOffsetValue >= 1530 ||
                        current.scrollOffsetValue < 2500)) {
                      return true;
                    } else {
                      return false;
                    }
                  },
                  builder: (context, state) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: infos
                          .map<Widget>((info) => InfoCard(
                              info: info,
                              scrollOffset: state.scrollOffsetValue.toDouble()))
                          .toList(),
                    );
                  },
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.width / 15,
                ),
                //THIS IS THE MISION AND VISION
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                  child: MissionAndVision(),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
