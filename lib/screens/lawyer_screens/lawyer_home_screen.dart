// lib/screens/lawyer_home_screen.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/screens/client_screen/chat_screen.dart';
import 'package:nyaya_marg/screens/client_screen/tools_screen.dart';
import 'package:nyaya_marg/theme/colors.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class LawyerHomeScreen extends StatefulWidget {
  const LawyerHomeScreen({super.key});

  @override
  State<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends State<LawyerHomeScreen> {
  // Form
  String? _selectedCity;
  String? _selectedCaseType;
  String? _selectedPriority;
  final _priorityOptions = ['Low', 'Medium', 'High'];

  // UI
  String _userName = 'Advocate';
  bool _isLoadingUser = true;
  bool _isAnalyzing = false;
  bool _showResult = false;
  Map<String, dynamic> _analysis = {};
  String? _error;

  // Gemini API
  final String _geminiApiKey = 'AIzaSyAUOLlfY3S9sQzaIEijYqJscZq6tzv9rnI';
  GenerativeModel? _model;

  // Dropdowns
  final List<String> _cities = [
    'Ahmedabad', 'Bangalore', 'Chandigarh', 'Chennai', 'Delhi',
    'Hyderabad', 'Jaipur', 'Kochi', 'Kolkata', 'Lucknow', 'Pune'
  ];
  final List<String> _caseTypes = [
    'Wrongful Termination', 'Employment', 'Property Dispute', 'Property',
    'Road Accident', 'Other'
  ];

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
    _initGemini();
  }

  Future<void> _initGemini() async {
    if (_geminiApiKey.startsWith('YOUR_') || _geminiApiKey.isEmpty) {
      setState(() => _error = 'Gemini API key not set!');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _geminiApiKey,
    );
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

  // ── SAFE STRING ──
  String _safeString(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String) return value;
    if (value is num) return value.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  // ── ANALYZE CASE USING GEMINI ──
  Future<void> _analyzeCase() async {
    if (_selectedCity == null || _selectedCaseType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select City and Case Type')),
      );
      return;
    }

    if (_model == null) {
      setState(() => _error = 'Gemini model not initialized. Check API key.');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _error = null;
    });

    try {
      final prompt = '''
You are a legal AI assistant for Indian courts. Analyze the case:

- City: $_selectedCity
- Case Type: $_selectedCaseType
- Priority: ${_selectedPriority ?? 'Not specified'}

Return **exactly** this JSON (no extra text):

{
  "court": {
    "name": "string",
    "state": "string",
    "risk_score": 0.0-1.0,
    "pending_cases": integer
  },
  "prediction": {
    "success_probability": 0.0-1.0,
    "confidence": 0.76-1.0   // ALWAYS >= 0.76
  },
  "timeline": {
    "expected_days": integer
  }
}

Use realistic Indian court data. **confidence must be >= 0.76**.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      final text = response.text ?? '';
      final jsonMatch = RegExp(r'\{.*\}', dotAll: true).firstMatch(text);

      if (jsonMatch == null) throw Exception('No JSON in response');

      final data = jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;

      // Enforce confidence >= 76%
      final prediction = data['prediction'] as Map<String, dynamic>? ?? {};
      final confidence = prediction['confidence'] as num? ?? 0.0;
      if (confidence < 0.76) {
        prediction['confidence'] = 0.76 + (confidence * 0.24);
      }

      setState(() {
        _analysis = data;
        _showResult = true;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Gemini Error: $e';
        _isAnalyzing = false;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCity = null;
      _selectedCaseType = null;
      _selectedPriority = null;
      _showResult = false;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.deepBlue,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatScreen())),
      ),
      body: SafeArea(child: _showResult ? _buildResult() : _buildForm()),
    );
  }

  // ── FORM UI ──
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello $_userName!', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.deepBlue)),
          const SizedBox(height: 8),
          Text('Analyze cases with AI-powered insights.', style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87)),
          const SizedBox(height: 24),

          _buildDropdown(
            label: 'City',
            hint: 'Select city',
            items: _cities,
            value: _selectedCity,
            onChanged: (v) => setState(() => _selectedCity = v),
          ),
          _buildDropdown(
            label: 'Case Type',
            hint: 'Select case type',
            items: _caseTypes,
            value: _selectedCaseType,
            onChanged: (v) => setState(() => _selectedCaseType = v),
          ),
          _buildDropdown(
            label: 'Priority',
            hint: 'Select priority',
            items: _priorityOptions,
            value: _selectedPriority,
            onChanged: (v) => setState(() => _selectedPriority = v),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _analyzeCase,
              icon: _isAnalyzing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.analytics),
              label: Text(_isAnalyzing ? 'ANALYZING...' : 'ANALYZE CASE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.deepBlue,
                elevation: 3,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: AppColors.deepBlue, width: 1.5),
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
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: GoogleFonts.poppins(color: Colors.red, fontSize: 14))),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          // CITIZEN CASES
          Text('Choose your case', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _citizenCases.length,
              itemBuilder: (ctx, i) {
                final c = _citizenCases[i];
                return Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['title']!, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(c['category']!, style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: Text('View More', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // TOOLS
          Row(
            children: [
              Expanded(
                child: _buildFeatureTile(
                  'Document Summarizer',
                  Icons.description,
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentSummarizerScreen())),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFeatureTile(
                  'Precedent Finder',
                  Icons.gavel,
                  Colors.purple,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrecedentFinderScreen())),
                ),
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── RESULT UI (4 METRICS - FIXED) ──
  Widget _buildResult() {
    final a = _analysis;
    final court = a['court'] as Map<String, dynamic>? ?? {};
    final prediction = a['prediction'] as Map<String, dynamic>? ?? {};
    final timeline = a['timeline'] as Map<String, dynamic>? ?? {};

    final courtName = _safeString(court['name']);
    final state = _safeString(court['state']);
    final riskScore = court['risk_score'] ?? 0.0;
    final pendingCases = court['pending_cases'] ?? 0; // Fixed: was 'pendingdingCases'

    final successProb = (prediction['success_probability'] ?? 0.0) * 100;
    final confidence = (prediction['confidence'] ?? 0.0) * 100;
    final timelineDays = timeline['expected_days'] ?? 0;

    // ── OVERALL ASSESSMENT (all 4 must be good) ──
    final isHighSuccess = successProb >= 60;
    final isLowRisk = riskScore < 0.4;
    final isLowBacklog = pendingCases < 5000; // Fixed typo
    final isHighConfidence = confidence >= 76;

    final overallAssessment = (isHighSuccess && isLowRisk && isLowBacklog && isHighConfidence) ? 'GOOD' : 'BAD';

    String riskLevel = riskScore < 0.3 ? 'Low Risk' : riskScore < 0.6 ? 'Medium Risk' : 'High Risk';

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

          // CASE OUTLOOK SUMMARY
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
                  _summaryRow(
                    icon: Icons.circle,
                    color: overallAssessment == 'GOOD' ? Colors.orange : Colors.red,
                    label: 'Overall Assessment:',
                    value: overallAssessment,
                    badge: true,
                  ),
                  _summaryRow(icon: Icons.location_city, label: 'Court', value: courtName),
                  _summaryRow(icon: Icons.folder_open, label: 'Case Type', value: _selectedCaseType ?? 'N/A'),
                  _summaryRow(icon: Icons.flag, label: 'Priority', value: _selectedPriority ?? 'N/A'),
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
              _metricCard(icon: Icons.shield, color: Colors.green, title: 'Court Risk Level', value: riskLevel),
              _metricCard(icon: Icons.cases, color: Colors.blue, title: 'Pending Cases', value: '$pendingCases'),
              _metricCard(icon: Icons.access_time, color: AppColors.deepBlue, title: 'Expected Timeline', value: '~$timelineDays days'),
              _metricCard(icon: Icons.bar_chart, color: Colors.orange, title: 'Confidence', value: '${confidence.toStringAsFixed(0)}%'),
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
                  Icon(overallAssessment == 'GOOD' ? Icons.check_circle : Icons.warning,
                      color: overallAssessment == 'GOOD' ? Colors.green : Colors.orange, size: 28),
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
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.deepBlue,
                side: const BorderSide(color: AppColors.deepBlue),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
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

  Widget _buildFeatureTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color), textAlign: TextAlign.center),
          ],
        ),
      ),
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