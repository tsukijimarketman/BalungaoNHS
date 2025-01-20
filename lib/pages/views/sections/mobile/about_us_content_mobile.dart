import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/pages/Auth_View/SignInMobileView.dart';
import 'package:balungao_nhs/TermsAndConditions/TAC_Mobile_View.dart';
import 'package:balungao_nhs/pages/views/sections/mobile/footer_mobile.dart';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/widgets/hover_extensions.dart';

class AboutUsContentMobile extends StatefulWidget {
  const AboutUsContentMobile({super.key});

  @override
  State<AboutUsContentMobile> createState() => _AboutUsContentMobileState();
}

class _AboutUsContentMobileState extends State<AboutUsContentMobile> with TickerProviderStateMixin {
  final GlobalKey _footerKey = GlobalKey();
  late ScrollController _scrollController;
  Color _appBarColor = Color(0xFF03b97c);
  Color _textColor1 = Color(0xFF002f24);
  Color _textColor2 = Color(0xFF002f24);
  Color _textColor3 = Color(0xFF002f24);
  bool _showSignInCard = false;
  bool _TAC = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels > 0) {
      setState(() {
        _appBarColor = const Color(0xFF03b97c);
      });
    } else {
      setState(() {
        _appBarColor = Color(0xFF03b97c);
      });
    }
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
        automaticallyImplyLeading: false,
        toolbarHeight: screenWidth / 10,
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
                      builder: (context) => Launcher(scrollToFooter: false),
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
                          height: screenWidth / 15,
                          width: screenWidth / 15,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "MNHS",
                      style: TextStyle(
                        color: Color(0xFF002f24),
                        fontFamily: "B",
                        fontSize: screenWidth / 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).showCursorOnHover,
              Spacer(),
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Color(0xFF002f24)),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Color(0xFF002f24),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF03b97c),
              ),
              child: Column(
                children: [
                  ClipOval(
                    child: Image.asset(
                      "assets/balungaonhs.png",
                      height: 80,
                      width: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Colors.white,),
              title: Text('Home', style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Launcher(scrollToFooter: false),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info,color: Colors.white),
              title: Text('About us', style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutUsContentMobile(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_mail, color: Colors.white),
              title: Text('Contact us', style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                scrollToSection(_footerKey);
              },
            ),
            ListTile(
              leading: Icon(Icons.login, color: Colors.white),
              title: Text('Sign In', style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                toggleSignInCard();
              },
            ),
            ListTile(
              leading: Icon(Icons.school, color: Colors.white),
              title: Text('Enroll Now', style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                toggleTAC();
              },
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
                Container(
                  width: screenWidth,
                  color: const Color.fromARGB(88, 173, 173, 173),
                  child: Container(
                    margin: EdgeInsets.only(
                      top: screenWidth / 9,
                      left: screenWidth / 17,
                      right: screenWidth / 17,
                      bottom: screenWidth / 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color.fromARGB(255, 235, 235, 235),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: screenHeight / 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            image: DecorationImage(
                              image: AssetImage("assets/mnhs2.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20),
                                  ),
                                  color: Color(0x6565f058).withOpacity(0.5), // Blend color with opacity
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Text(
                                      "Welcome to the largest school in Region 1,",
                                      style: TextStyle(
                                        color: Color(0xFF002f24),
                                        fontFamily: "B",
                                        fontSize: screenWidth / 20,
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      "MANGALDAN NATIONAL HIGH SCHOOL",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "BL",
                                        fontSize: screenWidth / 15,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          width: screenWidth,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth / 17),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "The Story of Mangaldan National High School",
                                style: TextStyle(
                                  fontFamily: "B",
                                  fontSize: screenWidth / 20,
                                  color: Color(0xFF03b97c),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Mangaldan National High School is the largest school in Region 1. It has a rich history and a commitment to providing quality education to its students.",
                                style: TextStyle(
                                  fontFamily: "R",
                                  fontSize: screenWidth / 25,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Our mission is to nurture and develop the potential of every student, preparing them for a successful future.",
                                style: TextStyle(
                                  fontFamily: "R",
                                  fontSize: screenWidth / 25,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                FooterMobile(
                  key: _footerKey,
                ),
              ],
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
                                  child: SignInMobile(
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
                                  child: TacMobileView(
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
