  import 'dart:io';
  import 'dart:html' as html;
  import 'dart:typed_data';
  import 'package:flutter/foundation.dart';
  import 'package:flutter/material.dart';
  import 'package:image_picker/image_picker.dart';
  import 'package:firebase_storage/firebase_storage.dart';

  class StudentInformation extends StatefulWidget {
    final double spacing;
    final Function(Map<String, dynamic>) onDataChanged;
    final Function(File?) onImageFileChanged;
  final Function(Uint8List?) onWebImageDataChanged;
  final Function(String?) onImageUrlChanged;

    StudentInformation({required this.spacing,
    required this.onDataChanged,
    required this.onImageFileChanged,
    required this.onWebImageDataChanged,
    required this.onImageUrlChanged,});

    @override
    State<StudentInformation> createState() => _StudentInformationState();
  }

  class _StudentInformationState extends State<StudentInformation> {
    final TextEditingController _lrnController = TextEditingController();
    final TextEditingController _lastNameController = TextEditingController();
    final TextEditingController _firstNameController = TextEditingController();
    final TextEditingController _middleNameController = TextEditingController();
    final TextEditingController _extensionNameController = TextEditingController();
    final TextEditingController _ageController = TextEditingController();
    final TextEditingController _birthdateController = TextEditingController();
    final TextEditingController _emailAddressController = TextEditingController();
    String _gender = '';
    String _indigenousGroup = '';
    File? _imageFile;
    Uint8List? _webImageData;
    String? _imageUrl;

    Future<void> _pickImage() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final reader = html.FileReader();
        reader.readAsArrayBuffer(files[0]!);
        reader.onLoadEnd.listen((e) {
          final imageData = reader.result as Uint8List;
          setState(() {
            _webImageData = imageData;
            widget.onWebImageDataChanged(imageData);
          });
        });
      });
    } else {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
           _imageFile = File(pickedFile.path);
          widget.onImageFileChanged(File(pickedFile.path));
        });
      }
    }
  }


    Future<void> _uploadImage() async {
    if (_imageFile == null && _webImageData == null) return;

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('student_pictures/${DateTime.now().toIso8601String()}.png');

    try {
      if (kIsWeb) {
        await imageRef.putData(_webImageData!);
      } else {
        await imageRef.putFile(_imageFile!);
      }

      final imageUrl = await imageRef.getDownloadURL();
      widget.onImageUrlChanged(imageUrl); 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image Uploaded Successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to Upload Image: $e')),
      );
    }
  }


    @override
    void initState() {
      super.initState();
      _lrnController.addListener(_notifyParent);
      _lastNameController.addListener(_notifyParent);
      _firstNameController.addListener(_notifyParent);
      _middleNameController.addListener(_notifyParent);
      _extensionNameController.addListener(_notifyParent);
      _ageController.addListener(_notifyParent);
      _birthdateController.addListener(_notifyParent);
      _emailAddressController.addListener(_notifyParent);
    }

    void _notifyParent() {
      widget.onDataChanged(getFormData());
    }

    Map<String, dynamic> getFormData() {
      return {
        'lrn': _lrnController.text,
        'last_name': _lastNameController.text,
        'first_name': _firstNameController.text,
        'middle_name': _middleNameController.text,
        'extension_name': _extensionNameController.text,
        'age': _ageController.text,
        'birthdate': _birthdateController.text,
        'gender': _gender,
        'indigenous_group': _indigenousGroup,
        'email_Address': _emailAddressController.text,
      };
    }

    @override
    Widget build(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Student Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _lrnController,
                    decoration: InputDecoration(
                      labelText: 'Learner Reference Number',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your LRN';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2.0),
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: _imageFile == null && _webImageData == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  color: Color.fromARGB(255, 101, 100, 100),
                                  size: 40.0,
                                ),
                                Text(
                                  '2x2 picture',
                                  style: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : (_webImageData != null
                            ? Image.memory(
                                _webImageData!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                _imageFile!,
                                fit: BoxFit.cover,
                              )),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _middleNameController,
                    decoration: InputDecoration(
                      labelText: 'Middle Name',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _extensionNameController,
                    decoration: InputDecoration(
                      labelText: 'Extension Name',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(
                      labelText: 'Age',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your age';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    value: _gender.isEmpty ? null : _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                        _notifyParent();
                      });
                    },
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _birthdateController,
                    decoration: InputDecoration(
                      labelText: 'Birthdate',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your birthdate';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _emailAddressController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Email Address';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: DropdownButtonFormField<String>(
                    value: _indigenousGroup.isEmpty ? null : _indigenousGroup,
                    onChanged: (value) {
                      setState(() {
                        _indigenousGroup = value!;
                        _notifyParent();
                      });
                    },
                    items: ['Yes', 'No'].map((group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Belonging to any Indigenous People (IP) Group?',
                      labelStyle: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        borderSide: BorderSide(color: Colors.blue, width: 2.0),
                      ),
                    ),

                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }