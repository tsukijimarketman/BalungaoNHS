import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddInstructorDialog extends StatefulWidget {
  final double screenWidth;
  final double screenHeight;
  final VoidCallback closeAddInstructors;

  AddInstructorDialog({
    super.key,
    required this.closeAddInstructors,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  _AddInstructorDialogState createState() => _AddInstructorDialogState();
}

class _AddInstructorDialogState extends State<AddInstructorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _adviserStatus = '--';
  String? _selectedSection;
  List<String> _sections = [];
  List<String> _subjectNameSuggestions = [];
  List<String> _subjectCodeSuggestions = [];
  bool _isSubjectNameSelected = false; // Track whether a suggestion was selected
  bool _isSubjectCodeSelected = false; // Track whether a suggestion was selected for subject code
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _fetchSections();
    _fetchSubjects();
  }

  Future<void> _fetchSections() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('sections').get();
      final sections =
          snapshot.docs.map((doc) => doc['section_name'] as String).toList();
      setState(() {
        _sections = sections;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sections: $e')),
      );
    }
  }

  Future<void> _fetchSubjects() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('subjects').get();
      setState(() {
        _subjectNameSuggestions = snapshot.docs
            .map((doc) => doc['subject_name'].toString()) // Keep camel case
            .toList();
        _subjectCodeSuggestions = snapshot.docs
            .map((doc) => doc['subject_code'].toString()) // Keep camel case
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching subjects: $e')),
      );
    }
  }

  List<String> _filterSuggestions(String query, List<String> suggestions) {
    // Convert query to lowercase for case-insensitive matching
    String queryLower = query.toLowerCase();

    return suggestions
        .where((suggestion) => suggestion
            .toLowerCase()
            .contains(queryLower)) // Case-insensitive comparison
        .toSet() // Remove duplicates
        .toList();
  }

  Future<String?> _emailValidator(String? value) async {
  if (value == null || value.isEmpty) {
    return 'Please enter an email address';
  }

  // Convert entered email to lowercase to perform case-insensitive comparison
  String enteredEmail = value.trim().toLowerCase();

  // Call the function that checks if the email already exists (case-insensitive check)
  bool isInUse = await _isEmailInUse(enteredEmail);

  if (isInUse) {
    return 'Email is already in use';
  }

  return null;
}


Future<bool> _isEmailInUse(String email) async {
  try {
    // Query all users in Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    // Convert entered email to lowercase for case-insensitive comparison
    String emailLowerCase = email.toLowerCase();

    // Loop through the documents to compare case-insensitive email
    for (var doc in snapshot.docs) {
      String storedEmail = (doc['email_Address'] as String).toLowerCase(); // Convert stored email to lowercase

      // Check if the stored email matches the entered email
      if (storedEmail == emailLowerCase) {
        return true; // Email found, it's already in use
      }
    }

    return false; // Email not found
  } catch (e) {
    // Handle error if query fails
    print("Error checking email: $e");
    return false; // Default to email not found
  }
}


  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_adviserStatus == '--') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Please select a valid adviser status (Yes or No).')),
        );
        return;
      }

      final firstName = _firstNameController.text;
      final middleName = _middleNameController.text;
      final lastName = _lastNameController.text;
      final subjectName = _subjectNameController.text;
      final subjectCode = _subjectCodeController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      String handledSectionValue =
          _adviserStatus == 'yes' ? _selectedSection ?? 'N/A' : 'N/A';

      try {
      // Get the current Firebase options
      final options = Firebase.app().options;
      
      // Create a unique name for the temporary app
      final tempAppName = 'tempApp-${DateTime.now().millisecondsSinceEpoch}';

      // Initialize the temporary app with explicit options
      final tempApp = await Firebase.initializeApp(
        name: tempAppName,
        options: FirebaseOptions(
          apiKey: options.apiKey,
          appId: options.appId,
          messagingSenderId: options.messagingSenderId,
          projectId: options.projectId,
          authDomain: options.authDomain,
          storageBucket: options.storageBucket,
        ),
      );

      try {
        // Create auth instance from temporary app
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        
        // Create instructor account
        final userCredential = await tempAuth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final uid = userCredential.user?.uid;
        if (uid == null) {
          throw Exception('Failed to create user: No UID generated');
        }

        // Add instructor data to Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'first_name': firstName,
          'middle_name': middleName,
          'last_name': lastName,
          'subject_Name': subjectName,
          'subject_Code': subjectCode,
          'email_Address': email,
          'accountType': 'instructor',
          'Status': 'active',
          'adviser': _adviserStatus,
          'handled_section': handledSectionValue,
          'uid': uid,
        });

        // Clean up - sign out from temporary auth
        await tempAuth.signOut();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Instructor account added successfully!')),
        );
        widget.closeAddInstructors();
        
      } finally {
        // Ensure temporary app is deleted
        try {
          await tempApp.delete();
        } catch (deleteError) {
          print('Error deleting temporary app: $deleteError');
        }
      }
    } catch (e) {
      print('Error adding instructor: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create instructor account: ${e.toString()}')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.closeAddInstructors,
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                width: widget.screenWidth / 2,
                height: widget.screenHeight / 1.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: widget.closeAddInstructors,
                          style: TextButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                          ),
                          child:
                              Text('Back', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Add Teacher',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTextField(_firstNameController, 'First Name',
                                'Please enter a first name'),
                            _buildTextField(_middleNameController,
                                'Middle Name', 'Please enter a middle name'),
                            _buildTextField(_lastNameController, 'Last Name',
                                'Please enter a last name'),
                            // For subject name field
                            _buildSuggestionField(
                              _subjectNameController,
                              'Subject Name',
                              _subjectNameSuggestions,
                              _isSubjectNameSelected, // Track selection status for subject name
                              (suggestion) {
                                setState(() {
                                  _subjectNameController.text =
                                      suggestion; // Set the controller text to the selected suggestion
                                  _isSubjectNameSelected =
                                      true; // Mark as selected
                                });
                              },
                            ),

// For subject code field
                            _buildSuggestionField(
                              _subjectCodeController,
                              'Subject Code',
                              _subjectCodeSuggestions,
                              _isSubjectCodeSelected, // Track selection status for subject code
                              (suggestion) {
                                setState(() {
                                  _subjectCodeController.text =
                                      suggestion; // Set the controller text to the selected suggestion
                                  _isSubjectCodeSelected =
                                      true; // Mark as selected
                                });
                              },
                            ),
                            SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _adviserStatus,
                              decoration: InputDecoration(
                                  labelText: 'Adviser Status',
                                  border: OutlineInputBorder()),
                              items: [
                                DropdownMenuItem(
                                    value: '--', child: Text('--')),
                                DropdownMenuItem(
                                    value: 'yes', child: Text('Yes')),
                                DropdownMenuItem(
                                    value: 'no', child: Text('No')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _adviserStatus = value ?? '--';
                                  _selectedSection = null;
                                });
                              },
                              validator: (value) => value == null
                                  ? 'Please select adviser status'
                                  : null,
                            ),
                            if (_adviserStatus == 'yes')
                              DropdownButtonFormField<String>(
                                value: _selectedSection,
                                decoration: InputDecoration(
                                    labelText: 'Select Section'),
                                items: _sections.map((section) {
                                  return DropdownMenuItem(
                                    value: section,
                                    child: Text(section),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedSection = value;
                                  });
                                },
                              ),
                            SizedBox(height: 8),
                            TextFormField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: 'Email Address',
    border: OutlineInputBorder(),
    errorText: _emailError, // Display error message here
  ),
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) {
    setState(() {
      _emailError = null; // Clear error message on input change
    });
  },
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    // Synchronous check for email validation
    bool isInUse = false;
    _isEmailInUse(value).then((result) {
      isInUse = result;
      if (isInUse) {
        setState(() {
          _emailError = 'Email is already in use'; // Set error state
        });
      }
    });
    if (isInUse) {
      return 'Email is already in use';
    }
    return null;
  },
),

                            SizedBox(height: 8),
                            _buildTextField(
                                _passwordController,
                                'Password',
                                'Please enter a password',
                                TextInputType.visiblePassword,
                                true),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: widget.screenWidth,
                        height: widget.screenHeight * 0.06,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            elevation: 5,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Save Changes',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, String labelText, String errorMessage,
    [TextInputType? keyboardType, bool obscureText = false]
  ) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: (value) => value?.isEmpty ?? true ? errorMessage : null,
        ),
        SizedBox(height: 8),
      ],
    );
  }

  Widget _buildSuggestionField(
      TextEditingController controller,
      String labelText,
      List<String> suggestions,
      bool isSubjectSelected,
      Function(String) onSuggestionTap) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              // Reset selection flag only when editing
              isSubjectSelected = false;
            });
          },
        ),
        // Show suggestions only if the controller text is not empty and no suggestion has been selected
        if (controller.text.isNotEmpty && !isSubjectSelected)
          Container(
            height: 150,
            child: ListView(
              children: _filterSuggestions(controller.text, suggestions)
                  .map((suggestion) {
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    onSuggestionTap(
                        suggestion); // Trigger the callback for subject selection
                    setState(() {
                      isSubjectSelected =
                          true; // Mark as selected after tapping
                    });
                  },
                );
              }).toList(),
            ),
          ),
        SizedBox(height: 8),
      ],
    );
  }
}
