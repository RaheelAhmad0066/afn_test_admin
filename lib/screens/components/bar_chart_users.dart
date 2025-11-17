import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:afn_test_admin/constants/constants.dart';
import 'package:afn_test_admin/controllers/dashboard_controller.dart';

class BarChartUsers extends StatelessWidget {
  const BarChartUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize dashboard controller
    if (!Get.isRegistered<DashboardController>()) {
      Get.put(DashboardController());
    }
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final chartData = controller.usersChartData;
      
      // Use dummy data if empty (will be replaced when real data loads)
      final List<Map<String, dynamic>> displayData = chartData.isEmpty ? [
        {'day': 'Mon', 'users': 5},
        {'day': 'Tue', 'users': 8},
        {'day': 'Wed', 'users': 12},
        {'day': 'Thu', 'users': 6},
        {'day': 'Fri', 'users': 15},
        {'day': 'Sat', 'users': 10},
        {'day': 'Sun', 'users': 7},
      ] : chartData.toList();

      // Find max value for scaling
      final maxValue = displayData.map((e) => e['users'] as int).reduce((a, b) => a > b ? a : b);
      final maxY = maxValue > 0 ? (maxValue * 1.2).ceil().toDouble() : 10.0;

      // Generate bar groups from data (dummy or real)
      final barGroups = displayData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final users = data['users'] as int;
        
        return BarChartGroupData(
          x: index + 1,
          barRods: [
            BarChartRodData(
              toY: users.toDouble(),
              width: 20,
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
            )
          ],
        );
      }).toList();

      return BarChart(BarChartData(
        maxY: maxY,
        borderData: FlBorderData(border: Border.all(width: 0)),
        groupsSpace: 15,
        titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt() - 1;
                  if (index >= 0 && index < displayData.length) {
                    return Text(
                      displayData[index]['day'] as String,
                      style: const TextStyle(
                        color: lightTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: lightTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            )),
        barGroups: barGroups,
      ));
    });
  }
}
