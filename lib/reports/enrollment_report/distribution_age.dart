import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:balungao_nhs/reports/enrollment_report/presentation/resources/app_colors.dart';
import 'package:balungao_nhs/reports/enrollment_report/presentation/widgets/indicator.dart';

class DistributionAge extends StatefulWidget {
  const DistributionAge({super.key});

  @override
  State<StatefulWidget> createState() => DistributionAgeState();
}

class DistributionAgeState extends State<DistributionAge> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<int, int>>(
      stream: getAgeDistribution(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text("Error loading data"));
        }

        final ageData = snapshot.data!;
        final total = ageData.values.fold(0, (sum, count) => sum + count);

        return Container(
          padding: const EdgeInsets.all(10),
          height: MediaQuery.of(context).size.width/3.21,
          width: MediaQuery.of(context).size.width/3.3,
          decoration: BoxDecoration(
            color: Color(0xFF002f24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                "Age Range",
                style: TextStyle(
                  fontFamily: "B",
                  fontSize: 25,
                  color: Colors.white
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: AgePieChart(ageData: ageData, total: total),
                    ),
                  ),
                  
                  AgeIndicators(ageData: ageData, total: total),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Stream<Map<int, int>> getAgeDistribution() {
    return FirebaseFirestore.instance
        .collection('users')
        .where('accountType', isEqualTo: 'student')
        .where('enrollment_status', whereIn: ['approved', 're-enrolled'])
        .snapshots()
        .map((snapshot) {
          final activeDocs =
              snapshot.docs.where((doc) => doc['Status'] == 'active').toList();

          final ageCounts = <int, int>{};
          for (final doc in activeDocs) {
            final age = int.tryParse(doc['age'].toString()) ?? 0;
            if (age > 0) {
              ageCounts[age] = (ageCounts[age] ?? 0) + 1;
            }
          }
          return ageCounts;
        });
  }
}

class AgePieChart extends StatefulWidget {
  final Map<int, int> ageData;
  final int total;

  const AgePieChart({required this.ageData, required this.total, super.key});

  @override
  _AgePieChartState createState() => _AgePieChartState();
}

class _AgePieChartState extends State<AgePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    List<Color> dynamicColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];

    List<PieChartSectionData> showingSections() {
      final ageGroups = widget.ageData.keys.toList();
      return List.generate(ageGroups.length, (i) {
        final age = ageGroups[i];
        final count = widget.ageData[age]!;
        final percentage = (count / widget.total) * 100;

        final fontSize = 16.0;
        final radius = 80.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

        final color = dynamicColors[i % dynamicColors.length];

        return PieChartSectionData(
          color: color,
          value: percentage,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: touchedIndex == i ? 100.0 : radius, // Apply enlargement animation
          titleStyle: TextStyle(
            fontSize: touchedIndex == i ? 25.0 : fontSize, // Enlarge title when touched
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        );
      });
    }

    return Container(
      width: 300,
      height: 300,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              if (event.isInterestedForInteractions &&
                  pieTouchResponse != null &&
                  pieTouchResponse.touchedSection != null) {
                final newIndex = pieTouchResponse.touchedSection!
                    .touchedSectionIndex;

                if (newIndex != touchedIndex) {
                  setState(() {
                    touchedIndex = newIndex;
                  });
                }
              } else {
                if (touchedIndex != -1) {
                  setState(() {
                    touchedIndex = -1;
                  });
                }
              }
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: showingSections(),
        ),
      ),
    );
  }
}

class AgeIndicators extends StatelessWidget {
  final Map<int, int> ageData;
  final int total;

  const AgeIndicators({required this.ageData, required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    List<Color> dynamicColors = [
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.amberAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ageData.keys.map((age) {
        final percentage = (ageData[age]! / total) * 100;
        final color = dynamicColors[ageData.keys.toList().indexOf(age) %
            dynamicColors.length];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Indicator(
            color: color,
            text: "$age years (${percentage.toStringAsFixed(1)}%)",
            isSquare: true,
          ),
        );
      }).toList(),
    );
  }
}
