import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart'; // To open PDF or Word in an external app

class Newcomersvalidator extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const Newcomersvalidator({required this.studentData, super.key});

  @override
  State<Newcomersvalidator> createState() => _NewcomersvalidatorState();
}

class _NewcomersvalidatorState extends State<Newcomersvalidator> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    String combinedAddress = [
      widget.studentData['house_number'] ?? '',
      widget.studentData['street_name'] ?? '',
      widget.studentData['subdivision_barangay'] ?? '',
      widget.studentData['city_municipality'] ?? '',
      widget.studentData['province'] ?? '',
      widget.studentData['country'] ?? '',
    ].where((s) => s.isNotEmpty).join(', ');

    List<String> fileUrls = List<String>.from(widget.studentData['file_urls'] ?? []);

    return Scaffold(
      body: Column(
        children: [
          // Breadcrumb Container (unchanged)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Student Details',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) {
                        setState(() {
                          _hovering = true;
                        });
                      },
                      onExit: (_) {
                        setState(() {
                          _hovering = false;
                        });
                      },
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Go back to the previous page (Student List)
                        },
                        child: Text(
                          'Student List',
                          style: TextStyle(
                            color: _hovering ? Colors.blue : Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      ' / ',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Student Details',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Left Card for Student Details (unchanged)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow(Icons.email, 'Email Address',
                                  widget.studentData['email_Address'] ?? ''),
                              _buildDetailRow(Icons.location_on, 'Address',
                                  combinedAddress),
                              _buildDetailRow(Icons.phone, 'Contact Number',
                                  widget.studentData['phone_number'] ?? ''),
                              _buildDetailRow(Icons.cake, 'Birthday',
                                  widget.studentData['birthdate'] ?? ''),
                              _buildDetailRow(Icons.person, 'Age',
                                  widget.studentData['age'] ?? ''),
                              _buildDetailRow(Icons.person, 'Gender',
                                  widget.studentData['gender'] ?? ''),
                              _buildDetailRow(Icons.grade, 'Grade',
                                  widget.studentData['grade_level'] ?? ''),
                              _buildDetailRow(Icons.track_changes, 'Track',
                                  widget.studentData['seniorHigh_Track'] ?? ''),
                              _buildDetailRow(Icons.book, 'Strand',
                                  widget.studentData['seniorHigh_Strand'] ?? ''),
                              _buildDetailRow(Icons.groups, 'Indigenous Group',
                                  widget.studentData['indigenous_group'] ?? ''),
                              _buildDetailRow(Icons.person, 'Father’s Name',
                                  widget.studentData['fathersName'] ?? ''),
                              _buildDetailRow(Icons.person, 'Mother’s Name',
                                  widget.studentData['mothersName'] ?? ''),
                              _buildDetailRow(Icons.person, 'Guardian’s Name',
                                  widget.studentData['guardianName'] ?? ''),
                              _buildDetailRow(Icons.group, 'Guardian Relationship',
                                  widget.studentData['relationshipGuardian'] ?? ''),
                              _buildDetailRow(Icons.phone, 'Guardian Contact Number',
                                  widget.studentData['cellphone_number'] ?? ''),
                              _buildDetailRow(Icons.school, 'Junior High School',
                                  widget.studentData['juniorHS'] ?? ''),
                              _buildDetailRow(Icons.location_city, 'JHS Address',
                                  widget.studentData['schoolAdd'] ?? ''),
                              _buildDetailRow(Icons.transfer_within_a_station, 'Transferee',
                                  widget.studentData['transferee'] ?? ''),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attached Files:',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    for (var fileUrl in fileUrls)
                                      GestureDetector(
                                        onTap: () {
                                          _openFile(fileUrl);
                                        },
                                        child: Container(
                                          width: 200,
                                          height: 40,
                                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8.0),
                                            color: Colors.grey[300],
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.file_present, size: 12,),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  Uri.decodeComponent(fileUrl.split('%2F').last.split('?').first),
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),

                  // Right Card for Student Profile (unchanged)
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'STUDENT',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 16),
                            GestureDetector(
                              onTap: () {
                                // Handle tap on profile picture
                              },
                              child: CircleAvatar(
                                radius: 100,
                                backgroundImage: widget.studentData['image_url'] != null
                                    ? NetworkImage(widget.studentData['image_url'])
                                    : NetworkImage(
                                        'https://cdn4.iconfinder.com/data/icons/linecon/512/photo-512.png'),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              '${widget.studentData['first_name'] ?? ''} ${widget.studentData['middle_name'] ?? ''} ${widget.studentData['last_name'] ?? ''} ${widget.studentData['extension_name'] ?? ''}',
                              style: TextStyle(fontSize: 20),
                            ),
                            Text(widget.studentData['email_Address'] ?? ''),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build detail rows (unchanged)
  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

Future<void> _openFile(String url) async {
  final uri = Uri.parse(url);
  final path = uri.path;
  final extension = path.substring(path.lastIndexOf('.')).toLowerCase();

  print("File URL: $url");
  print("File Extension: $extension");

  if (extension == '.jpg' || extension == '.jpeg' || extension == '.png') {
    print("Opening image file...");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Image.network(url),
        ),
      ),
    );
  } else if (extension == '.pdf') {
    print("Opening PDF file...");
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showUnsupportedFileType();
    }
  } else if (extension == '.docx' || extension == '.doc') {
    try {
      print("Attempting to open DOC/DOCX file...");
      final result = await OpenFile.open(url);
      if (result.type != ResultType.done) {
        throw Exception("open_file failed");
      }
    } catch (e) {
      print("Open file failed: $e");
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        _showUnsupportedFileType();
      }
    }
  } else {
    print("Unsupported file type encountered.");
    _showUnsupportedFileType();
  }
}



void _showUnsupportedFileType() {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Row(
      children: [
        Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
        Text('Unsupported file type'),
      ],
    )),
  );
}

}