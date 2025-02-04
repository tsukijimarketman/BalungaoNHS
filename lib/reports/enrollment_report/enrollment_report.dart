import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:balungao_nhs/reports/enrollment_report/distribution_age.dart';
import 'package:balungao_nhs/reports/enrollment_report/distribution_gender.dart';
import 'package:balungao_nhs/reports/enrollment_report/total_enrollments_by_strand.dart';

class EnrollmentReport extends StatefulWidget {
  const EnrollmentReport({super.key});

  @override
  State<EnrollmentReport> createState() => _EnrollmentReportState();
}

class _EnrollmentReportState extends State<EnrollmentReport> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text(
                "Enrollment Report",
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width/35,
                  fontFamily: "BL",
                ),
              ),
              SizedBox(height: screenWidth / 300),
              Text(
                "View and analyze school enrollment data",
                style: TextStyle(
                    fontFamily: "M", fontSize: screenWidth/90, color: Colors.grey),
              ),
              SizedBox(height: screenWidth/50),
              Text(
                "Total Enrollments",
                style: TextStyle(fontSize: screenWidth/55, fontFamily: "B"),
              ),
              SizedBox(height: screenWidth/50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<int>(
                    stream: getTotalEnrollments(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCardH(
                            "Total Enrollments", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCardH("Total Enrollments", "Error");
                      }
                      return buildStatCardH(
                        "Total Enrollments",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(
                    width: screenWidth/70,
                  ),
                  StreamBuilder<int>(
                    stream: getTotalJHS(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCardH(
                            "Total JHS Student", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCardH("Total JHS Student", "Error");
                      }
                      return buildStatCardH(
                        "Total JHS Student",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(
                    width: screenWidth/70,
                  ),
                  StreamBuilder<int>(
                    stream: getTotalSHS(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCardH(
                            "Total SHS Student", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCardH("Total SHS Student", "Error");
                      }
                      return buildStatCardH(
                        "Total SHS Student",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenWidth/50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StreamBuilder<int>(
                    stream: getGradeLevelCount("7"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Grade 7", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Grade 7", "Error");
                      }
                      return buildStatCard(
                        "Grade 7",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(width: screenWidth/70),
                  StreamBuilder<int>(
                    stream: getGradeLevelCount("8"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Grade 8", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Grade 8", "Error");
                      }
                      return buildStatCard(
                        "Grade 8",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(width: screenWidth/70),
                  StreamBuilder<int>(
                    stream: getGradeLevelCount("9"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Grade 9", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Grade 9", "Error");
                      }
                      return buildStatCard(
                        "Grade 9",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(width: screenWidth/70),
                  StreamBuilder<int>(
                    stream: getGradeLevelCount("10"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Grade 10", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Grade 10", "Error");
                      }
                      return buildStatCard(
                        "Grade 10",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(width: screenWidth/70),
                  StreamBuilder<int>(
                    stream: getGradeLevelCount("11"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Grade 11", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Grade 11", "Error");
                      }
                      return buildStatCard(
                        "Grade 11",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  SizedBox(width: screenWidth/70),
                  StreamBuilder<int>(
                    stream: getGradeLevelCount("12"),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Grade 12", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Grade 12", "Error");
                      }
                      return buildStatCard(
                        "Grade 12",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenWidth/50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DistributionAge(),
                  DistributionGender(),
                  TEBS(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth/60, horizontal: screenWidth/50),
      width: MediaQuery.of(context).size.width / 6.92,
      decoration: BoxDecoration(
        color: Color(0xFF00A16c),
        borderRadius: BorderRadius.circular(screenWidth/80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: screenWidth/65, fontFamily: "M", color: Colors.white),
          ),
          SizedBox(height: screenWidth/300),
          Text(
            value,
            style: TextStyle(
                fontFamily: "B", fontSize: screenWidth/50, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildStatCardH(String title, String value) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.symmetric(vertical: screenWidth/70, horizontal: screenWidth/50),
      width: MediaQuery.of(context).size.width / 3.3,
      height: MediaQuery.of(context).size.width / 10,
      decoration: BoxDecoration(
        color: Color(0xFFA1F9D0),
        borderRadius: BorderRadius.circular(screenWidth/80),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: screenWidth/65, fontFamily: "M", color: Colors.black),
          ),
          
          Text(
            value,
            style: TextStyle(
                fontFamily: "B", fontSize: screenWidth/30, color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// Stream function to get the total enrollments
  Stream<int> getTotalEnrollments() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .snapshots()
        .map((snapshot) {
          final activeCount =
              snapshot.docs.where((doc) => doc['Status'] != 'inactive').length;
          return activeCount;
        });
  }

  Stream<int> getTotalSHS() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .where('educ_level', isEqualTo: 'Senior High School')
        .snapshots()
        .map((snapshot) {
          final activeCount =
              snapshot.docs.where((doc) => doc['Status'] != 'inactive').length;
          return activeCount;
        });
  }

  Stream<int> getTotalJHS() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .where('educ_level', isEqualTo: 'Junior High School')
        .snapshots()
        .map((snapshot) {
          final activeCount =
              snapshot.docs.where((doc) => doc['Status'] != 'inactive').length;
          return activeCount;
        });
  }

  /// Stream function to get the count of students in a specific grade level
  Stream<int> getGradeLevelCount(String gradeLevel) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .where('grade_level', isEqualTo: gradeLevel)
        .snapshots()
        .map((snapshot) {
          final activeCount =
              snapshot.docs.where((doc) => doc['Status'] != 'inactive').length;
          return activeCount;
        });
  }

  /// Stream function to calculate the average age of active students
  Stream<double> getAverageAge() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .snapshots()
        .map((snapshot) {
          // Filter out inactive students
          final activeDocs =
              snapshot.docs.where((doc) => doc['Status'] != 'inactive');

          if (activeDocs.isEmpty) return 0.0; // Handle empty result case

          // Convert 'age' from string to int, ignoring invalid or missing values
          final totalAge = activeDocs.map((doc) {
            final ageString = doc['age']?.toString();
            return int.tryParse(ageString ?? '0') ?? 0;
          }).fold(0, (sum, age) => sum + age);

          return totalAge / activeDocs.length; // Calculate average age
        });
  }
}
