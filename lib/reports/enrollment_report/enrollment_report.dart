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
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enrollment Report",
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: "BL",
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                "View and analyze school enrollment data",
                style: TextStyle(
                    fontFamily: "M", fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              const Text(
                "Total Enrollments",
                style: TextStyle(fontSize: 20, fontFamily: "B"),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  StreamBuilder<int>(
                    stream: getTotalEnrollments(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Total Enrollments", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Total Enrollments", "Error");
                      }
                      return buildStatCard(
                        "Total Enrollments",
                        snapshot.data?.toString() ?? "0",
                      );
                    },
                  ),
                  const SizedBox(width: 20),
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
                  const SizedBox(width: 20),
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
                  const SizedBox(width: 20),
                  StreamBuilder<double>(
                    stream: getAverageAge(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return buildStatCard("Average Age", "Loading...");
                      }
                      if (snapshot.hasError) {
                        return buildStatCard("Average Age", "Error");
                      }

                      // Convert the number to an integer (whole number)
                      final averageAge = snapshot.data?.toInt() ?? 0;

                      return buildStatCard(
                        "Average Age",
                        averageAge.toString(), // Display as a whole number
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const DistributionGender(),
                  SizedBox(width: 50,),
                  DistributionAge(),
                ],
              ),
              SizedBox(height: 40,),
              TEBS(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontFamily: "M"),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(fontFamily: "B", fontSize: 30),
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
