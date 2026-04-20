import 'package:flutter/material.dart';
import '../../core/models/data_source.dart';
import '../../theme/premium_theme.dart';

class DataSourceIndicator extends StatelessWidget {
  final DataSourceType type;

  const DataSourceIndicator({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case DataSourceType.live:
        color = PremiumTheme.successGreen;
        break;
      case DataSourceType.cached:
        color = PremiumTheme.warningYellow;
        break;
      case DataSourceType.dataset:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            type.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
