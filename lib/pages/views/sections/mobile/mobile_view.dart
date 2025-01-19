import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/Auth_View/SignInMobileView.dart';
import 'package:balungao_nhs/TermsAndConditions/TAC_Mobile_View.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/first_section_mobile.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/footer_mobile.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/second_section_mobile.dart';

class MobileView extends StatefulWidget {
  const MobileView({super.key});

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> with TickerProviderStateMixin {
  final GlobalKey _footerKey = GlobalKey();
  final GlobalKey _firstSectionKey = GlobalKey();
  late ScrollController _scrollController;
  bool _showSignInCard = false;
  bool _TAC = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

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
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Image.asset(
                "assets/balungaonhs.png",
                height: 40,
                width: 40,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "BNHS Portal",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: "B",
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF002f24),
        iconTheme: IconThemeData(
          color: Colors.white, // Make the drawer icon white
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.login, color: Colors.white),
            onPressed: toggleSignInCard,
          ),
          IconButton(
            icon: Icon(Icons.app_registration, color: Colors.white),
            onPressed: toggleTAC,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF03b97c),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:
                  BoxDecoration(color: Color(0xFF002f24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/balungaonhs.png", // Replace with your PBMA logo asset path
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Menu",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: "M",
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.black),
              title: Text(
                "Home",
                style: TextStyle(fontFamily: "M"),
              ),
              onTap: () => scrollToSection(
                  _firstSectionKey), // Scroll to the first section
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.black),
              title: Text(
                "About Us",
                style: TextStyle(fontFamily: "M"),
              ),
              onTap: () {
                //todo ABOUT US MOBILE HERE
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_page, color: Colors.black),
              title: Text(
                "Contact Us",
                style: TextStyle(fontFamily: "M"),
              ),
              onTap: () => scrollToSection(_footerKey),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                FirstSectionMobile(
                  key: _firstSectionKey,
                  onGetStartedPressed: toggleTAC,
                ),
                SecondSectionMobile(),
                FooterMobile(key: _footerKey),
              ],
            ),
          ),
          if (_showSignInCard)
            Positioned.fill(
              child: GestureDetector(
                onTap: closeSignInCard,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.6,
                          curve: Curves.easeInOut,
                          child: SignInMobile(
                              closeSignInCardCallback: closeSignInCard),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_TAC)
            Positioned.fill(
              child: GestureDetector(
                onTap: closeTAC,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.6,
                          curve: Curves.easeInOut,
                          child: TacMobileView(closeTAC: closeTAC),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
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
