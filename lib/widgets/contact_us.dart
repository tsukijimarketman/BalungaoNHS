import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _LocationURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _TESDAURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail(String email) async {
    // Define the mailto URL with the recipient's email
    //final email = 'mailto:recipient@example.com?subject=Hello&body=How are you?';

    // Check if the email app can be launched and then launch it
    if (await canLaunchUrlString(email)) {
      await launchUrlString(email);
    } else {
      throw 'Could not launch email client';
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final telUrl = 'tel:$phoneNumber';

    if (await canLaunchUrlString(telUrl)) {
      await launchUrlString(telUrl);
    } else {
      throw 'Could not launch $telUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 420,
        color: Color.fromARGB(255, 1, 93, 168),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 80),
          child: Row(
            children: [
              Container(
                height: 420,
                width: (MediaQuery.of(context).size.width / 3) + 67,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: Colors.yellow, width: 2))),
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                          right: 40,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.yellow, width: 2))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 50.0,
                              height: 50.0,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                "assets/PBMA.png",
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _launchURL(
                                        "https://www.facebook.com/PrimeAcademyOfficial/");
                                  },
                                  child: Stack(children: [
                                    Container(
                                        width: 50.0,
                                        height: 50.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 5),
                                          shape: BoxShape.circle,
                                        )),
                                    Icon(
                                      Icons.facebook_outlined,
                                      color: Colors.white,
                                      size: 50,
                                    ),
                                  ]).showCursorOnHover.moveUpOnHover,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _launchEmail(
                                        "mailto:pbmindsacademy@gmail.com?subject=Concerns&body=My concern is about?");
                                  },
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.alternate_email,
                                      color: Color.fromARGB(255, 1, 93, 168),
                                      size: 40,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _makePhoneCall("+639919382645");
                                  },
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.call,
                                      color: Color.fromARGB(255, 1, 93, 168),
                                      size: 30,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _LocationURL(
                                        "https://www.google.com/maps/place/Prime+Brilliant+Minds+Academy/@16.0168431,120.3119883,17z/data=!3m1!4b1!4m6!3m5!1s0x33915d7291b3b4d3:0x6b994ae103d607e5!8m2!3d16.016838!4d120.3145632!16s%2Fg%2F11f6xybt1w?entry=ttu&g_ep=EgoyMDI0MTAwMS4wIKXMDSoASAFQAw%3D%3D");
                                  },
                                  child: Container(
                                    width: 50.0,
                                    height: 50.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: Color.fromARGB(255, 1, 93, 168),
                                      size: 40,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                                SizedBox(
                                  width: 6,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _TESDAURL(
                                        "https://tesdatrainingcourses.com/prime-brilliant-minds-academy.html");
                                  },
                                  child: Container(
                                      width: 50.0,
                                      height: 50.0,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.white, width: 4),
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        "assets/tesda.png",
                                        fit: BoxFit.cover,
                                      )).moveUpOnHover.showCursorOnHover,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 40),
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        child: Text(
                          "Dedicated to shaping the minds of tomorrow by providing high-quality education, a supportive community, and opportunities for every student to thrive.",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: "R",
                              color: Colors.white),
                        ),
                      ),
                      Container(
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.contact_phone,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 30,),
                                Text("09754724092\t\t or \t\t09754724092", style: TextStyle(fontSize: 15, fontFamily: "M", color: Colors.white),),
                                
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 30,),
                                Text("pbmindsacademy@gmail.com", style: TextStyle(fontSize: 15, fontFamily: "M", color: Colors.white),),
                                
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width / 4),
                height: 420,
                //color: Colors.green,
                child: Column(
                  children: [],
                ),
              ),
              Container(
                width: (MediaQuery.of(context).size.width / 4),
                height: 420,
                // color: Colors.purple,
                child: Column(
                  children: [
                    Text("")
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
