import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationBadge extends StatelessWidget {
  final int count;

  const NotificationBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: PremiumTheme.surfaceDark,
      onPressed: () {},
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.notifications_none, color: PremiumTheme.primaryGold),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: PremiumTheme.errorRed,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  count > 9 ? "9+" : count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .shimmer(delay: 2.seconds, duration: 1.seconds, color: PremiumTheme.primaryGold.withValues(alpha: 0.3));
  }
}
