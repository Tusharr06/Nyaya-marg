// home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  bool _isLoading = true;

  // Hardcoded analysis result
  final Map<String, dynamic> _analysis = {
    "overall_assessment": "GOOD",
    "court": "Delhi Sessions Court",
    "case_type": "Civil",
    "priority": "Low",
    "risk_level": "Low Risk",
    "predicted_outcome": "Unfavorable",
    "confidence": 69.7,
    "timeline_days": 582,
    "is_optimal": true,
    "optimal_message": "Your court has manageable workload – no transfer needed.",
  };

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        _userName = data?['name'] ?? user.displayName ?? 'User';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ───── GREETING ─────
              Row(
                children: [
                  Text(
                    'Hello ',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '$_userName!',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepBlue,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.deepBlue.withOpacity(0.2),
                    child: const Icon(Icons.balance, color: AppColors.deepBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Here's your case overview for today.",
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // ───── CASE OUTLOOK SUMMARY ─────
              _buildSummaryCard(),

              const SizedBox(height: 20),

              // ───── KEY METRICS ─────
              Text(
                'KEY METRICS',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 12),
              _buildMetricsGrid(),

              const SizedBox(height: 20),

              // ───── OPTIMAL MESSAGE ─────
              _buildOptimalCard(),

              const SizedBox(height: 20),

              // ───── NEXT STEPS ─────
              Text(
                'Next Steps',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue,
                ),
              ),
              const SizedBox(height: 12),
              _buildNextSteps(),
            ],
          ),
        ),
      ),
    );
  }

  // ───── CASE OUTLOOK SUMMARY CARD ─────
  Widget _buildSummaryCard() {
    final a = _analysis;
    final isGood = a['overall_assessment'] == 'GOOD';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CASE OUTLOOK SUMMARY',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            _summaryRow(
              icon: Icons.circle,
              color: isGood ? Colors.orange : Colors.red,
              label: 'Overall Assessment:',
              value: a['overall_assessment'],
              badge: true,
            ),
            _summaryRow(icon: Icons.location_city, label: 'Court', value: a['court']),
            _summaryRow(icon: Icons.folder_open, label: 'Case Type', value: a['case_type']),
            _summaryRow(icon: Icons.flag, label: 'Priority', value: a['priority']),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
    bool badge = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.deepBlue),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
          ),
          const Spacer(),
          badge
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: (color ?? Colors.orange).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: color ?? Colors.orange,
                    ),
                  ),
                )
              : Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
                ),
        ],
      ),
    );
  }

  // ───── KEY METRICS GRID (2×2) ─────
  Widget _buildMetricsGrid() {
    final a = _analysis;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: [
        _metricCard(
          icon: Icons.check_circle,
          color: Colors.green,
          title: 'Court Risk Level',
          value: a['risk_level'],
        ),
        _metricCard(
          icon: Icons.close,
          color: Colors.red,
          title: 'Predicted Outcome',
          value: a['predicted_outcome'],
        ),
        _metricCard(
          icon: Icons.bar_chart,
          color: Colors.orange,
          title: 'Confidence',
          value: '${a['confidence']}%',
        ),
        _metricCard(
          icon: Icons.access_time,
          color: AppColors.deepBlue,
          title: 'Expected Timeline',
          value: '~${a['timeline_days']} days',
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ───── OPTIMAL MESSAGE CARD ─────
  Widget _buildOptimalCard() {
    final a = _analysis;
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              a['is_optimal'] ? Icons.check_circle : Icons.warning,
              color: a['is_optimal'] ? Colors.green : Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a['optimal_message'],
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── NEXT STEPS LIST ─────
  Widget _buildNextSteps() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _stepRow(Icons.search, 'Monitor case status via eCourts portal'),
            const SizedBox(height: 12),
            _stepRow(Icons.description, 'Prepare documentation per court guidelines'),
          ],
        ),
      ),
    );
  }

  Widget _stepRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.deepBlue, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}