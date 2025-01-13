// ignore_for_file: unused_field, unused_import, unused_element

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:balungao_nhs/pages/enrollment_form_sector/junior_highschool_enrollment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/launcher.dart';
import 'package:balungao_nhs/pages/Auth_View/SignInDesktopView.dart';
import 'package:balungao_nhs/pages/dashboard.dart';
import 'package:balungao_nhs/pages/enrollment_form_sector/home_address.dart';
import 'package:balungao_nhs/pages/enrollment_form_sector/junior_high_school.dart';
import 'package:balungao_nhs/pages/enrollment_form_sector/parent_information.dart';
import 'package:balungao_nhs/pages/enrollment_form_sector/senior_high_school.dart';
import 'package:balungao_nhs/pages/enrollment_form_sector/student_information.dart';
import 'package:balungao_nhs/pages/enrollment_form_sector/uploading_files.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnrollmentForm extends StatefulWidget {
  @override
  State<EnrollmentForm> createState() => _EnrollmentFormState();
}

class _EnrollmentFormState extends State<EnrollmentForm> {
  final supabase = Supabase.instance.client;
  Color _appBarColor = Colors.transparent;

  Color _textColor1 = Color.fromARGB(255, 1, 93, 168);
  Color _textColor2 = Color.fromARGB(255, 1, 93, 168);
  Color _textColor3 = Color.fromARGB(255, 1, 93, 168);

  bool _isSubmitting = false;

  bool _showSignInCard = false;
  bool _isHoveringDashboard = false;

  String? selectededucLevel;

  // Define the reset functions for each form section
  final GlobalKey<StudentInformationState> _studentInfoKey = GlobalKey();
  final GlobalKey<JuniorHighSchoolState> _juniorHSKey = GlobalKey();
  final GlobalKey<JuniorHighSchoolEnrollmentState> _juniorHSinforKey =
      GlobalKey();
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
  Map<String, dynamic> _juniorHSDataInfo = {};

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

  void _updateJuniorHSInfo(Map<String, dynamic> data) {
    setState(() {
      _juniorHSDataInfo = data;
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
        List<String> fileUrls = [];
        // Handle profile image upload
        if (_webImageData != null) {
          try {
            const bucketName = 'Balungao NHS';
            final fileName =
                'student_pictures/${DateTime.now().millisecondsSinceEpoch}.png';
            await supabase.storage.from(bucketName).uploadBinary(
                  fileName,
                  _webImageData!,
                  fileOptions: const FileOptions(
                    contentType: 'image/png',
                    upsert: true,
                  ),
                );
            imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
            print('Successfully uploaded image: $imageUrl');
          } catch (e, stackTrace) {
            print('Upload error: $e');
            print('Stack trace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload profile image: $e')),
            );
            return;
          }
        }
        // Handle other file uploads
        for (var file in _selectedFiles) {
          try {
            const bucketName = 'Balungao NHS';
            final fileName =
                'uploads/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
            await supabase.storage.from(bucketName).uploadBinary(
                  fileName,
                  file.bytes!,
                  fileOptions: const FileOptions(
                    upsert: true,
                  ),
                );
            final fileUrl =
                supabase.storage.from(bucketName).getPublicUrl(fileName);

            fileUrls.add(fileUrl);
            print('Successfully uploaded file: $fileUrl');
          } catch (e, stackTrace) {
            print('File upload error: $e');
            print('Stack trace: $stackTrace');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload file ${file.name}: $e')),
            );
          }
        }

        String? semesterValue;
        if (selectededucLevel == 'Junior High School') {
          print('Fetching semester value for Junior High School...');
          final querySnapshot = await FirebaseFirestore.instance
              .collection('jhs configurations')
              .where('educ_level', isEqualTo: 'Junior High School')
              .where('isActive', isEqualTo: true)
              .limit(1)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            semesterValue = querySnapshot.docs.first.get('semester');
            print('Fetched semester value: $semesterValue');
          } else {
            print('No active JHS configuration found.');
          }
        } else {
          print('Skipping semester fetch for Senior High School.');
        }

        // Combine all data
        final combinedData = {
          ..._studentData,
          ..._homeAddressData,
          ..._juniorHSDataInfo,
          ..._juniorHSData,
          ..._parentInfoData,
          ..._seniorHSData,
          'enrollment_status': 'pending',
          'image_url': imageUrl,
          'file_urls': fileUrls,
          'educ_level': selectededucLevel,
          if (semesterValue != null)
            'quarter': semesterValue, // Add semester as quarter if found
        };

        // Save to Firestore
        await FirebaseFirestore.instance.collection('users').add(combinedData);
        // Show success dialog
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
                      SnackBar(
                        content: Row(
                          children: [
                            Image.asset('PBMA.png', scale: 40),
                            SizedBox(width: 10),
                            Text('Data Saved Successfully'),
                          ],
                        ),
                      ),
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
          SnackBar(
            content: Row(
              children: [
                Image.asset('PBMA.png', scale: 40),
                SizedBox(width: 10),
                Text('Failed to Save Data: $error'),
              ],
            ),
          ),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _resetForm() {
    // Reset all form fields
    _studentInfoKey.currentState?.resetFields();
    _juniorHSKey.currentState?.resetForm();
    _juniorHSinforKey.currentState?.resetFields();
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
                      onEnter: (_) =>
                          setState(() => _isHoveringDashboard = true),
                      onExit: (_) =>
                          setState(() => _isHoveringDashboard = false),
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
                            color: _isHoveringDashboard
                                ? Colors.blue
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey),
                    Text(
                      "Enrollment",
                      style: TextStyle(
                        color:
                            _isHoveringDashboard ? Colors.black : Colors.blue,
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
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double containerWidth = constraints.maxWidth > 600
                              ? constraints.maxWidth / 4.2
                              : constraints.maxWidth * 0.9;

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: containerWidth,
                              child: DropdownButtonFormField<String>(
                                value: selectededucLevel,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .blue, // Set the border color to blue
                                      width: 1.0, // Thickness of the border
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .blue, // Blue color when the field is not focused
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors
                                          .blue, // A slightly brighter blue when focused
                                      width: 1.0,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: '',
                                    child: Text('---'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Junior High School',
                                    child: Text('Junior High School Student'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Senior High School',
                                    child: Text('Senior High School Student'),
                                  ),
                                ],
                                onChanged: (value) async {
                                  if (value == 'Junior High School') {
                                    // Fetch semester for Junior High School
                                    try {
                                      final querySnapshot =
                                          await FirebaseFirestore
                                              .instance
                                              .collection('jhs configurations')
                                              .where(
                                                  'educ_level',
                                                  isEqualTo:
                                                      'Junior High School')
                                              .where('isActive',
                                                  isEqualTo: true)
                                              .limit(1)
                                              .get();

                                      if (querySnapshot.docs.isNotEmpty) {
                                        final semester = querySnapshot
                                            .docs.first
                                            .get('semester');
                                        if (semester != '1st') {
                                          // Show dialog for ongoing school year
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Text(
                                                  'Enrollment Closed',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                                content: Text(
                                                  'We are not currently accepting new students because \n the school year is already ongoing.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  Launcher()));
                                                    },
                                                    child: Text(
                                                      'OK',
                                                      style: TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          // Reset the dropdown selection
                                          setState(() {
                                            selectededucLevel = '';
                                          });
                                          return;
                                        }
                                      }
                                    } catch (e) {
                                      print('Error fetching semester: $e');
                                    }
                                  }

                                  // Update the selected educational level
                                  setState(() {
                                    selectededucLevel = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your Educational Level';
                                  }
                                  return null;
                                },
                                hint: Text('Select your educational level'),
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 30),
                      if (selectededucLevel == 'Junior High School') ...[
                        JuniorHighSchoolEnrollment(
                            key: _juniorHSinforKey,
                            spacing: 50.0,
                            onDataChanged: _updateStudentData),
                        SizedBox(height: 30),
                      ],
                      if (selectededucLevel == 'Senior High School') ...[
                        // Add square brackets for consistency
                        JuniorHighSchool(
                          key: _juniorHSKey,
                          onDataChanged: _updateStudentData,
                        ),
                        SizedBox(height: 30),
                        SeniorHighSchool(
                          // Move inside senior condition
                          key: _seniorHSKey,
                          spacing: 50.0,
                          onDataChanged: _updateStudentData,
                        ),
                      ],
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
                            final double screenWidth =
                                MediaQuery.of(context).size.width;
                            // Dynamically adjust the button size for different screen widths
                            final double buttonWidth = screenWidth < 600
                                ? screenWidth * 0.8
                                : screenWidth / 8;
                            final double buttonHeight =
                                screenWidth < 600 ? 50 : screenWidth / 35;

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
                                child: _isSubmitting
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.yellow,
                                          strokeWidth: 2.0,
                                        ),
                                      )
                                    : Text(
                                        "Submit",
                                        style: TextStyle(
                                          fontFamily: "B",
                                          fontSize: screenWidth < 600
                                              ? 16
                                              : 12, // Adjust font size for small screens
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
