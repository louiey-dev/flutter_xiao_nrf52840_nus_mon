import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  // Config: Maximum data points to show on screen at once
  final int limitCount = 100;

  // Data buffer for the graph
  final List<FlSpot> points = [];

  // Current X-axis value (simulated time)
  double xValue = 0;
  double step = 0.05; // How fast the graph moves

  @override
  void initState() {
    super.initState();
    // Initialize with 0s to fill the chart initially (optional)
    for (int i = 0; i < limitCount; i++) {
      points.add(FlSpot(i.toDouble(), 0));
      xValue++;
    }

    _startListening();
  }

  void _startListening() {}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 16.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Live Z-Axis Data",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                // 1. Grid & Axis styling
                gridData: const FlGridData(show: true, drawVerticalLine: false),
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ), // Hide time labels for clean look
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey),
                ),

                // 2. Viewport range (Autoscaling vs Fixed)
                // Fixed Y-axis (-15 to 15) stops the graph from jumping around
                // when values are stable. Gravity is usually ~9.8.
                minY: -15,
                maxY: 15,

                // 3. The Line Data
                lineBarsData: [
                  LineChartBarData(
                    spots: points,
                    isCurved: true, // Makes the line smooth
                    gradient: const LinearGradient(
                      colors: [Colors.blueAccent, Colors.purpleAccent],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(
                      show: false,
                    ), // Hide dots for performance
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blueAccent.withOpacity(0.1),
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
}
