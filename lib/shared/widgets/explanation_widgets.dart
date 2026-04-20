import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';

class ExplanationCard extends StatelessWidget {
  final List<String> positives;
  final List<String> negatives;

  const ExplanationCard({
    super.key,
    required this.positives,
    required this.negatives,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Model Explanation",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...positives.map((p) => _buildItem(p, Icons.check_circle_outline, PremiumTheme.successGreen)),
            const SizedBox(height: 8),
            ...negatives.map((n) => _buildItem(n, Icons.error_outline, PremiumTheme.errorRed)),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class RiskBadge extends StatelessWidget {
  final String level; // Low, Medium, High

  const RiskBadge({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level.toLowerCase()) {
      case 'high':
        color = PremiumTheme.errorRed;
        break;
      case 'medium':
        color = PremiumTheme.warningYellow;
        break;
      case 'low':
      default:
        color = PremiumTheme.successGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        "$level Risk",
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
