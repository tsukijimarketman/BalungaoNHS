import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StudentInformation extends StatefulWidget {
  final double spacing;
  final Function(Map<String, dynamic>) onDataChanged;
  final Function(File?) onImageFileChanged;
  final Function(Uint8List?) onWebImageDataChanged;
  final Function(String?) onImageUrlChanged;

  StudentInformation({
    required this.spacing,
    required this.onDataChanged,
    required this.onImageFileChanged,
    required this.onWebImageDataChanged,
    required this.onImageUrlChanged,
  });

  @override
  State<StudentInformation> createState() => _StudentInformationState();
}

class _StudentInformationState extends State<StudentInformation>
    with AutomaticKeepAliveClientMixin {
  final FocusNode _lrnFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _genderFocusNode = FocusNode();
  final FocusNode _birthdateFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _indigenousFocusNode = FocusNode();

  final FocusNode _middleNameFocusNode = FocusNode();
  final FocusNode _extensionNameFocusNode = FocusNode();

  final TextEditingController _lrnController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _extensionNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _emailAddressController = TextEditingController();
  final TextEditingController _indigenousController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();

  String _gender = '';
  String _indigenousGroup = '';
  File? _imageFile;
  Uint8List? _webImageData;
  String? _imageUrl;

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
    _indigenousController.addListener(_notifyParent);
    _genderController.addListener(_notifyParent);

    _lrnFocusNode.addListener(_onFocusChange);
    _lastNameFocusNode.addListener(_onFocusChange);
    _firstNameFocusNode.addListener(_onFocusChange);
    _middleNameFocusNode.addListener(_onFocusChange);
    _extensionNameFocusNode.addListener(_onFocusChange);
    _ageFocusNode.addListener(_onFocusChange);
    _birthdateFocusNode.addListener(_onFocusChange);
    _emailFocusNode.addListener(_onFocusChange);
    _indigenousFocusNode.addListener(_onFocusChange);
    _genderController.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _lrnController.dispose();
    _lrnFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _lastNameController.dispose();
    _firstNameFocusNode.dispose();
    _firstNameController.dispose();
    _middleNameFocusNode.dispose();
    _middleNameController.dispose();
    _extensionNameFocusNode.dispose();
    _extensionNameController.dispose();
    _ageFocusNode.dispose();
    _ageController.dispose();
    _birthdateFocusNode.dispose();
    _birthdateController.dispose();
    _emailFocusNode.dispose();
    _emailAddressController.dispose();
    _indigenousFocusNode.dispose();
    _indigenousController.dispose();
    _genderFocusNode.dispose();
    _genderController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  void _onFocusChange() {
    final TextEditingController _lrnController = TextEditingController();
    final TextEditingController _lastNameController = TextEditingController();
    final TextEditingController _firstNameController = TextEditingController();
    final TextEditingController _middleNameController = TextEditingController();
    final TextEditingController _extensionNameController = TextEditingController();
    final TextEditingController _ageController = TextEditingController();
    final TextEditingController _birthdateController = TextEditingController();
    final TextEditingController _emailAddressController = TextEditingController();
    final TextEditingController _indigenousController = TextEditingController();
    final TextEditingController _genderController = TextEditingController();
    final TextEditingController _contactNumberController = TextEditingController();
    
    String _gender = '';
    String _indigenousGroup = '';
    File? _imageFile;
    Uint8List? _webImageData;
    String? _imageUrl;

    // @override
    // void initState() {
    //   super.initState();
    //   _lrnController.addListener(_notifyParent);
    //   _lastNameController.addListener(_notifyParent);
    //   _firstNameController.addListener(_notifyParent);
    //   _middleNameController.addListener(_notifyParent);
    //   _extensionNameController.addListener(_notifyParent);
    //   _ageController.addListener(_notifyParent);
    //   _birthdateController.addListener(_notifyParent);
    //   _emailAddressController.addListener(_notifyParent);
    //   _indigenousController.addListener(_notifyParent);
    //   _genderController.addListener(_notifyParent);

    //   _lrnFocusNode.addListener(_onFocusChange);
    //   _lastNameFocusNode.addListener(_onFocusChange);
    //   _firstNameFocusNode.addListener(_onFocusChange);
    //   _middleNameFocusNode.addListener(_onFocusChange);
    //   _extensionNameFocusNode.addListener(_onFocusChange);
    //   _ageFocusNode.addListener(_onFocusChange);
    //   _birthdateFocusNode.addListener(_onFocusChange);
    //   _emailFocusNode.addListener(_onFocusChange);
    //   _indigenousFocusNode.addListener(_onFocusChange);
    //   _genderController.addListener(_notifyParent);
    // }

    //  @override
    //   void dispose() {
    //     _lrnController.dispose();
    //     _lrnFocusNode.dispose();
    //     _lastNameFocusNode.dispose();
    //     _lastNameController.dispose();
    //     _firstNameFocusNode.dispose();
    //     _firstNameController.dispose();
    //     _middleNameFocusNode.dispose();
    //     _middleNameController.dispose();
    //     _extensionNameFocusNode.dispose();
    //     _extensionNameController.dispose();
    //     _ageFocusNode.dispose();
    //     _ageController.dispose();
    //     _birthdateFocusNode.dispose();
    //     _birthdateController.dispose();
    //     _emailFocusNode.dispose();
    //     _emailAddressController.dispose();
    //     _indigenousFocusNode.dispose();
    //     _indigenousController.dispose();
    //     _genderFocusNode.dispose();
    //     _genderController.dispose();
    //     super.dispose();
    // }
  
    void _onFocusChange() {
    setState(() {});
    }
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
                    focusNode: _lrnFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Learner Reference Number',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_lrnFocusNode.hasFocus || _lrnController.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red, // Red color for the asterisk
                            ),
                            ),
                        ],
                      ),
                    ),
                      
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
                    onChanged: (text) {
                      setState(() {});
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
                                  Iconsax.profile_circle_copy,
                                  color: Color.fromARGB(255, 101, 100, 100),
                                  size: 50.0,
                                ),
                                // Text(
                                //   '2x2 picture',
                                //   style: TextStyle(color: Color.fromARGB(255, 101, 100, 100)),
                                //   textAlign: TextAlign.center,
                                // ),
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
                SizedBox(width: 8.0),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                  children: [
                    OutlinedButton(
                      onPressed: _pickImage, // Your existing function
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.blue), // Border color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5), // Rounded corners with radius 10
                        ),
                        minimumSize: Size(40, 30), // Minimum width and height
                      ),
                      child: Text(
                        'Choose Files',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.0), // Space between the button and text
                    Text(
                      "Upload your 2x2 picture",
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.black, // Customize the text color
                      ),
                    ),
                  ],
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
                    focusNode: _lastNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Last Name',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_lastNameFocusNode.hasFocus || _lastNameController.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red, // Red color for the asterisk
                            ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _firstNameController,
                    focusNode: _firstNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'First Name',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_firstNameFocusNode.hasFocus || _firstNameController.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red, // Red color for the asterisk
                            ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _middleNameController,
                    focusNode: _middleNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Middle Name',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_middleNameFocusNode.hasFocus || _middleNameController.text.isNotEmpty)
                          TextSpan(
                            text: '(optional)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 101, 100, 100), // Red color for the asterisk
                            ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
                    },
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
                    focusNode: _extensionNameFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Extension Name',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_extensionNameFocusNode.hasFocus || _extensionNameController.text.isNotEmpty)
                          TextSpan(
                            text: '(optional)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 101, 100, 100),
                            ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _ageController,
                    focusNode: _ageFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Age',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_ageFocusNode.hasFocus || _ageController.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,                             ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
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
                    focusNode: _birthdateFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Birthdate',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_birthdateFocusNode.hasFocus || _birthdateController.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,                             ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: widget.spacing),
                Container(
                  width: 300,
                  child: TextFormField(
                    controller: _emailAddressController,
                    focusNode: _emailFocusNode,
                    decoration: InputDecoration(
                      labelText: null,
                      label: RichText(text: TextSpan(
                        text: 'Email Address',
                        style: TextStyle(
                          color: Color.fromARGB(255, 101, 100, 100),
                          fontSize: 16,
                        ),
                        children: [
                          if (_emailFocusNode.hasFocus || _emailAddressController.text.isNotEmpty)
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: Colors.red,                             ),
                            ),
                        ],
                      ),
                    ),
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
                    onChanged: (text) {
                      setState(() {});
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