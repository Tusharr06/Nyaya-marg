import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nyaya_marg/theme/colors.dart';
import 'justice_graph_service.dart';

class CaseDurationScreen extends StatefulWidget {
  const CaseDurationScreen({super.key});

  @override
  State<CaseDurationScreen> createState() => _CaseDurationScreenState();
}

class _CaseDurationScreenState extends State<CaseDurationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Encodings (Based on typical ML label encoding)
  int _selectedCaseType = 5; // Default: Employment
  int _selectedPriority = 1; // Default: Medium
  final _actCountCtrl = TextEditingController(text: '3');
  final _courtLoadCtrl = TextEditingController(text: '0.65');

  bool _isLoading = false;
  double? _predictedDays;
  String? _error;

  final Map<int, String> _caseTypeMap = {
    0: 'Criminal Appeal',
    1: 'Writ Petition',
    2: 'Property Dispute',
    3: 'Family Law',
    4: 'Wrongful Termination',
    5: 'Employment',
    6: 'Road Accident',
    7: 'Consumer Case',
  };

  final Map<int, String> _priorityMap = {
    0: 'Low',
    1: 'Medium',
    2: 'High',
  };

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _predictedDays = null;
      _error = null;
    });

    try {
      final res = await JusticeGraphService.predictDuration(
        caseTypeEncoded: _selectedCaseType,
        priorityEncoded: _selectedPriority,
        actCount: int.parse(_actCountCtrl.text),
        courtLoad: double.parse(_courtLoadCtrl.text),
      );
      setState(() {
        _predictedDays = res['predicted_days'] as double;
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
        title: Text('Duration Estimator',
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
              _buildDropdownField('Case Type', _selectedCaseType, _caseTypeMap, (v) => setState(() => _selectedCaseType = v!)),
              _buildDropdownField('Priority Level', _selectedPriority, _priorityMap, (v) => setState(() => _selectedPriority = v!)),
              _buildInputField('Involved Acts Count', _actCountCtrl, Icons.gavel, isInt: true),
              _buildInputField('Court Load Factor (0.0 - 1.0)', _courtLoadCtrl, Icons.speed),
              const SizedBox(height: 32),
              _buildAnalyzeButton(),
              const SizedBox(height: 24),
              if (_isLoading) _buildLoader(),
              if (_error != null) _buildError(),
              if (_predictedDays != null) _buildResult(),
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
        color: AppColors.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, color: AppColors.primaryBlue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Estimate the total duration of a case from filing to final decision.',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, int value, Map<int, String> items, Function(int?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                onChanged: onChanged,
              ),
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
              prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
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
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: Text('PREDICT DURATION',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.primaryBlue),
          SizedBox(height: 16),
          Text('Processing Regressor...', style: TextStyle(color: Colors.grey)),
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
    final years = (_predictedDays! / 365).toStringAsFixed(1);
    final months = ((_predictedDays! % 365) / 30).toStringAsFixed(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Estimated Timeline', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.deepBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: AppColors.deepBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            children: [
              Text('${_predictedDays!.toStringAsFixed(0)} DAYS',
                  style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text('Approximately $years Years and $months Months',
                  style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withValues(alpha: 0.9))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Note: This prediction is based on the complexity of the case and current court workload. Actual duration may vary based on procedural delays.',
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}
