import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SubmitButtonHandler {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> studentData;
  final Map<String, dynamic> homeAddressData;
  final Map<String, dynamic> juniorHSData;
  final Map<String, dynamic> parentInfoData;
  final Map<String, dynamic> seniorHSData;
  final File? imageFile;
  final Uint8List? webImageData;
  final BuildContext context;

  SubmitButtonHandler({
    required this.formKey,
    required this.studentData,
    required this.homeAddressData,
    required this.juniorHSData,
    required this.parentInfoData,
    required this.seniorHSData,
    required this.imageFile,
    required this.webImageData,
    required this.context,
  });

  Future<void> handleSubmit() async {
    if (formKey.currentState!.validate()) {
      String? imageUrl;

      if (imageFile != null || webImageData != null) {
        final storageRef = FirebaseStorage.instance.ref();
        final imageRef = storageRef.child('student_pictures/${DateTime.now().toIso8601String()}.png');

        try {
          if (kIsWeb && webImageData != null) {
            await imageRef.putData(webImageData!);
          } else if (imageFile != null) {
            await imageRef.putFile(imageFile!);
          }
          imageUrl = await imageRef.getDownloadURL();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to Upload Image: $e')),
          );
        }
      }

      final combinedData = {
        ...studentData,
        ...homeAddressData,
        ...juniorHSData,
        ...parentInfoData,
        ...seniorHSData,
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
}
