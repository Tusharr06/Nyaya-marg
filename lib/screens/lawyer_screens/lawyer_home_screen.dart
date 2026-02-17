// lib/screens/lawyer_home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/screens/client_screen/chat_screen.dart';
import 'package:nyaya_marg/screens/client_screen/tools_screen.dart';
import 'package:nyaya_marg/theme/colors.dart';
import 'package:nyaya_marg/screens/lawyer_screens/justice_graph/backlog_risk_screen.dart';
import 'package:nyaya_marg/screens/lawyer_screens/justice_graph/case_duration_screen.dart';
import 'package:nyaya_marg/screens/lawyer_screens/justice_graph/district_investigation_screen.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  // UI
  String _userName = 'Advocate';
  bool _isLoadingUser = true;

  // Mock Citizen Cases
  final List<Map<String, String>> _citizenCases = [
    {'title': 'Ramesh vs. ABC Corp', 'category': 'Wrongful Termination', 'status': 'Pending'},
    {'title': 'Sita Devi vs. Landlord', 'category': 'Property Dispute', 'status': 'Hearing Scheduled'},
    {'title': 'Accident Claim - Rajesh', 'category': 'Road Accident', 'status': 'Evidence Stage'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();
      setState(() {
        _userName = data?['name'] ?? user.displayName ?? 'Advocate';
        _isLoadingUser = false;
      });
    } else {
      setState(() => _isLoadingUser = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.deepBlue,
        elevation: 4,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        child: _buildDashboard(),
      ),
    );
  }

  Widget _buildDashboard() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // PREMIUM SLIVER HEADER
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: false, // ENSURE IT SCROLLS AWAY COMPLETELY
          elevation: 0,
          backgroundColor: AppColors.deepBlue,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.deepBlue, AppColors.deepBlue.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello $_userName!',
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Manage your legal workspace',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // MAIN CONTENT
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _sectionTitle('Citizen Enquiries'),
              _buildCitizenCarousel(),

              const SizedBox(height: 30),
              _sectionTitle('Quick Tools'),
              _buildToolsGrid(),

              const SizedBox(height: 30),
              _sectionTitle('JusticeGraph Hub'),
              _buildGraphLabSection(),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildCitizenCarousel() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _citizenCases.length,
        itemBuilder: (ctx, i) {
          final c = _citizenCases[i];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 16, bottom: 10, top: 4),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.person_search, color: Colors.blue, size: 18),
                    ),
                    const Spacer(),
                    Text('New Inquiry', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[400])),
                  ],
                ),
                const SizedBox(height: 12),
                Text(c['title']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(c['category']!, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildToolsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _modernToolTile(
              'Summarizer',
              'Extract details',
              Icons.summarize_rounded,
              const Color(0xFFF59E0B),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentSummarizerScreen())),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _modernToolTile(
              'Precedents',
              'Court cases',
              Icons.gavel_rounded,
              const Color(0xFF8B5CF6),
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrecedentFinderScreen())),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernToolTile(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
            Text(sub, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildGraphLabSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Column(
          children: [
            _buildModernLabTile(
              'Backlog Risk Predictor',
              'Scientific speed analysis',
              Icons.speed,
              Colors.indigo,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BacklogRiskScreen())),
            ),
            _buildModernLabTile(
              'Duration Estimator',
              'Likely closure timeline',
              Icons.timer_outlined,
              Colors.blue,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseDurationScreen())),
            ),
            _buildModernLabTile(
              'District Investigation',
              'Regional performance',
              Icons.map_outlined,
              Colors.teal,
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistrictInvestigationScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLabTile(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text(sub, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500])),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}

// ── PRECEDENT FINDER (unchanged) ──
class PrecedentFinderScreen extends StatefulWidget {
  const PrecedentFinderScreen({super.key});
  @override State<PrecedentFinderScreen> createState() => _PrecedentFinderScreenState();
}

class _PrecedentFinderScreenState extends State<PrecedentFinderScreen> {
  final _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  bool _isSearching = false;

  final List<Map<String, String>> _mockCases = [
    {'title': 'Kesavananda Bharati v. State of Kerala', 'citation': '(1973) 4 SCC 225', 'court': 'Supreme Court', 'summary': 'Established the basic structure doctrine.'},
    {'title': 'Shreya Singhal v. Union of India', 'citation': '(2015) 5 SCC 1', 'court': 'Supreme Court', 'summary': 'Struck down Section 66A of IT Act.'},
    {'title': 'Vishaka v. State of Rajasthan', 'citation': '(1997) 6 SCC 241', 'court': 'Supreme Court', 'summary': 'Sexual harassment guidelines.'},
    {'title': 'Maneka Gandhi v. Union of India', 'citation': '(1978) 1 SCC 248', 'court': 'Supreme Court', 'summary': 'Expanded Article 21.'},
    {'title': 'Indra Sawhney v. Union of India', 'citation': '(1992) Supp 3 SCC 217', 'court': 'Supreme Court', 'summary': '27% OBC reservation upheld.'},
  ];

  @override void initState() { super.initState(); _results = _mockCases; }

  void _search() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() => _isSearching = true);
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _results = query.isEmpty
            ? _mockCases
            : _mockCases.where((c) =>
                c['title']!.toLowerCase().contains(query) ||
                c['citation']!.toLowerCase().contains(query) ||
                c['summary']!.toLowerCase().contains(query)).toList();
        _isSearching = false;
      });
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Precedent Finder', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Search by case name, citation, or keyword...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
                  : _results.isEmpty
                      ? Center(child: Text('No precedents found', style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600])))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _results.length,
                          itemBuilder: (_, i) {
                            final c = _results[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(c['title']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(c['citation']!, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.deepBlue)),
                                    const SizedBox(height: 6),
                                    Text(c['summary']!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87)),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.deepBlue),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}