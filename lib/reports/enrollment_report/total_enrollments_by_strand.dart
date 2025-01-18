import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/reports/enrollment_report/presentation/resources/app_colors.dart';

class TEBS extends StatelessWidget {
  const TEBS({super.key});

  static const strandLabels = ['ABM', 'HUMMS', 'STEM', 'ICT', 'HE', 'IA'];

  static const strandMapping = {
    "Accountancy, Business, and Management (ABM)": 0,
    "Humanities and Social Sciences (HUMSS)": 1,
    "Science, Technology, Engineering and Mathematics (STEM)": 2,
    "Information and Communication Technology (ICT)": 3,
    "Home Economics (HE)": 4,
    "Industrial Arts (IA)": 5,
  };

  Stream<Map<int, int>> fetchStrandData() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .where('Status', isEqualTo: "active") // Exclude "inactive" students
        .snapshots()
        .map((snapshot) {
          // Initialize counts for each strand
          final strandCounts = {
            for (var i = 0; i < TEBS.strandLabels.length; i++) i: 0
          };

          for (final doc in snapshot.docs) {
            // Ensure the field exists and matches the expected type
            final strand = doc.data()['seniorHigh_Strand'] as String?;
            if (strand == null) continue;

            // Map strand to its corresponding bar index
            final index = TEBS.strandMapping[strand];
            if (index != null) {
              strandCounts[index] = strandCounts[index]! + 1;
            }
          }
          return strandCounts;
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: fetchStrandData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Error loading data"));
        }

        final strandData = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF002f24),
            borderRadius: BorderRadius.circular(12),
          ),
          width: MediaQuery.of(context).size.width/3.3, // Adjusted width to fit beside other graphs
          child: Column(
            children: [
              const Text(
                "Total enrollments by strand",
                style: TextStyle(
                    fontFamily: "B", fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: const [
                    Indicator(
                      color: Colors.orangeAccent,
                      label: "Academic Strand",
                    ),
                    SizedBox(height: 10),
                    Indicator(
                      color: Colors.purpleAccent,
                      label: "Technical-Vocational-Livelihood Strand",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              EnrollmentBarChart(
                strandData: strandData,
                strandLabels: strandLabels,
              ),
            ],
          ),
        );
      },
    );
  }
}

class EnrollmentBarChart extends StatefulWidget {
  const EnrollmentBarChart({
    super.key,
    required this.strandData,
    required this.strandLabels,
  });

  final Map<int, int> strandData;
  final List<String> strandLabels;

  @override
  State<EnrollmentBarChart> createState() => _EnrollmentBarChartState();
}

class _EnrollmentBarChartState extends State<EnrollmentBarChart> {
  int touchedIndex = -1;

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 10);
    if (value.toInt() < widget.strandLabels.length) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          widget.strandLabels[value.toInt()],
          style: style,
        ),
      );
    }
    return const SizedBox();
  }

  Widget leftTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.white, fontSize: 12); // Enlarged font size
    if (value % 5 == 0) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          value.toInt().toString(),
          style: style,
        ),
      );
    }
    return const SizedBox();
  }

  BarChartGroupData generateGroup(int x, double value, {bool isTouched = false}) {
    final isAcademic = x < 3;
    final barColor = isAcademic ? Colors.orangeAccent : Colors.purpleAccent;

    return BarChartGroupData(
      x: x,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          toY: value, // Use the actual data value
          width: 25, // Adjusted width to align better with the grid lines
          color: barColor, // Always use the original bar color
          borderSide: BorderSide(
            color: isTouched ? Colors.white : Colors.transparent,
            width: isTouched ? 2 : 0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Adjusted width to fit within the container
      height: 315, // Adjusted height to fit within the container
      child: BarChart(
        BarChartData(
          maxY: widget.strandData.values.reduce((a, b) => a > b ? a : b) + 5,
          minY: 0,
          groupsSpace: 10, // Increased space between groups for better alignment
          barGroups: List.generate(
            widget.strandLabels.length,
            (i) => generateGroup(
              i,
              widget.strandData[i]?.toDouble() ?? 0,
              isTouched: i == touchedIndex,
            ),
          ),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                // Use the actual value without adding any offsets
                final actualValue =
                    widget.strandData[groupIndex]?.toDouble() ?? 0;
                return BarTooltipItem(
                  '${widget.strandLabels[groupIndex]}: ${actualValue.round()}',
                  const TextStyle(color: Colors.white),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                setState(() {
                  touchedIndex = -1;
                });
                return;
              }
              setState(() {
                touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // Added reserved size for better spacing
                getTitlesWidget: leftTitles,
                interval: 5,
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: bottomTitles,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          gridData: FlGridData(
            show: true,
            checkToShowHorizontalLine: (value) => value % 1 == 0,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.3),
                strokeWidth: 0.8,
              );
            },  
          ),
        ),
      ),
    );
  }
}


class Indicator extends StatelessWidget {
  const Indicator({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.square_rounded, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
              fontFamily: "M", fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }
}
