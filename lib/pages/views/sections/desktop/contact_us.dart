import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:pbma_portal/widgets/hover_extensions.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  // URL launch functions
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

  // Map zoom functions
  final MapController _mapController = MapController();
  double _currentZoom = 16.0;
  LatLng _currentCenter = LatLng(16.0169146, 120.3144147);

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
      _mapController.move(_currentCenter, _currentZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
      _mapController.move(_currentCenter, _currentZoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        height: screenWidth/3.28,
        color: Color.fromARGB(255, 1, 93, 168),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 80),
          child: Row(
            children: [
              // Left panel content
              Container(
                width: (MediaQuery.of(context).size.width / 3) + 67,
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                          right: BorderSide(color: Colors.yellow, width: 2))),
                  margin: EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Social media and contact icons
                      Container(
                        margin: EdgeInsets.only(right: 40),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.yellow, width: 2))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth/35,
                              height: screenWidth/35,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                "assets/PBMA.png",
                                width: screenWidth/35,
                              height: screenWidth/35,
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
                                        width: screenWidth/35,
                              height: screenWidth/35,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 5),
                                          shape: BoxShape.circle,
                                        )),
                                    Icon(
                                      Icons.facebook_outlined,
                                      color: Colors.white,
                                      size: screenWidth/35,
                                    ),
                                  ]).showCursorOnHover.moveUpOnHover,
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    _launchEmail(
                                        "mailto:pbmindsacademy@gmail.com?subject=Concerns&body=My concern is about?");
                                  },
                                  child: Container(
                                    width: screenWidth/35,
                              height: screenWidth/35,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.alternate_email,
                                      color: Color.fromARGB(255, 1, 93, 168),
                                      size: screenWidth/40,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    _makePhoneCall("+639919382645");
                                  },
                                  child: Container(
                                    width: screenWidth/35,
                              height: screenWidth/35,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.call,
                                      color: Color.fromARGB(255, 1, 93, 168),
                                      size: screenWidth/45,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    _LocationURL(
                                        "https://www.google.com/maps/place/Prime+Brilliant+Minds+Academy/@16.0168431,120.3119883,17z/data=!3m1!4b1!4m6!3m5!1s0x33915d7291b3b4d3:0x6b994ae103d607e5!8m2!3d16.016838!4d120.3145632!16s%2Fg%2F11f6xybt1w?entry=ttu&g_ep=EgoyMDI0MTAwMS4wIKXMDSoASAFQAw%3D%3D");
                                  },
                                  child: Container(
                                    width: screenWidth/35,
                              height: screenWidth/35,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: Color.fromARGB(255, 1, 93, 168),
                                      size: screenWidth/40,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                                SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    _TESDAURL(
                                        "https://tesdatrainingcourses.com/prime-brilliant-minds-academy.html");
                                  },
                                  child: Container(
                                    width: screenWidth/35,
                              height: screenWidth/35,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.white, width: 4),
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      "assets/tesda.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ).moveUpOnHover.showCursorOnHover,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Description
                      Container(
                        margin: EdgeInsets.only(right: 40),
                        child: Text(
                          "Dedicated to shaping the minds of tomorrow by providing high-quality education, a supportive community, and opportunities for every student to thrive.",
                          style: TextStyle(
                            fontSize: screenWidth/75,
                            fontFamily: "R",
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Contact details
                      Container(
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.contact_phone,
                                  size: screenWidth/55,
                                  color: Colors.white,
                                ),
                                SizedBox(width: screenWidth/80),
                                Text(
                                  "09754724092\t\t or \t\t09754724092",
                                  style: TextStyle(
                                      fontSize: screenWidth/90,
                                      fontFamily: "M",
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  size: screenWidth/55,
                                  color: Colors.white,
                                ),
                                SizedBox(width: screenWidth/80),
                                Text(
                                  "pbmindsacademy@gmail.com",
                                  style: TextStyle(
                                      fontSize: screenWidth/90,
                                      fontFamily: "M",
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Map section with zoom buttons  
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 40),
                  color: Colors.green,
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: LatLng(16.0169146, 120.3144147),
                          initialZoom: _currentZoom,
                          maxZoom: 18,
                          minZoom: 1,
                        ),
                        children: [
                          TileLayer(
                            tileProvider: CancellableNetworkTileProvider(),
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.pbma_portal',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(16.0169146, 120.3144147),
                                width: screenWidth/25,
                                height: screenWidth/25,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red,
                                  size: screenWidth/30,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              onPressed: _zoomIn,
                              child: Icon(Icons.zoom_in),
                              mini: true,
                            ),
                            SizedBox(height: 10),
                            FloatingActionButton(
                              onPressed: _zoomOut,
                              child: Icon(Icons.zoom_out),
                              mini: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
