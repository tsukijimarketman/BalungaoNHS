import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pbma_portal/launcher.dart';
import 'package:pbma_portal/pages/Auth_View/SignInDesktopView.dart';
import 'package:pbma_portal/pages/dashboard.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/home_address.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/junior_high_school.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/parent_information.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/senior_high_school.dart';
import 'package:pbma_portal/pages/enrollment_form_sector/student_information.dart';

class EnrollmentForm extends StatefulWidget {
  @override
  State<EnrollmentForm> createState() => _EnrollmentFormState();
}

class _EnrollmentFormState extends State<EnrollmentForm> {
  Color _appBarColor = Colors.transparent;

  Color _textColor1 = Color.fromARGB(255, 1, 93, 168);
  Color _textColor2 = Color.fromARGB(255, 1, 93, 168);
  Color _textColor3 = Color.fromARGB(255, 1, 93, 168);

  bool _showSignInCard = false;

  // Define the _formKey
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  Uint8List? _webImageData;
  String? _imageUrl;

  Map<String, dynamic> _studentData = {};
  Map<String, dynamic> _homeAddressData = {};
  Map<String, dynamic> _juniorHSData = {};
  Map<String, dynamic> _parentInfoData = {};
  Map<String, dynamic> _seniorHSData = {};

  void _updateStudentData(Map<String, dynamic> data) {
    setState(() {
      _studentData = {..._studentData, ...data};
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

  void _updateImageFile(File? imageFile) {
    setState(() {
      _imageFile = imageFile;
    });
  }

  void _updateWebImageData(Uint8List? webImageData) {
    setState(() {
      _webImageData = webImageData;
    });
  }

  void _updateImageUrl(String? imageUrl) {
    setState(() {
      _imageUrl = imageUrl;
    });
  }

  void _updateHomeAddressData(Map<String, dynamic> data) {
    setState(() {
      _homeAddressData = data;
    });
  }

  void _updateJuniorHSData(Map<String, dynamic> data) {
    setState(() {
      _juniorHSData = data;
    });
  }

  void _updateParentInfo(Map<String, dynamic> data) {
    setState(() {
      _parentInfoData = data;
    });
  }

  void _updateSeniorHS(Map<String, dynamic> data) {
    setState(() {
      _seniorHSData = data;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String? imageUrl;

      if (_imageFile != null || _webImageData != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef =
            storageRef.child('student_pictures/${DateTime.now().toIso8601String()}.png');

        try {
          if (kIsWeb && _webImageData != null) {
            await imageRef.putData(_webImageData!);
          } else if (_imageFile != null) {
            await imageRef.putFile(_imageFile!);
          }

          imageUrl = await imageRef.getDownloadURL();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to Upload Image: $e')),
          );
        }
      }

      final combinedData = {
        ..._studentData,
        ..._homeAddressData,
        ..._juniorHSData,
        ..._parentInfoData,
        ..._seniorHSData,
        'enrollment_status': 'pending',
        'image_url': imageUrl,
      };

      FirebaseFirestore.instance.collection('users').add(combinedData).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data Saved Successfully')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Save Data: $error')),
        );
      });
    }
  }




  @override
Widget build(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  double screenWidth = screenSize.width;
  double screenHeight = screenSize.height;

  // double formFieldWidth = screenSize.width > 600 ? 300 : screenSize.width * 0.9;
  double spacing = 50.0;

  return Scaffold(
    appBar: AppBar(
      toolbarHeight: screenWidth / 16,
      elevation: 8,
      backgroundColor: _appBarColor,
      title: Container(
        child: Row(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      "assets/pbma.jpg",
                      height: screenWidth / 20,
                      width: screenWidth / 20,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "PBMA",
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: "B",
                    fontSize: screenWidth / 50,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
              Spacer(),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _textColor1 = Colors.black;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _textColor1 = Color.fromARGB(255, 1, 93, 168);
                  });
                },
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Launcher()),
                    );
                  },
                  child: Text(
                    "Dashboard",
                    style: TextStyle(
                      fontFamily: "SB",
                      fontSize: 14,
                      color: _textColor1, // Dynamic color
                    ),
                  ),
                ),
              ),
              SizedBox(width: 25),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _textColor2 = Colors.black;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _textColor2 = Color.fromARGB(255, 1, 93, 168);;
                  });
                },
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    "About us",
                    style: TextStyle(
                      fontFamily: "SB",
                      fontSize: 14,
                      color: _textColor2, // Dynamic color
                    ),
                  ),
                ),
              ),
              SizedBox(width: 25),
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _textColor3 = Colors.black;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _textColor3 = Color.fromARGB(255, 1, 93, 168);
                  });
                },
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Contact us",
                    style: TextStyle(
                      fontFamily: "SB",
                      fontSize: 14,
                      color: _textColor3, // Dynamic color
                    ),
                  ),
                ),
              ),
              SizedBox(width: 25),
              SizedBox(
                width: screenWidth / 12,
                height: screenWidth / 35,
                child: TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.yellow),
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
                      color: Color.fromARGB(255, 1, 93, 168),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [ Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                StudentInformation(
                  spacing: spacing,
                  onDataChanged: _updateStudentData,
                  onImageFileChanged: _updateImageFile,
                  onWebImageDataChanged: _updateWebImageData,
                  onImageUrlChanged: _updateImageUrl,
                ),
                SizedBox(height: 30),
                HomeAddress(
                  spacing: spacing,
                  onDataChanged: _updateStudentData,
                ),
                SizedBox(height: 30),
                ParentInformation(
                  spacing: spacing,
                  onDataChanged: _updateStudentData,
                ),
                SizedBox(height: 30),
                JuniorHighSchool(
                  onDataChanged: _updateStudentData,
                ),
                SizedBox(height: 30),
                SeniorHighSchool(
                  spacing: spacing,
                  onDataChanged: _updateStudentData,
                ),
                SizedBox(height: 30),
                Center(
                  child: SizedBox(
                    width: screenWidth / 8,
                    height: screenWidth / 35,
                    child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 1, 93, 168)),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      onPressed:_submitForm,
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontFamily: "B",
                          fontSize: 14,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // ElevatedButton(
                //   onPressed: _submitForm,
                //   child: Text('Submit'),
                // ),
              ],
            ),
            
          ),
        ),
        AnimatedSwitcher(
            duration: Duration(milliseconds: 550),
            child: _showSignInCard
                ? Positioned.fill(
                    child: GestureDetector(
                      onTap: closeSignInCard,
                      child: Stack(
                        children: [
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child:
                                Container(color: Colors.black.withOpacity(0.5)),
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
                  )
                : SizedBox.shrink(),
          ),
        ]
      ),
      
      
    );
  }
}
