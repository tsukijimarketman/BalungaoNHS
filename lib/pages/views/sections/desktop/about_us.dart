import 'dart:js_interop';
import 'dart:math';
import 'dart:ui';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/about_us.dart';
import 'package:balungao_nhs/pages/views/sections/desktop/about_us_content.dart';
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

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> with TickerProviderStateMixin {
  final GlobalKey _footerKey = GlobalKey();
  
  Color _appBarColor = Color(0xFF03b97c);
  //tsukijimarketman/PBMA_Portal


  Color _textColor1 = Color(0xFF002f24);
  Color _textColor2 = Color(0xFF002f24);
  Color _textColor3 = Color(0xFF002f24);
  Color _textColor5 = Color(0xFF002f24);
  Color _textColor6 = Color(0xFF03b97c);

  bool _showSignInCard = false;
  bool _TAC = false;


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
            child: Column(
              children: [
                AboutUsContent(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
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
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.asset(
                                  "assets/balungaonhs.png",
                                  height: screenWidth / 20,
                                  width: screenWidth / 20,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "MNHS",
                                style: TextStyle(
                                  color: Color(0xFF002f24),
                                  fontFamily: "B",
                                  fontSize: screenWidth / 50,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        //here
                        MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _textColor2 = Color(0xFF002f24);
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _textColor1 = Color(0xFF002f24);
                            });
                          },
                          child: GestureDetector(
                            onTap: () {},
                            child: Text(
                              "Services",
                              style: TextStyle(
                                fontFamily: "SB",
                                fontSize: 14,
                                color: _textColor1,
                              ),
                            ).showCursorOnHover.moveUpOnHover,
                          ),
                        ),
                        SizedBox(width: 25),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
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
                              color: Colors.yellowAccent,
                            ),
                          ).showCursorOnHover.moveUpOnHover,
                        ),
                        SizedBox(width: 25),
                        MouseRegion(
                          onEnter: (_) {
                            setState(() {
                              _textColor2 = Color(0xFF002f24);
                            });
                          },
                          onExit: (_) {
                            setState(() {
                              _textColor3 = Color(0xFF002f24);
                            });
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      Launcher(scrollToFooter: true),
                                ),
                              );
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
            ),  ),
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
}
