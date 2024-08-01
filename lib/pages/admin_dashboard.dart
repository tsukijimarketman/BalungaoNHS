import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pbma_portal/pages/dashboard.dart';
import 'package:pbma_portal/student_utils/Student_Utils.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedDrawerItem = 'Dashboard';

  Widget _buildBodyContent() {
    switch (_selectedDrawerItem) {
      case 'Dashboard':
        return _buildDashboardContent();
      case 'Students':
        return _buildStudentsContent();
      case 'Strand Professor':
        return _buildStrandInstructorContent();
      case 'Manage Newcomers':  
        return _buildNewcomersContent();
      default:
        return Center(child: Text('Body Content Here'));
    }
  }

  Widget _buildDashboardContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Students List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 2.0),
            ),
              child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('enrollment_status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No students.'));
                }

                final students = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (bool? value) {}),
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(child: Text('Track')),
                          Expanded(child: Text('Strand')),
                          Expanded(child: Text('Grade Level')),
                        ],
                      ),
                      Divider(),
                      ...students.map((student) {
                        final data = student.data() as Map<String, dynamic>;
                        return Row(
                          children: [
                            Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text(data['student_id'] ?? '')),
                            Expanded(child: Text(data['first_name'] ?? '')),
                            Expanded(child: Text(data['last_name'] ?? '')),
                            Expanded(child: Text(data['middle_name'] ?? '')),
                            Expanded(child: Text(data['seniorHigh_Track'] ?? '')),
                            Expanded(child: Text(data['seniorHigh_Strand'] ?? '')),
                            Expanded(child: Text(data['grade_level'] ?? '')),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStudentsContent() {
  return Container(
    color: Colors.grey[300],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Students',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                 
                },
                icon: Icon(Iconsax.add_copy, size: 18, color: Colors.black),
                label: Text('Add Student', style: TextStyle(color: Colors.black)),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Container(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Student',
                    prefixIcon: Icon(Iconsax.search_normal_1_copy),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 2.0),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('enrollment_status', isEqualTo: 'approved')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No approved students.'));
                }

                final students = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (bool? value) {}),
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(child: Text('Track')),
                          Expanded(child: Text('Strand')),
                          Expanded(child: Text('Grade Level')),
                        ],
                      ),
                      Divider(),
                      ...students.map((student) {
                        final data = student.data() as Map<String, dynamic>;
                        return Row(
                          children: [
                            Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text(data['student_id'] ?? '')),
                            Expanded(child: Text(data['first_name'] ?? '')),
                            Expanded(child: Text(data['last_name'] ?? '')),
                            Expanded(child: Text(data['middle_name'] ?? '')),
                            Expanded(child: Text(data['seniorHigh_Track'] ?? '')),
                            Expanded(child: Text(data['seniorHigh_Strand'] ?? '')),
                            Expanded(child: Text(data['grade_level'] ?? '')),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStrandInstructorContent() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Strand Instructor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Students List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  width: 300,
                  child: Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search Student',
                        prefixIcon: Icon(Iconsax.search_normal_1_copy),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),  
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0),
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (bool? value) {}),
                        Expanded(child: Text('Student ID')),
                        Expanded(child: Text('Name')),
                        Expanded(child: Text('Track')),
                        Expanded(child: Text('Strand')),
                        Expanded(child: Text('Grade Level')),
                        Expanded(child: Text('Average')),
                      ],
                    ),
                    Divider(),
                    Row(
                      children: [
                        Checkbox(value: false, onChanged: (bool? value) {}),
                        Expanded(child: Text('PBMA-0001-2024')),
                        Expanded(child: Text('Juan Manaloto. Delacruz')),
                        Expanded(child: Text('TVL')),
                        Expanded(child: Text('ICT')),
                        Expanded(child: Text('12')),
                        Expanded(child: Text('N/A')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildNewcomersContent() {
  return Container(
    color: Colors.grey[300],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Manage Newcomers',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 300,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search Student',
                    prefixIcon: Icon(Iconsax.search_normal_1_copy),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.blue, width: 2.0),
            ),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('enrollment_status', isEqualTo: 'pending')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No pending students.'));
                }

                final students = snapshot.data!.docs;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(value: false, onChanged: (bool? value) {}),
                          Expanded(child: Text('Student ID')),
                          Expanded(child: Text('First Name')),
                          Expanded(child: Text('Last Name')),
                          Expanded(child: Text('Middle Name')),
                          Expanded(child: Text('Track')),
                          Expanded(child: Text('Strand')),
                          Expanded(child: Text('Grade Level')),
                          Expanded(child: Text('')),
                        ],
                      ),
                      Divider(),
                      ...students.map((student) {
                        final data = student.data() as Map<String, dynamic>;
                        return Row(
                          children: [
                            Checkbox(value: false, onChanged: (bool? value) {}),
                            Expanded(child: Text(data['student_id'] ?? '')),
                            Expanded(child: Text(data['first_name'] ?? '')),
                            Expanded(child: Text(data['last_name'] ?? '')),
                            Expanded(child: Text(data['middle_name'] ?? '')),
                            Expanded(child: Text(data['seniorHigh_Track'] ?? '')),
                            Expanded(child: Text(data['seniorHigh_Strand'] ?? '')),
                            Expanded(child: Text(data['grade_level'] ?? '')),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Iconsax.tick_circle_copy, color: Colors.green),
                                    onPressed: () {
                                      approveStudent(student.id);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Iconsax.close_circle_copy, color: Colors.red),
                                    onPressed: () {
                                     
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Set the preferred height
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the back button
          backgroundColor: Colors.white, // Set the background color to match the image
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  iconSize: 30,
                  icon: Icon(Iconsax.menu_copy, color: Colors.blue), // Use Iconsax.menu
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer(); // Open the drawer when pressed
                  },
                ),
                Row(
                  children: [
                    Icon(
                      size: 30,
                      Iconsax.profile_circle_copy,
                    ),
                    SizedBox(width: 15), // Add spacing between the icon and the text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ADMIN',
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 16, // Smaller font size for the label
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                        ),
                        Text(
                          'admin123@gmail.com',
                          style: TextStyle(
                            color: Colors.black, // Black color for the text
                            fontSize: 14, // Smaller font size for the email
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/PBMA.png', // Replace with your asset image path
                    height: 130,
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Iconsax.dash_dash),
              title: Text('Dashboard'),
              onTap: () {
                setState(() {
                  _selectedDrawerItem = 'Dashboard';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Iconsax.user),
              title: Text('Students'),
              onTap: () {
                setState(() {
                  _selectedDrawerItem = 'Students';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            
            ListTile(
              leading: Icon(Iconsax.teacher),
              title: Text('Strand Professor'),
              onTap: () {
                setState(() {
                  _selectedDrawerItem = 'Strand Professor';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Iconsax.task),
              title: Text('Manage Newcomers'),
              onTap: () {
                setState(() {
                  _selectedDrawerItem = 'Manage Newcomers';
                });
                Navigator.of(context).pop(); // Close the drawer
              },
            ),
            ListTile(
              leading: Icon(Iconsax.logout),
              title: Text('Log out'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Dashboard()),
                );
              },
            ),
          ],
        ),
      ),
      body: _buildBodyContent(),
    );
  }
}
