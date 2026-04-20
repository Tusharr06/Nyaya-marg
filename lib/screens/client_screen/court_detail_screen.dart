import 'package:flutter/material.dart';
import '../../core/models/legal_models.dart';
import '../../theme/premium_theme.dart';
import '../../shared/widgets/court_widgets.dart';

class CourtDetailScreen extends StatelessWidget {
  final Court court;

  const CourtDetailScreen({super.key, required this.court});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(court.name),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: PremiumTheme.primaryGold,
            labelColor: PremiumTheme.primaryGold,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: "Cases"),
              Tab(text: "Cause List"),
              Tab(text: "Judgments"),
              Tab(text: "Stats"),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CourtInfoCard(
                courtName: court.name,
                status: "Operational",
                nextHearing: "Daily 10 AM - 5 PM",
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  _CourtTabContent(title: "Recent Cases"),
                  _CourtTabContent(title: "Daily Cause List"),
                  _CourtTabContent(title: "Latest Judgments"),
                  _CourtTabContent(title: "Analytics & Stats"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtTabContent extends StatelessWidget {
  final String title;

  const _CourtTabContent({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.white10),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            "Loading simulation data...",
            style: const TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
