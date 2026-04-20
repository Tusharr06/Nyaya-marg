import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../core/models/legal_models.dart';
import '../../data/repositories/legal_repository.dart';
import '../../shared/widgets/explanation_widgets.dart';
import '../../shared/widgets/insight_card.dart';
import '../../shared/widgets/data_source_indicator.dart';
import '../../core/models/data_source.dart';
import '../../theme/premium_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class CaseDetailScreen extends StatefulWidget {
  final String caseId;

  const CaseDetailScreen({super.key, required this.caseId});

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  late final LegalRepository _repository;
  CaseModel? _case;
  CaseInsight? _insight;
  bool _isLoading = true;

  @override
  void initState() {
    _repository = context.read<LegalRepository>();
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final caseData = await _repository.getCaseDetail(widget.caseId);
      final insightData = await _repository.getCaseInsight(widget.caseId);
      setState(() {
        _case = caseData;
        _insight = insightData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: PremiumTheme.primaryGold)));
    }

    if (_case == null) return const Scaffold(body: Center(child: Text("Case not found")));

    return Scaffold(
      appBar: AppBar(
        title: Text(_case!.caseNumber),
        actions: [
          const DataSourceIndicator(type: DataSourceType.live),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            if (_insight != null) ...[
              InsightCard(
                title: _insight!.title,
                message: _insight!.message,
              ),
              const SizedBox(height: 16),
              ExplanationCard(
                positives: _insight!.positives,
                negatives: _insight!.negatives,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RiskBadge(level: _insight!.riskLevel),
                  _buildConfidenceMeter(_insight!.confidence),
                ],
              ),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle("Case Particulars"),
            _buildDetailGrid(),
            const SizedBox(height: 24),
            _buildSectionTitle("Recent Orders"),
            _buildOrderCard(),
            const SizedBox(height: 40),
            _buildDisclaimer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _case!.title,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
        ).animate().fadeIn().slideX(),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.account_balance, size: 16, color: Colors.white54),
            const SizedBox(width: 8),
            Text(_case!.courtName, style: const TextStyle(color: Colors.white54)),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: PremiumTheme.primaryGold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildDetailGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: [
        _buildInfoTile("Status", _case!.status, PremiumTheme.accentCyan),
        _buildInfoTile("Next Hearing", DateFormat('dd MMM yyyy').format(_case!.nextHearingDate!), PremiumTheme.warningYellow),
        _buildInfoTile("Judge", _case!.judgeName, Colors.white),
        _buildInfoTile("Court Hall", _case!.courtHall, Colors.white),
        _buildInfoTile("Filing Date", DateFormat('dd MMM yyyy').format(_case!.filingDate), Colors.white),
        _buildInfoTile("Category", "Civil", Colors.white),
      ],
    );
  }

  Widget _buildInfoTile(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Last Order: 12 April 2024", style: TextStyle(color: Colors.white54, fontSize: 12)),
              IconButton(icon: const Icon(Icons.download, size: 20, color: PremiumTheme.primaryGold), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _case!.lastOrderSummary,
            style: const TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceMeter(double confidence) {
    final percentage = (confidence * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "Confidence: $percentage%",
          style: const TextStyle(color: PremiumTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          width: 100,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [PremiumTheme.primaryGold, PremiumTheme.accentCyan]),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.white24, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "⚠️ This is AI-generated insight, not legal advice.",
              style: TextStyle(color: Colors.white24, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
