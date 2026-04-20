import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../core/models/legal_models.dart';
import '../../data/repositories/legal_repository.dart';
import '../../shared/widgets/court_widgets.dart';
import '../../shared/widgets/insight_card.dart';
import '../../theme/premium_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'court_detail_screen.dart';

class CourtExplorerScreen extends StatefulWidget {
  const CourtExplorerScreen({super.key});

  @override
  State<CourtExplorerScreen> createState() => _CourtExplorerScreenState();
}

class _CourtExplorerScreenState extends State<CourtExplorerScreen> {
  late final LegalRepository _repository;
  List<Court>? _courts;
  final String _selectedLocation = "Bengaluru";
  bool _isLoading = true;

  @override
  void initState() {
    _repository = context.read<LegalRepository>();
    super.initState();
    _loadCourts();
  }

  Future<void> _loadCourts() async {
    setState(() => _isLoading = true);
    try {
      final courts = await _repository.getCourts(location: _selectedLocation);
      setState(() {
        _courts = courts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Court Explorer"),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: PremiumTheme.primaryGold),
            onPressed: () {
              // Simulate location detection
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   InsightCard(
                    title: "Live Location",
                    message: "Automatically detected Bengaluru. Showing 5 courts nearby.",
                    icon: Icons.my_location,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Available Courts",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.filter_list, size: 18),
                        label: const Text("Filters"),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: SkeletonLoader(height: 120),
                  ),
                  childCount: 4,
                ),
              ),
            )
          else if (_courts == null || _courts!.isEmpty)
            const SliverToBoxAdapter(
              child: Center(child: Text("No courts found.")),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final court = _courts![index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CourtDetailScreen(court: court)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: PremiumTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    court.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: PremiumTheme.primaryGold.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    court.type,
                                    style: const TextStyle(color: PremiumTheme.primaryGold, fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.white54),
                                const SizedBox(width: 4),
                                Text(court.location, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                const Spacer(),
                                const Icon(Icons.gavel, size: 14, color: PremiumTheme.accentCyan),
                                const SizedBox(width: 4),
                                Text("${court.activeCases} Active Cases", 
                                  style: const TextStyle(color: PremiumTheme.accentCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2),
                    );
                  },
                  childCount: _courts!.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
