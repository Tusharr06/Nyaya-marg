import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/theme/colors.dart';

class LawyerHomeScreen extends StatelessWidget {
  const LawyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Lawyer Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, Advocate 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Here’s a quick overview of your activities:',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),

              // Quick Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(Icons.folder_open, 'My Cases', Colors.blueAccent),
                  _buildQuickAction(Icons.description_outlined, 'Documents', Colors.orangeAccent),
                  _buildQuickAction(Icons.people_alt_outlined, 'Clients', Colors.purpleAccent),
                ],
              ),
              const SizedBox(height: 25),

              // Upcoming Hearings
              Text(
                'Upcoming Hearings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _buildCard('State vs Sharma', '29 Oct 2025', 'Courtroom 2B'),
              _buildCard('Mehta vs Verma', '30 Oct 2025', 'Courtroom 4A'),
              const SizedBox(height: 20),

              // AI Suggestions / Research
              Text(
                'AI Case Insights',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _buildInsightCard(
                'Based on your active cases, 3 similar precedents found.',
                'Tap to view related judgments.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 13)),
      ],
    );
  }

  Widget _buildCard(String title, String date, String location) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.gavel, color: AppColors.primaryBlue),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text('$date • $location', style: GoogleFonts.poppins(fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }

  Widget _buildInsightCard(String title, String subtitle) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.psychology_outlined, color: Colors.green),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 13)),
      ),
    );
  }
}
