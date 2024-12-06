import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:io';

class StudentInformationView extends StatefulWidget {
  final Map<String, dynamic> userData;
  final Future<void> Function() pickImage;
  final Future<void> Function() replaceProfilePicture;
  final Future<void> Function() imageGetterFromExampleState;
  final VoidCallback logout;
  final Uint8List? imageBytes;
  final File? imageFile;
  final String? imageUrl;

  const StudentInformationView({
    Key? key,
    required this.userData,
    required this.pickImage,
    required this.replaceProfilePicture,
    required this.imageGetterFromExampleState,
    required this.logout,
    this.imageBytes,
    this.imageFile,
    this.imageUrl,
  }) : super(key: key);

  @override
  _StudentInformationViewState createState() => _StudentInformationViewState();
}

class _StudentInformationViewState extends State<StudentInformationView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: const Color.fromARGB(255, 1, 93, 168),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 40),
              const Text(
                "Student Information",
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 25,
                  fontFamily: "SB",
                ),
              ),
              const SizedBox(height: 10),
              _buildStudentDetails(),
              const SizedBox(height: 20),
              // TODO: Insert the remaining parts of your code here.
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: _handleProfilePictureChange,
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
  radius: 85,
  backgroundImage: widget.imageBytes != null
      ? MemoryImage(widget.imageBytes!) as ImageProvider<Object>
      : widget.imageFile != null
          ? FileImage(widget.imageFile!) as ImageProvider<Object>
          : widget.imageUrl != null
              ? NetworkImage(widget.imageUrl!) as ImageProvider<Object>
              : const NetworkImage(
                  'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png',
                ) as ImageProvider<Object>,
),

                    if (_isHovered)
                      Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFullName(),
                const SizedBox(height: 15),
                _buildProfileActions(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFullName() {
    return Row(
      children: [
        Text(
          widget.userData['first_name'] ?? 'N/A',
          style: const TextStyle(color: Colors.white, fontFamily: "B", fontSize: 30),
        ),
        const SizedBox(width: 10),
        Text(
          widget.userData['middle_name'] ?? 'N/A',
          style: const TextStyle(color: Colors.white, fontFamily: "B", fontSize: 30),
        ),
        const SizedBox(width: 10),
        Text(
          widget.userData['last_name'] ?? 'N/A',
          style: const TextStyle(color: Colors.white, fontFamily: "B", fontSize: 30),
        ),
      ],
    );
  }

  Widget _buildProfileActions() {
    return Row(
      children: [
        _buildEditProfileButton(),
        const SizedBox(width: 15),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildEditProfileButton() {
    return GestureDetector(
      onTap: _handleProfilePictureChange,
      child: Container(
        height: 40,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Edit Profile",
              style: TextStyle(color: Colors.black, fontFamily: "B", fontSize: 15),
            ),
            SizedBox(width: 5),
            Icon(Icons.edit, size: 20, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: widget.logout,
      child: Container(
        height: 40,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Logout",
              style: TextStyle(
                color: Color.fromARGB(255, 1, 93, 168),
                fontFamily: "B",
                fontSize: 15,
              ),
            ),
            SizedBox(width: 5),
            Icon(Icons.logout_rounded, size: 20, color: Color.fromARGB(255, 1, 93, 168)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDetailField("First Name", widget.userData['first_name']),
        _buildDetailField("Middle Name", widget.userData['middle_name']),
        _buildDetailField("Last Name", widget.userData['last_name']),
        _buildDetailField("Extension Name", widget.userData['extension_name']),
      ],
    );
  }

  Widget _buildDetailField(String label, String? value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontFamily: "M", fontSize: 15, color: Colors.white),
        ),
        const SizedBox(height: 13),
        SizedBox(
          width: label == "Extension Name" ? 150 : 309,
          child: TextFormField(
            initialValue: value ?? 'N/A',
            enabled: false,
            style: TextStyle(color: Colors.grey[700], fontFamily: "R", fontSize: 13),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(left: 10),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Colors.grey[300],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleProfilePictureChange() async {
    await widget.pickImage();
    if (widget.imageBytes != null || widget.imageFile != null) {
      await widget.replaceProfilePicture();
      await widget.imageGetterFromExampleState();
      setState(() {});
    }
  }
}
