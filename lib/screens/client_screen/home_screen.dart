import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/premium_theme.dart';
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/notification_badge.dart';
import 'case_detail_screen.dart';
import 'analytics_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _notificationCount = 3;
  late Timer _updateTimer;

  @override
  void initState() {
    super.initState();
    // Simulate real-time updates
    _updateTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        setState(() {
          _notificationCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: PremiumTheme.surfaceDark,
            content: Row(
              children: [
                const Icon(Icons.notifications_active, color: PremiumTheme.primaryGold, size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "New order uploaded for your tracked case OS/2023/542",
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildLocationChip(),
                  const SizedBox(height: 24),
                  const InsightCard(
                    title: "Daily Briefing",
                    message: "3 of your tracked cases have hearings scheduled this week. Predicted success rate overall: 72%.",
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Smart Suggestions"),
                  _buildSuggestions(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Recently Viewed"),
                  _buildRecentList(),
                  const SizedBox(height: 32),
                  _buildSectionTitle("Predictive Trends"),
                  _buildTrendCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _notificationCount > 0 
          ? NotificationBadge(count: _notificationCount)
          : null,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          "NyayMarg Intelligence",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                PremiumTheme.primaryGold.withValues(alpha: 0.2),
                PremiumTheme.deepBlue,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: PremiumTheme.primaryGold), onPressed: () {}),
        IconButton(icon: const Icon(Icons.person_outline, color: Colors.white), onPressed: () {}),
      ],
    );
  }

  Widget _buildLocationChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: PremiumTheme.primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PremiumTheme.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.my_location, size: 14, color: PremiumTheme.primaryGold),
          const SizedBox(width: 8),
          const Text(
            "Bengaluru, Karnataka",
            style: TextStyle(color: PremiumTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        letterSpacing: 1.2,
        color: Colors.white.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = ["Property Disputes", "Civil Appeals", "IPC 302 Cases", "Labor Law"];
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              backgroundColor: PremiumTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.white10),
              ),
              label: Text(suggestions[index], style: const TextStyle(color: Colors.white70, fontSize: 13)),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentList() {
    return Column(
      children: List.generate(2, (index) => _buildRecentItem(index)),
    );
  }

  Widget _buildRecentItem(int index) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => CaseDetailScreen(caseId: "case_$index"))
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PremiumTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined, color: PremiumTheme.primaryGold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("OS/2023/54${index + 1}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Land Dispute - Bengaluru North", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 150).ms).slideX();
  }

  Widget _buildTrendCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceDark,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             PremiumTheme.deepBlue,
             PremiumTheme.surfaceDark,
          ],
        ),
        border: Border.all(color: PremiumTheme.accentCyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("High Court Filing Trends", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Icon(Icons.trending_up, color: PremiumTheme.successGreen, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Civil filings in Bengaluru have increased by 14% this month. Average disposal time: 3.2 years.",
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 12),
          TextButton(
            child: Text("VIEW ANALYTICS", style: TextStyle(color: PremiumTheme.accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}