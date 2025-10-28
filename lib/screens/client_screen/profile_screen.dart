import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/auth_screens/role_selection_screen.dart';
import 'package:nyaya_marg/theme/colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/user_avatar.png'),
            ),
            const SizedBox(height: 15),
            Text(
              'Rahul Sharma',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'User Account',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
            const SizedBox(height: 25),

            // Info Tiles
            _buildInfoTile(Icons.email_outlined, 'Email', 'rahul.sharma@email.com'),
            _buildInfoTile(Icons.phone_outlined, 'Phone', '+91 98765 43210'),
            _buildInfoTile(Icons.location_on_outlined, 'Location', 'Delhi, India'),
            _buildInfoTile(Icons.language_outlined, 'Preferred Language', 'English, Hindi'),

            const Spacer(),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 10),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                );
              },
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: Text(
                'Logout',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: Colors.grey[700]),
        ),
      ),
    );
  }
}
