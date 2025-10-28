// home_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:nyaya_marg/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Form
  String? _selectedCity;
  String? _selectedCaseType;
  String _priority = '';
  final _priorityController = TextEditingController();

  // UI
  String _userName = 'User';
  bool _isLoadingUser = true;
  bool _isAnalyzing = false;
  bool _showResult = false;
  Map<String, dynamic> _analysis = {};
  String? _error;

  // API
  final String _apiUrl =
      'https://unsectionalised-clingiest-dorris.ngrok-free.dev/analyze';

  final List<String> _cities = [
    'Ahmedabad', 'Bangalore', 'Chandigarh', 'Chennai', 'Delhi',
    'Hyderabad', 'Jaipur', 'Kochi', 'Kolkata', 'Lucknow', 'Pune'
  ];
  final List<String> _caseTypes = [
    'Criminal', 'Civil', 'Constitutional', 'Corporate',
    'Family', 'Property', 'Tax', 'Cybercrime'
  ];

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
        _isLoadingUser = false;
      });
    } else {
      setState(() => _isLoadingUser = false);
    }
  }

  // ── SAFE STRING (Handles Map/List/Null) ──
  String _safeString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value;
    if (value is num) return value.toStringAsFixed(2).replaceAllMapped(RegExp(r'0+$'), (m) => '').replaceAllMapped(RegExp(r'\.$'), (m) => '');
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  Future<void> _analyzeCase() async {
    if (_selectedCity == null || _selectedCaseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select City and Case Type')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final Map<String, String> queryParams = {
        'state': _selectedCity!,
        'case_type': _selectedCaseType!,
        if (_priority.trim().isNotEmpty) 'priority': _priority.trim(),
      };

      final uri = Uri.parse(_apiUrl).replace(queryParameters: queryParams);
      print('POST → $uri');

      final response = await http
          .post(
            uri,
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      print('Status: ${response.statusCode}');
      print('Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _analysis = data;
          _showResult = true;
          _isAnalyzing = false;
        });
      } else {
        setState(() {
          _error = 'Server error: ${response.statusCode}\n${response.body}';
          _isAnalyzing = false;
        });
      }
    } on SocketException {
      setState(() {
        _error = 'No internet connection.';
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Request failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCity = null;
      _selectedCaseType = null;
      _priorityController.clear();
      _priority = '';
      _showResult = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: _showResult ? _buildResult() : _buildForm(),
      ),
    );
  }

  // ───── FORM UI ─────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello $_userName!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.deepBlue)),
          const SizedBox(height: 8),
          Text('Let’s analyze your case with AI-powered insights.', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 24),
          _buildDropdown(label: 'Enter your City/State', hint: 'Select city', items: _cities, value: _selectedCity, onChanged: (v) => setState(() => _selectedCity = v)),
          _buildDropdown(label: 'Enter Case Type', hint: 'Select case type', items: _caseTypes, value: _selectedCaseType, onChanged: (v) => setState(() => _selectedCaseType = v)),
          _buildInputField(label: 'Enter Priority (optional)', controller: _priorityController, hint: 'e.g., Low, Medium, High', onChanged: (v) => _priority = v),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeCase,
              icon: _isAnalyzing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.analytics),
              label: Text(_isAnalyzing ? 'ANALYZING...' : 'ANALYZE CASE'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), elevation: 3),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: GoogleFonts.poppins(color: Colors.red, fontSize: 14))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ───── RESULT UI ─────
  Widget _buildResult() {
    final a = _analysis;

    // ── EXTRACT NESTED VALUES ──
    final court = a['court'] as Map<String, dynamic>? ?? {};
    final prediction = a['prediction'] as Map<String, dynamic>? ?? {};
    final timeline = a['timeline'] as Map<String, dynamic>? ?? {};

    final courtName = _safeString(court['name']);
    final state = _safeString(court['state']);
    final riskScore = court['risk_score'] ?? 0.0;
    final pendingCases = court['pending_cases'] ?? 0;
    final outcome = _safeString(prediction['outcome']);
    final confidence = prediction['confidence'] ?? 0.0;
    final timelineDays = timeline['expected_days'] ?? 0;

    // Risk Level
    String riskLevel;
    if (riskScore < 0.3) riskLevel = 'Low Risk';
    else if (riskScore < 0.6) riskLevel = 'Medium Risk';
    else riskLevel = 'High Risk';

    // Overall Assessment
    final isFavorable = outcome.toLowerCase().contains('favorable');
    final overallAssessment = isFavorable ? 'GOOD' : 'BAD';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Hello ', style: GoogleFonts.poppins(fontSize: 24, color: Colors.black87)),
              Text('$_userName!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.deepBlue)),
              const Spacer(),
              CircleAvatar(radius: 24, backgroundColor: AppColors.deepBlue.withOpacity(0.2), child: const Icon(Icons.balance, color: AppColors.deepBlue)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Here's your case overview for today.", style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 24),

          // ── CASE OUTLOOK SUMMARY ──
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASE OUTLOOK SUMMARY', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 12),
                  _summaryRow(icon: Icons.circle, color: overallAssessment == 'GOOD' ? Colors.orange : Colors.red, label: 'Overall Assessment:', value: overallAssessment, badge: true),
                  _summaryRow(icon: Icons.location_city, label: 'Court', value: courtName),
                  _summaryRow(icon: Icons.folder_open, label: 'Case Type', value: _selectedCaseType ?? 'N/A'),
                  _summaryRow(icon: Icons.flag, label: 'Priority', value: _priority.isEmpty ? 'N/A' : _priority),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('KEY METRICS', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.deepBlue)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _metricCard(icon: Icons.check_circle, color: Colors.green, title: 'Court Risk Level', value: riskLevel),
              _metricCard(icon: Icons.close, color: Colors.red, title: 'Predicted Outcome', value: outcome),
              _metricCard(icon: Icons.bar_chart, color: Colors.orange, title: 'Confidence', value: '$confidence%'),
              _metricCard(icon: Icons.access_time, color: AppColors.deepBlue, title: 'Expected Timeline', value: '~$timelineDays days'),
            ],
          ),

          const SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(isFavorable ? Icons.check_circle : Icons.warning, color: isFavorable ? Colors.green : Colors.orange, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Court: $courtName, State: $state', style: GoogleFonts.poppins(fontSize: 14))),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('Next Steps', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.deepBlue)),
          const SizedBox(height: 12),
          Card(
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
          ),

          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.refresh),
              label: const Text('New Analysis'),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.deepBlue, side: const BorderSide(color: AppColors.deepBlue), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
            ),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE WIDGETS ──
  Widget _buildDropdown({required String label, required String hint, required List<String> items, required String? value, required Function(String?) onChanged}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.deepBlue)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              hint: Text(hint, style: GoogleFonts.poppins(color: Colors.grey[600])),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              icon: const Icon(Icons.arrow_drop_down, color: AppColors.deepBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required TextEditingController controller, required String hint, required Function(String) onChanged}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.deepBlue)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(color: Colors.grey[600]), border: InputBorder.none, isDense: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow({required IconData icon, required String label, required dynamic value, Color? color, bool badge = false}) {
    String displayValue = _safeString(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.deepBlue),
          const SizedBox(width: 12),
          Expanded(flex: 2, child: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black.withOpacity(0.7)), softWrap: true)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: badge
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: (color ?? Colors.orange).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text(displayValue, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color ?? Colors.orange), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, maxLines: 1),
                    )
                  : Text(displayValue, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87), textAlign: TextAlign.end, overflow: TextOverflow.ellipsis, maxLines: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({required IconData icon, required Color color, required String title, required dynamic value}) {
    String displayValue = _safeString(value);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(title, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black54), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(displayValue, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
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
        Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87))),
      ],
    );
  }
}