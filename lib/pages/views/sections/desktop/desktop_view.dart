import 'dart:js_interop';
import 'dart:math';
import 'dart:ui';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/about_us.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/first_section.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/second_section.dart';
import 'package:balungao_nhs/widgets/hover_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:balungao_nhs/TermsAndConditions/TAC_Web_View.dart';
import 'package:balungao_nhs/pages/Auth_View/SignInDesktopView.dart';
import 'package:balungao_nhs/pages/enrollment_form.dart';
import 'package:balungao_nhs/pages/models/infos.dart';
import 'package:balungao_nhs/widgets/info_card.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/mission_vision.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/footer.dart';
import 'package:balungao_nhs/widgets/scroll_offset.dart';
import 'package:balungao_nhs/widgets/text_reveal.dart';

class DesktopView extends StatefulWidget {
  final bool scrollToFooter;

  const DesktopView({super.key, this.scrollToFooter = false});

  @override
  State<DesktopView> createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView>
    with TickerProviderStateMixin {
  final GlobalKey _footerKey = GlobalKey();
  late AnimationController imageController;
  late Animation<double> imageReveal;
  late Animation<double> imageOpacity;
  late ScrollController _scrollController;
  late AnimationController _textController2;
  late Animation<double> _textRevealAnimation2;
  late Animation<double> _textOpacityAnimation2;
  late AnimationController _section2TextController;
  late AnimationController coreValues;
  Color _appBarColor = Colors.transparent;
  //tsukijimarketman/PBMA_Portal

  @override
  void initState() {
    _textController2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 3000),
      reverseDuration: Duration(milliseconds: 375),
    );
    _textRevealAnimation2 = Tween<double>(begin: 100, end: 0).animate(
        CurvedAnimation(
            parent: _textController2,
            curve: Interval(0.0, 0.3, curve: Curves.fastEaseInToSlowEaseOut)));
    _textOpacityAnimation2 = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _textController2,
            curve: Interval(0.0, 0.3, curve: Curves.easeOut)));

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

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      context.read<DisplayOffset>().changeDisplayOffset(
          (MediaQuery.of(context).size.height +
                  _scrollController.position.pixels)
              .toInt());
    });

    _scrollController.addListener(_scrollListener);
    super.initState();
    Future.delayed(Duration(milliseconds: 1250), () {
      _textController2.forward();
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      _section2TextController.forward();
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      imageController.forward();
    });
    Future.delayed(Duration(milliseconds: 1000), () {
      coreValues.forward();
    });

    if (widget.scrollToFooter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToSection(_footerKey);
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 0) {
      setState(() {
        _appBarColor = const Color(0xFF03b97c);
      });
    } else {
      setState(() {
        _appBarColor = Colors.transparent;
      });
    }
  }

  Color _textColor1 = Colors.yellowAccent;
  Color _textColor2 = Colors.yellowAccent;
  Color _textColor3 = Colors.yellowAccent;
  Color _textColor5 = Color(0xFF002f24);
  Color _textColor6 = Color(0xFF03b97c);

  bool _showSignInCard = false;
  bool _TAC = false;

  void scrollToSection(GlobalKey key) {
    Scrollable.ensureVisible(key.currentContext!,
        duration: Duration(seconds: 1), curve: Curves.easeInOut);
  }

  void toggleTAC() {
    setState(() {
      _TAC = !_TAC;
    });
  }

  void closeTAC() {
    setState(() {
      _TAC = false;
    });
  }

  void toggleSignInCard() {
    setState(() {
      _showSignInCard = !_showSignInCard;
    });
  }

  void closeSignInCard() {
    setState(() {
      _showSignInCard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                FirstSection(onGetStartedPressed: toggleTAC),
                SecondSection(),
                Footer(
                  key: _footerKey,
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textController2,
              builder: (context, child) {
                return FadeTransition(
                    opacity: _textOpacityAnimation2,
                    child: AppBar(
                      automaticallyImplyLeading: false,
                      toolbarHeight: screenWidth / 16,
                      elevation: 8,
                      backgroundColor: _appBarColor,
                      title: Container(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Launcher(
                                      scrollToFooter: false,
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {},
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Image.asset(
                                        "assets/balungaonhs.png",
                                        height: screenWidth / 20,
                                        width: screenWidth / 20,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "BNHS",
                                    style: TextStyle(
                                      color: Colors.yellowAccent,
                                      fontFamily: "B",
                                      fontSize: screenWidth / 50,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ).showCursorOnHover,
                            Spacer(),
                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _textColor2 = Color(0xFF002f24);
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _textColor2 = Colors.yellowAccent;
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AboutUs(),
                                      ));
                                },
                                child: Text(
                                  "About us",
                                  style: TextStyle(
                                    fontFamily: "SB",
                                    fontSize: 14,
                                    color: _textColor2,
                                  ),
                                ).showCursorOnHover.moveUpOnHover,
                              ),
                            ),
                            SizedBox(width: 25),
                            MouseRegion(
                              onEnter: (_) {
                                setState(() {
                                  _textColor3 = Color(0xFF002f24);
                                });
                              },
                              onExit: (_) {
                                setState(() {
                                  _textColor3 = Colors.yellowAccent;
                                });
                              },
                              child: GestureDetector(
                                onTap: () {
                                  scrollToSection(_footerKey);
                                },
                                child: Text(
                                  "Contact us",
                                  style: TextStyle(
                                    fontFamily: "SB",
                                    fontSize: 14,
                                    color: _textColor3,
                                  ),
                                ).showCursorOnHover.moveUpOnHover,
                              ),
                            ),
                            SizedBox(width: 25),
                            SizedBox(
                              width: screenWidth / 12,
                              height: screenWidth / 35,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xFF002f24)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                onPressed: toggleSignInCard,
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontFamily: "B",
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).moveUpOnHover,
                            SizedBox(width: 25),
                            SizedBox(
                              width: screenWidth / 12,
                              height: screenWidth / 35,
                              child: TextButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xFF002f24)),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                onPressed: toggleTAC,
                                child: Text(
                                  "Enroll Now",
                                  style: TextStyle(
                                    fontFamily: "B",
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ).moveUpOnHover,
                          ],
                        ),
                      ),
                    ));
              },
            ),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 550),
            child: _showSignInCard
                ? Stack(children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: closeSignInCard,
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: screenWidth / 1.2,
                                  height: screenHeight / 1.2,
                                  curve: Curves.easeInOut,
                                  child: SignInDesktop(
                                    key: ValueKey('signInCard'),
                                    closeSignInCardCallback: closeSignInCard,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])
                : SizedBox.shrink(),
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 550),
            child: _TAC
                ? Stack(children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: closeTAC,
                        child: Stack(
                          children: [
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
                                  width: screenWidth / 1.2,
                                  height: screenHeight / 1.2,
                                  curve: Curves.easeInOut,
                                  child: TACWebView(
                                    key: ValueKey('closeTAC'),
                                    closeTAC: closeTAC,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
