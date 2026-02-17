import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/theme/colors.dart';
import 'justice_graph_service.dart';

class BacklogRiskScreen extends StatefulWidget {
  const BacklogRiskScreen({super.key});

  @override
  State<BacklogRiskScreen> createState() => _BacklogRiskScreenState();
}

class _BacklogRiskScreenState extends State<BacklogRiskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judgeStrengthCtrl = TextEditingController(text: '15');
  final _pendingCasesCtrl = TextEditingController(text: '5000');
  final _filingRateCtrl = TextEditingController(text: '200.5');
  final _disposalRateCtrl = TextEditingController(text: '180.2');
  final _budgetCtrl = TextEditingController(text: '1200.0');
  final _shortfallCtrl = TextEditingController(text: '2.5');

  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final res = await JusticeGraphService.predictBacklog(
        judgeStrength: int.parse(_judgeStrengthCtrl.text),
        pendingCases: int.parse(_pendingCasesCtrl.text),
        filingRate: double.parse(_filingRateCtrl.text),
        disposalRate: double.parse(_disposalRateCtrl.text),
        budgetPerCapita: double.parse(_budgetCtrl.text),
        courthallShortfall: double.parse(_shortfallCtrl.text),
      );
      setState(() {
        _result = res;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Backlog Risk Predictor',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildInputField('Judge Strength', _judgeStrengthCtrl, Icons.people, isInt: true),
              _buildInputField('Pending Cases', _pendingCasesCtrl, Icons.folder_open, isInt: true),
              _buildInputField('Filing Rate (per month)', _filingRateCtrl, Icons.trending_up),
              _buildInputField('Disposal Rate (per month)', _disposalRateCtrl, Icons.trending_down),
              _buildInputField('Budget Per Capita (INR)', _budgetCtrl, Icons.account_balance_wallet),
              _buildInputField('Courthall Shortfall', _shortfallCtrl, Icons.domain_disabled),
              const SizedBox(height: 32),
              _buildAnalyzeButton(),
              const SizedBox(height: 24),
              if (_isLoading) _buildLoader(),
              if (_error != null) _buildError(),
              if (_result != null) _buildResult(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.deepBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, color: AppColors.deepBlue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Scientifically predict the backlog risk level of a court using ML markers.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController ctrl, IconData icon, {bool isInt = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.poppins(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColors.deepBlue, size: 20),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (isInt && int.tryParse(v) == null) return 'Must be an integer';
              if (!isInt && double.tryParse(v) == null) return 'Must be a number';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _analyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: Text('ANALYZE BACKLOG RISK',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.deepBlue),
          SizedBox(height: 16),
          Text('Running ML Inference...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
      child: Text(_error!, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildResult() {
    final score = _result!['risk_score'] as double;
    final level = _result!['risk_level'] as String;
    final explanation = _result!['explanation'] as Map<String, dynamic>;

    Color levelColor = Colors.green;
    if (level == 'High') levelColor = Colors.red;
    if (level == 'Moderate') levelColor = Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inference Result', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: levelColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: levelColor.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Risk Score', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text('${(score * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: levelColor)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Risk Level', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: levelColor, borderRadius: BorderRadius.circular(20)),
                    child: Text(level, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Factor Insights', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...explanation.entries.map((e) => _buildExplanationTile(e.key, e.value.toString())).toList(),
      ],
    );
  }

  Widget _buildExplanationTile(String key, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.deepBlue),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.poppins(color: Colors.black87, fontSize: 13),
                children: [
                  TextSpan(text: '${key.replaceAll('_', ' ').toUpperCase()}: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
