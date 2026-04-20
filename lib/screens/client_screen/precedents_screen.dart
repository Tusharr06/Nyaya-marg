import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../core/models/legal_models.dart';
import '../../data/repositories/legal_repository.dart';
import '../../shared/widgets/data_source_indicator.dart';
import '../../core/models/data_source.dart';
import '../../theme/premium_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'case_detail_screen.dart';

class PrecedentsScreen extends StatefulWidget {
  const PrecedentsScreen({super.key});

  @override
  State<PrecedentsScreen> createState() => _PrecedentsScreenState();
}

class _PrecedentsScreenState extends State<PrecedentsScreen> {
  late final LegalRepository _repository;
  List<CaseModel>? _cases;
  bool _isLoading = true;

  @override
  void initState() {
    _repository = context.read<LegalRepository>();
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    final cases = await _repository.getCases();
    setState(() {
      _cases = cases;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Precedents Explorer"),
        actions: [
          IconButton(icon: const Icon(Icons.sort), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_alt_outlined, color: PremiumTheme.primaryGold), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _isLoading ? _buildLoading() : _buildList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: PremiumTheme.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, size: 20, color: Colors.white24),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Property dispute Bengaluru...",
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
      ).animate(onPlay: (c) => c.repeat()).shimmer(),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cases?.length ?? 0,
      itemBuilder: (context, index) {
        final item = _cases![index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CaseDetailScreen(caseId: item.id)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
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
                    Text(item.caseNumber, style: const TextStyle(color: PremiumTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                    const DataSourceIndicator(type: DataSourceType.dataset),
                  ],
                ),
                const SizedBox(height: 8),
                Text(item.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTag("Match: ${(item.predictionConfidence * 100).toInt()}%", PremiumTheme.accentCyan),
                    const SizedBox(width: 8),
                    _buildTag(item.status, item.status == 'Active' ? PremiumTheme.successGreen : Colors.white38),
                  ],
                ),
                const Divider(height: 24, color: Colors.white10),
                Row(
                  children: [
                    const Icon(Icons.account_balance, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item.courtName, style: const TextStyle(color: Colors.white54, fontSize: 11))),
                    const Text("Updated 2 mins ago", style: TextStyle(color: Colors.white24, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 100).ms).slideX(),
        );
      },
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
