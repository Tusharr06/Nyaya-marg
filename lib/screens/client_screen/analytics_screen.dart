import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Judiciary Analytics")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard("Win Rate by Court", "High Court shows 68% favorable outcomes for Civil cases.", Colors.green),
            const SizedBox(height: 24),
            _buildChartSection("Disposal Trends (2020-2024)"),
            const SizedBox(height: 32),
            _buildStatCard("Avg Case Duration", "4.2 Years for District Court property disputes.", Colors.orange),
            const SizedBox(height: 24),
            _buildJudgeTrends(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String desc, Color accent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildChartSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: PremiumTheme.primaryGold, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: PremiumTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 3),
                    const FlSpot(1, 1.5),
                    const FlSpot(2, 5),
                    const FlSpot(3, 2.5),
                    const FlSpot(4, 4),
                  ],
                  isCurved: true,
                  color: PremiumTheme.primaryGold,
                  barWidth: 3,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: PremiumTheme.primaryGold.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJudgeTrends() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Judge-wise Grant Rate (Mock)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildJudgeRow("Justice R. Kumar", 0.75),
        _buildJudgeRow("Justice S. Murthy", 0.42),
        _buildJudgeRow("Justice V. Lakshmi", 0.61),
      ],
    );
  }

  Widget _buildJudgeRow(String name, double rate) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text("${(rate * 100).toInt()}%", style: const TextStyle(color: PremiumTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
             value: rate,
             backgroundColor: Colors.white10,
             color: PremiumTheme.primaryGold,
          ),
        ],
      ),
    );
  }
}
