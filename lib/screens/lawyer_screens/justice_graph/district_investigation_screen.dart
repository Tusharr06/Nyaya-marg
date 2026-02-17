import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'justice_graph_service.dart';

class DistrictInvestigationScreen extends StatefulWidget {
  const DistrictInvestigationScreen({super.key});

  @override
  State<DistrictInvestigationScreen> createState() => _DistrictInvestigationScreenState();
}

class _DistrictInvestigationScreenState extends State<DistrictInvestigationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String _selectedState = 'Karnataka';
  String _selectedDistrict = 'Bangalore';
  String _selectedCaseType = 'Civil';

  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  final List<String> _districts = [
    'Bangalore',
    'Mysore',
    'Dharwad',
    'Belgaum',
    'Gulbarga',
    'Mangalore',
    'Shimoga',
    'Udupi'
  ];

  final List<String> _caseTypes = [
    'Civil',
    'Criminal',
    'Family',
    'Property',
    'Revenue',
    'Motor Vehicle Claim'
  ];

  Future<void> _analyze() async {
    setState(() {
      _isLoading = true;
      _result = null;
      _error = null;
    });

    try {
      final res = await JusticeGraphService.predictDistrictBacklog(
        state: _selectedState,
        district: _selectedDistrict,
        caseType: _selectedCaseType,
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('District Case Investigation',
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
              _buildHeroSection(),
              const SizedBox(height: 24),
              _buildDropdownField('State', _selectedState, ['Karnataka'], (v) => setState(() => _selectedState = v!)),
              _buildDropdownField('District', _selectedDistrict, _districts, (v) => setState(() => _selectedDistrict = v!)),
              _buildDropdownField('Case Category', _selectedCaseType, _caseTypes, (v) => setState(() => _selectedCaseType = v!)),
              const SizedBox(height: 32),
              _buildAnalyzeButton(),
              const SizedBox(height: 32),
              if (_isLoading) _buildLoader(),
              if (_error != null) _buildError(),
              if (_result != null) _buildResultView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.location_searching, color: Colors.indigo, size: 40),
          const SizedBox(height: 12),
          Text(
            'Regional Backlog Data',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by JusticeGraph Regional Dataset',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('  $label', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black54)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [Colors.indigo, Colors.blueAccent]),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _analyze,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text('FETCH DISTRICT INSIGHTS',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildLoader() {
    return const Center(child: CircularProgressIndicator(color: Colors.indigo));
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(15)),
      child: Text(_error!, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildResultView() {
    final days = _result!['estimated_duration_days'] as double;
    final years = _result!['estimated_duration_years'] as double;
    final confidence = _result!['confidence'] as String;
    final explanation = _result!['explanation'] as String;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard('Days', days.toStringAsFixed(0), Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('Years', years.toStringAsFixed(1), Colors.orange),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.verified_user, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text('Confidence: $confidence',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                explanation,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}
