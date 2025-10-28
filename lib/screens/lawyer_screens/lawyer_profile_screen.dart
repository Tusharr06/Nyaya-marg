import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/auth_screens/service/logout_service.dart';
import 'package:nyaya_marg/theme/colors.dart';

class LawyerProfileScreen extends StatefulWidget {
  const LawyerProfileScreen({super.key});

  @override
  State<LawyerProfileScreen> createState() => _LawyerProfileScreenState();
}

class _LawyerProfileScreenState extends State<LawyerProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _barCouncilIdCtrl;
  late final TextEditingController _specializationCtrl;
  late final TextEditingController _languagesCtrl;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _barCouncilIdCtrl = TextEditingController();
    _specializationCtrl = TextEditingController();
    _languagesCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _barCouncilIdCtrl.dispose();
    _specializationCtrl.dispose();
    _languagesCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final user = FirebaseAuth.instance.currentUser!;
    final data = {
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'location': _locationCtrl.text.trim(),
      'barCouncilId': _barCouncilIdCtrl.text.trim(),
      'specialization': _specializationCtrl.text.trim(),
      'languages': _languagesCtrl.text.trim(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Not available';

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: user != null
              ? FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .snapshots()
              : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

            if (_isLoading) {
              _nameCtrl.text = data['name'] ?? user?.displayName ?? 'Advocate';
              _phoneCtrl.text = data['phone'] ?? '';
              _locationCtrl.text = data['location'] ?? '';
              _barCouncilIdCtrl.text = data['barCouncilId'] ?? '';
              _specializationCtrl.text = data['specialization'] ?? '';
              _languagesCtrl.text = data['languages'] ?? '';
              _isLoading = false;
            }

            final displayName = _nameCtrl.text;
            final specialization = _specializationCtrl.text.isNotEmpty
                ? _specializationCtrl.text
                : 'Law Specialist';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ───── TITLE ─────
                  Text(
                    'Lawyer Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ───── AVATAR + NAME + SPECIALIZATION ─────
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.deepBlue,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : 'A',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              specialization,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              'Lawyer Account',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ───── EMAIL (READ-ONLY) ─────
                  _buildFieldCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: email,
                    enabled: false,
                  ),

                  // ───── EDITABLE FIELDS ─────
                  _buildFieldCard(
                    icon: Icons.person_outline,
                    label: 'Full Name',
                    controller: _nameCtrl,
                  ),
                  _buildFieldCard(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildFieldCard(
                    icon: Icons.location_on_outlined,
                    label: 'Location',
                    controller: _locationCtrl,
                  ),
                  _buildFieldCard(
                    icon: Icons.badge_outlined,
                    label: 'Bar Council ID',
                    controller: _barCouncilIdCtrl,
                  ),
                  _buildFieldCard(
                    icon: Icons.school_outlined,
                    label: 'Specialization',
                    controller: _specializationCtrl,
                  ),
                  _buildFieldCard(
                    icon: Icons.language_outlined,
                    label: 'Languages',
                    controller: _languagesCtrl,
                  ),

                  const SizedBox(height: 32),

                  // ───── SAVE BUTTON ─────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: _isSaving ? null : _saveProfile,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: _isSaving
                              ? AppColors.deepBlue.withOpacity(0.6)
                              : AppColors.deepBlue,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSaving)
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              const Icon(Icons.save_outlined, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _isSaving ? 'Saving...' : 'Save Changes',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ───── LOGOUT BUTTON ─────
                  SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () => LogoutService.logout(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.redAccent, width: 1.5),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout, color: Colors.redAccent),
                            const SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: GoogleFonts.poppins(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ───── REUSABLE FIELD CARD (Same as Client) ─────
  Widget _buildFieldCard({
    required IconData icon,
    required String label,
    String? value,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    final isReadOnly = !enabled;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(icon, color: AppColors.deepBlue, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: AppColors.deepBlue,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  isReadOnly
                      ? Text(
                          value!,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        )
                      : TextField(
                          controller: controller,
                          keyboardType: keyboardType,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}