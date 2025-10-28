// home_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:nyaya_marg/theme/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ── FORM ───────────────────────────────────────────────────────────────
  String? _selectedCity;
  String? _selectedCaseType;
  String _priority = '';
  final _priorityController = TextEditingController();

  // ── UI ─────────────────────────────────────────────────────────────────
  String _userName = 'User';
  bool _isLoadingUser = true;
  bool _isAnalyzing = false;
  bool _showResult = false;
  Map<String, dynamic> _analysis = {};
  String? _error;

  // ── GEMINI ─────────────────────────────────────────────────────────────
  final String _geminiApiKey =
      'AIzaSyAUOLlfY3S9sQzaIEijYqJscZq6tzv9rnI'; // <-- replace / secure
  GenerativeModel? _model;

  // ── DROPDOWNS ──────────────────────────────────────────────────────────
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
    _initGemini();
  }

  // ── GEMINI INITIALISATION ───────────────────────────────────────────────
  Future<void> _initGemini() async {
    if (_geminiApiKey.startsWith('YOUR_') || _geminiApiKey.isEmpty) {
      setState(() => _error = 'Gemini API key not set!');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash', // or gemini-2.5-flash if available
      apiKey: _geminiApiKey,
    );
  }

  // ── USER NAME ───────────────────────────────────────────────────────────
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

  // ── SAFE STRING ─────────────────────────────────────────────────────────
  String _safeString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value;
    if (value is num) {
      return value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  // ── ANALYZE WITH GEMINI ─────────────────────────────────────────────────
  Future<void> _analyzeCase() async {
    if (_selectedCity == null || _selectedCaseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select City and Case Type')),
      );
      return;
    }

    if (_model == null) {
      setState(() => _error = 'Gemini model not initialized.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final prompt = '''
You are a legal AI assistant for Indian courts.  
Analyze the case with the following inputs:

- City: $_selectedCity
- Case Type: $_selectedCaseType
- Priority: ${_priority.trim().isEmpty ? 'Not specified' : _priority.trim()}

Return **exactly** this JSON structure (no extra text):

{
  "court": {
    "name": "string",
    "state": "string",
    "risk_score": 0.0-1.0,
    "pending_cases": integer
  },
  "prediction": {
    "success_probability": 0.0-1.0,
    "confidence": 0.0-1.0
  },
  "timeline": {
    "expected_days": integer
  }
}
Be concise, realistic, and base numbers on typical Indian court data.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);

      if (jsonMatch == null) throw Exception('No JSON in Gemini response');

      final data = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      setState(() {
        _analysis = data;
        _showResult = true;
        _isAnalyzing = false;
      });
    } on SocketException {
      setState(() {
        _error = 'No internet connection.';
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gemini Error: $e';
        _isAnalyzing = false;
      });
    }
  }

  // ── RESET ───────────────────────────────────────────────────────────────
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

  // ── BUILD ───────────────────────────────────────────────────────────────
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

  // ── FORM UI ────────────────────────────────────────────────────────────
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello $_userName!',
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue)),
          const SizedBox(height: 8),
          Text('Let’s analyze your case with AI-powered insights.',
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 24),

          _buildDropdown(
              label: 'Enter your City/State',
              hint: 'Select city',
              items: _cities,
              value: _selectedCity,
              onChanged: (v) => setState(() => _selectedCity = v)),
          _buildDropdown(
              label: 'Enter Case Type',
              hint: 'Select case type',
              items: _caseTypes,
              value: _selectedCaseType,
              onChanged: (v) => setState(() => _selectedCaseType = v)),
          _buildInputField(
              label: 'Enter Priority (optional)',
              controller: _priorityController,
              hint: 'e.g., Low, Medium, High',
              onChanged: (v) => _priority = v),

          const SizedBox(height: 32),

          // ── NEW BUTTON STYLE (same as lawyer screen) ─────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeCase,
              icon: _isAnalyzing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.analytics),
              label: Text(_isAnalyzing ? 'ANALYZING...' : 'ANALYZE CASE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.deepBlue,
                elevation: 3,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side:
                      const BorderSide(color: AppColors.deepBlue, width: 1.5),
                ),
              ),
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.red.withOpacity(0.3))),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: GoogleFonts.poppins(
                              color: Colors.red, fontSize: 14))),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── RESULT UI ───────────────────────────────────────────────────────────
  Widget _buildResult() {
    final a = _analysis;

    final court = a['court'] as Map<String, dynamic>? ?? {};
    final prediction = a['prediction'] as Map<String, dynamic>? ?? {};
    final timeline = a['timeline'] as Map<String, dynamic>? ?? {};

    final courtName = _safeString(court['name']);
    final state = _safeString(court['state']);
    final riskScore = court['risk_score'] ?? 0.0;
    final pendingCases = court['pending_cases'] ?? 0;

    // NEW: success_probability (0-1) → 0-100%
    final successProb = (prediction['success_probability'] ?? 0.0) * 100;
    final confidence = (prediction['confidence'] ?? 0.0) * 100;
    final timelineDays = timeline['expected_days'] ?? 0;

    String riskLevel =
        riskScore < 0.3 ? 'Low Risk' : riskScore < 0.6 ? 'Medium Risk' : 'High Risk';
    final overallAssessment = successProb >= 60 ? 'GOOD' : 'BAD';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Hello ',
                  style: GoogleFonts.poppins(
                      fontSize: 24, color: Colors.black87)),
              Text('$_userName!',
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepBlue)),
              const Spacer(),
              CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.deepBlue.withOpacity(0.2),
                  child: const Icon(Icons.balance,
                      color: AppColors.deepBlue)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Here's your case overview for today.",
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 24),

          // ── SUMMARY ─────────────────────────────────────────────────────
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CASE OUTLOOK SUMMARY',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 12),
                  _summaryRow(
                      icon: Icons.circle,
                      color: overallAssessment == 'GOOD'
                          ? Colors.orange
                          : Colors.red,
                      label: 'Overall Assessment:',
                      value: overallAssessment,
                      badge: true),
                  _summaryRow(
                      icon: Icons.location_city,
                      label: 'Court',
                      value: courtName),
                  _summaryRow(
                      icon: Icons.folder_open,
                      label: 'Case Type',
                      value: _selectedCaseType ?? 'N/A'),
                  _summaryRow(
                      icon: Icons.flag,
                      label: 'Priority',
                      value: _priority.isEmpty ? 'N/A' : _priority),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('KEY METRICS',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue)),
          const SizedBox(height: 12),

          // ── METRICS GRID ───────────────────────────────────────────────
          GridView.count(
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
                  value: riskLevel),
              // NEW METRIC
              _metricCard(
                  icon: Icons.trending_up,
                  color: Colors.blue,
                  title: 'Success Probability',
                  value: '${successProb.toStringAsFixed(0)}%'),
              _metricCard(
                  icon: Icons.bar_chart,
                  color: Colors.orange,
                  title: 'Confidence',
                  value: '${confidence.toStringAsFixed(0)}%'),
              _metricCard(
                  icon: Icons.access_time,
                  color: AppColors.deepBlue,
                  title: 'Expected Timeline',
                  value: '~$timelineDays days'),
            ],
          ),

          const SizedBox(height: 20),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                      successProb >= 60 ? Icons.check_circle : Icons.warning,
                      color: successProb >= 60 ? Colors.green : Colors.orange,
                      size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text('Court: $courtName, State: $state',
                          style: GoogleFonts.poppins(fontSize: 14))),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text('Next Steps',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.deepBlue)),
          const SizedBox(height: 12),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _stepRow(Icons.search,
                      'Monitor case status via eCourts portal'),
                  const SizedBox(height: 12),
                  _stepRow(Icons.description,
                      'Prepare documentation per court guidelines'),
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
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepBlue,
                  side: const BorderSide(color: AppColors.deepBlue),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25))),
            ),
          ),
        ],
      ),
    );
  }

  // ── REUSABLE WIDGETS ───────────────────────────────────────────────────
  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
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
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.deepBlue)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: value,
              hint: Text(hint,
                  style: GoogleFonts.poppins(color: Colors.grey[600])),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: onChanged,
              decoration:
                  const InputDecoration(border: InputBorder.none, isDense: true),
              icon: const Icon(Icons.arrow_drop_down,
                  color: AppColors.deepBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
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
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.deepBlue)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      GoogleFonts.poppins(color: Colors.grey[600]),
                  border: InputBorder.none,
                  isDense: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow({
    required IconData icon,
    required String label,
    required dynamic value,
    Color? color,
    bool badge = false,
  }) {
    final display = _safeString(value);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.deepBlue),
          const SizedBox(width: 12),
          Expanded(
              flex: 2,
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: Colors.black.withOpacity(0.7)),
                  softWrap: true)),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: badge
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: (color ?? Colors.orange).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(display,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color ?? Colors.orange),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1),
                    )
                  : Text(display,
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.black87),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color color,
    required String title,
    required dynamic value,
  }) {
    final display = _safeString(value);
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
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 11, color: Colors.black54),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(display,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
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
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.black87))),
      ],
    );
  }
}