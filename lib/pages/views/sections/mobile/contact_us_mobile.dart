import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUsMobile extends StatefulWidget {
  const ContactUsMobile({super.key});

  @override
  State<ContactUsMobile> createState() => _ContactUsMobileState();
}

class _ContactUsMobileState extends State<ContactUsMobile> {
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

  // Map controller and zoom functions
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
    double screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        color: Color(0xFF03b97c),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
              // Top section with social media and contact details
              Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.yellow, width: 2)),
                ),
                child: Column(
                  children: [
                    // Logo and social media icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: screenWidth / 10,
                          height: screenWidth / 10,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            "assets/balungaonhs.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _launchURL("https://www.facebook.com/PrimeAcademyOfficial/");
                              },
                              child: Icon(
                                Icons.facebook_outlined,
                                color: Colors.white,
                                size: screenWidth / 8.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _launchEmail("mailto:pbmindsacademy@gmail.com?subject=Concerns&body=My concern is about?");
                              },
                              child: Container(
                                width: screenWidth / 10,
                                height: screenWidth / 10,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.alternate_email,
                                  color: Color(0xFF03b97c),
                                  size: screenWidth / 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _makePhoneCall("+639919382645");
                              },
                              child: Container(
                                width: screenWidth / 10,
                                height: screenWidth / 10,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.call,
                                  color: Color(0xFF03b97c),
                                  size: screenWidth / 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                _LocationURL("https://www.google.com/maps/place/Prime+Brilliant+Minds+Academy/@16.0168431,120.3119883,17z/data=!3m1!4b1!4m6!3m5!1s0x33915d7291b3b4d3:0x6b994ae103d607e5!8m2!3d16.016838!4d120.3145632!16s%2Fg%2F11f6xybt1w?entry=ttu&g_ep=EgoyMDI0MTAwMS4wIKXMDSoASAFQAw%3D%3D");
                              },
                              child: Container(
                                width: screenWidth / 10,
                                height: screenWidth / 10,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: Color(0xFF03b97c),
                                  size: screenWidth / 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    // Description
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Dedicateds to shaping the minds of tomorrow by providing high-quality education, a supportive community, and opportunities for every student to thrive.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth / 30,
                          fontFamily: "R",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Contact details
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.contact_phone,
                          size: screenWidth / 35,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "09754724092 or 09754724092",
                          style: TextStyle(
                            fontSize: screenWidth / 30,
                            fontFamily: "M",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.email,
                          size: screenWidth / 35,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "pbmindsacademy@gmail.com",
                          style: TextStyle(
                            fontSize: screenWidth / 30,
                            fontFamily: "M",
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Map section
              Container(
                width: MediaQuery.of(context).size.width/1.2,
                height: MediaQuery.of(context).size.width/2,
                margin: EdgeInsets.symmetric(vertical: 20),
                color: Colors.green,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentCenter,
                        initialZoom: _currentZoom,
                        maxZoom: 18,
                        minZoom: 1,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.pbma_portal',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentCenter,
                              width: screenWidth / 20,
                              height: screenWidth / 20,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: screenWidth / 25,
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
                          SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
