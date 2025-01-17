import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

class DistributionGender extends StatefulWidget {
  const DistributionGender({super.key});

  @override
  State<DistributionGender> createState() => _DistributionGenderState();
}

class _DistributionGenderState extends State<DistributionGender> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: getGenderDistribution(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text("Error loading data"));
        }

        final genderData = snapshot.data!;
        final maleCount = genderData['Male'] ?? 0;
        final femaleCount = genderData['Female'] ?? 0;

        final dataList = [
          _BarData(Colors.blue, maleCount.toDouble()), // Male
          _BarData(Colors.pink, femaleCount.toDouble()), // Female
        ];

        return Container(
          width: MediaQuery.of(context).size.width/3.3,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF002f24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: const Text(
                  "Distribution of Gender",
                  style: TextStyle(fontFamily: "SB", color: Colors.white, fontSize: 20),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.face_retouching_natural, color: Colors.blue),
                      SizedBox(width: 5),
                      Text("Male", style: TextStyle(color: Colors.blue, fontFamily: "M")),
                    ],
                  ),
                  Row(
                    children: const [
                      Icon(Icons.face_retouching_natural, color: Colors.pink),
                      SizedBox(width: 5),
                      Text("Female", style: TextStyle(color: Colors.pink, fontFamily: "M")),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(
                        show: true,
                        border: Border.symmetric(
                          horizontal: BorderSide(
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 36,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                child: _IconWidget(
                                  color: dataList[index].color,
                                  isSelected: false,
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(),
                        topTitles: const AxisTitles(),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.4),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: dataList.asMap().entries.map((e) {
                        final index = e.key;
                        final data = e.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value,
                              color: data.color,
                              width: 50,
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ],
                        );
                      }).toList(),
                           // Adjust based on expected maximum count
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Stream function to get gender distribution
  Stream<Map<String, int>> getGenderDistribution() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .where('Status', isEqualTo: 'active')
        .snapshots()
        .map((snapshot) {
          final maleCount = snapshot.docs
              .where((doc) => doc['gender'] == 'Male')
              .length;
          final femaleCount = snapshot.docs
              .where((doc) => doc['gender'] == 'Female')
              .length;
          return {'Male': maleCount, 'Female': femaleCount};
        });
  }
}

class _BarData {
  const _BarData(this.color, this.value);
  final Color color;
  final double value;
}

class _IconWidget extends ImplicitlyAnimatedWidget {
  const _IconWidget({
    required this.color,
    required this.isSelected,
  }) : super(duration: const Duration(milliseconds: 300));
  final Color color;
  final bool isSelected;

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _IconWidgetState();
}

class _IconWidgetState extends AnimatedWidgetBaseState<_IconWidget> {
  Tween<double>? _rotationTween;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.face,
      color: widget.color,
      size: 28,
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _rotationTween = visitor(
      _rotationTween,
      widget.isSelected ? 1.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value as double, end: 0.0),
    ) as Tween<double>?;
  }
}
