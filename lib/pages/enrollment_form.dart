import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:pbma_portal/pages/enrollment_form_sector/uploading_files.dart';

class EnrollmentForm extends StatefulWidget {
  @override
  State<EnrollmentForm> createState() => _EnrollmentFormState();
}

class _EnrollmentFormState extends State<EnrollmentForm> {
  Color _appBarColor = Colors.transparent;

  Color _textColor1 = Color.fromARGB(255, 1, 93, 168);
  Color _textColor2 = Color.fromARGB(255, 1, 93, 168);
  Color _textColor3 = Color.fromARGB(255, 1, 93, 168);

  bool _isSubmitting = false;

  bool _showSignInCard = false;
     bool _isHoveringDashboard = false;


  // Define the reset functions for each form section
  final GlobalKey<StudentInformationState> _studentInfoKey = GlobalKey();
  final GlobalKey<JuniorHighSchoolState> _juniorHSKey = GlobalKey();
  final GlobalKey<HomeAddressState> _homeAddressKey = GlobalKey();
  final GlobalKey<ParentInformationState> _parentInfoKey = GlobalKey();
  final GlobalKey<SeniorHighSchoolState> _seniorHSKey = GlobalKey();
  final GlobalKey<UploadingFilesState> _uploadFilesKey = GlobalKey();
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

  List<PlatformFile> _selectedFiles = [];

  // Method to update selected files list
  void _updateSelectedFiles(List<PlatformFile> files) {
    setState(() {
      _selectedFiles = files;
    });
  }

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
      setState(() {
        _isSubmitting = true; // Show progress indicator
      });

      try {
        String? imageUrl;

        if (_imageFile != null || _webImageData != null) {
          final storageRef = FirebaseStorage.instance.ref();
          final imageRef = storageRef.child('student_pictures/${DateTime.now().toIso8601String()}.png');

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
            return;
          }
        }

        List<String> fileUrls = [];
        for (var file in _selectedFiles) {
          try {
            final fileRef = FirebaseStorage.instance.ref().child('uploads/${file.name}');
            final uploadTask = file.bytes != null ? fileRef.putData(file.bytes!) : fileRef.putFile(File(file.path!));
            final snapshot = await uploadTask;
            final downloadUrl = await snapshot.ref.getDownloadURL();
            fileUrls.add(downloadUrl);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to Upload File ${file.name}: $e')),
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
          'file_urls': fileUrls,
        };

        await FirebaseFirestore.instance.collection('users').add(combinedData);

        showCupertinoDialog(
          context: context,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text("Important Notice"),
              content: Text(
                "To validate your enrollment, please submit the following documents to the school within 15 days:\n\n"
                "- Birth Certificate\n"
                "- 2x2 Picture\n"
                "- Form 137 from previous school\n\n"
                "Failure to submit these documents within the specified timeframe will result in the rejection of your enrollment request.",
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Data Saved Successfully')),
                    );
                    _resetForm();
                  },
                ),
              ],
            );
          },
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to Save Data: $error')),
        );
      } finally {
        setState(() {
          _isSubmitting = false; // Hide progress indicator
        });
      }
    }
  }

  void _resetForm() {
    // Reset all form fields
    _studentInfoKey.currentState?.resetFields();
    _juniorHSKey.currentState?.resetForm();
    _homeAddressKey.currentState?.resetForm();
    _parentInfoKey.currentState?.resetForm();
    _seniorHSKey.currentState?.resetFields();
    _uploadFilesKey.currentState?.resetFields();
    _updateImageFile(null);
    _updateWebImageData(null);
    _updateImageUrl(null);
    _updateSelectedFiles([]);
  }

@override
Widget build(BuildContext context) {
  final Size screenSize = MediaQuery.of(context).size;
  double screenWidth = screenSize.width;

  return Material(
    color: Colors.white,
    child: SingleChildScrollView(
      child: Container(
        color: Colors.white, 
        child: Column(
          children: [
            // Header Section
            Container(
              height: 75,
              color: Color.fromARGB(255, 1, 93, 168),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.asset(
                          "assets/pbma.jpg",
                          height: 60,
                          width: 60,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "PBMA",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "B",
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Breadcrumb Section
            Container(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    onEnter: (_) => setState(() => _isHoveringDashboard = true),
                    onExit: (_) => setState(() => _isHoveringDashboard = false),
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
                          color: _isHoveringDashboard ? Colors.blue : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey),
                  Text(
                    "Enrollment",
                    style: TextStyle(
                      color: _isHoveringDashboard ? Colors.black : Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Container(
              padding: EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student Information Section
                    StudentInformation(
                      key: _studentInfoKey,
                      spacing: 50.0,
                      onDataChanged: _updateStudentData,
                      onImageFileChanged: _updateImageFile,
                      onWebImageDataChanged: _updateWebImageData,
                      onImageUrlChanged: _updateImageUrl,
                    ),
                    SizedBox(height: 30),

                    // Home Address Section
                    HomeAddress(
                      key: _homeAddressKey,
                      spacing: 50.0,
                      onDataChanged: _updateStudentData,
                    ),
                    SizedBox(height: 30),

                    // Parent Information Section
                    ParentInformation(
                      key: _parentInfoKey,
                      spacing: 50.0,
                      onDataChanged: _updateStudentData,
                    ),
                    SizedBox(height: 30),

                    // Junior High School Section
                    JuniorHighSchool(
                      key: _juniorHSKey,
                      onDataChanged: _updateStudentData,
                    ),
                    SizedBox(height: 30),

                    // Senior High School Section
                    SeniorHighSchool(
                      key: _seniorHSKey,
                      spacing: 50.0,
                      onDataChanged: _updateStudentData,
                    ),
                    SizedBox(height: 30),

                    // Uploading Files Section
                    UploadingFiles(
                      key: _uploadFilesKey,
                      spacing: 8.0,
                      onFilesSelected: _updateSelectedFiles,
                    ),
                    SizedBox(height: 30),

                    Center(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double screenWidth = MediaQuery.of(context).size.width;
                          // Dynamically adjust the button size for different screen widths
                          final double buttonWidth = screenWidth < 600 ? screenWidth * 0.8 : screenWidth / 8;
                          final double buttonHeight = screenWidth < 600 ? 50 : screenWidth / 35;

                          return SizedBox(
                            width: buttonWidth,
                            height: buttonHeight,
                            child: TextButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                  Color.fromARGB(255, 1, 93, 168),
                                ),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              onPressed: _isSubmitting ? null : _submitForm,
                              child: _isSubmitting ?
                              SizedBox(height: 20, width: 20, 
                              child: CircularProgressIndicator(color: Colors.yellow, strokeWidth: 2.0,),)
                              : Text(
                                "Submit",
                                style: TextStyle(
                                  fontFamily: "B",
                                  fontSize: screenWidth < 600 ? 16 : 12, // Adjust font size for small screens
                                  color: Colors.yellow,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
