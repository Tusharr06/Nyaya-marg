import 'package:flutter/material.dart';
import 'theme/premium_theme.dart';
import 'screens/client_screen/home_screen.dart';
import 'screens/client_screen/chat_screen.dart';
import 'screens/client_screen/court_explorer_screen.dart';
import 'screens/client_screen/precedents_screen.dart';
import 'screens/client_screen/analytics_screen.dart';
import 'data/repositories/legal_repository.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const NyayMargApp());
}

class NyayMargApp extends StatelessWidget {
  const NyayMargApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LegalRepository>(create: (_) => ApiLegalRepository()),
      ],
      child: MaterialApp(
        title: 'NyayMarg',
        theme: PremiumTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const MainNavigationWrapper(),
      ),
    );
  }
}

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const PrecedentsScreen(),
    const ChatScreen(),
    const CourtExplorerScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: PremiumTheme.deepBlue,
          selectedItemColor: PremiumTheme.primaryGold,
          unselectedItemColor: Colors.white24,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.library_books_outlined), activeIcon: Icon(Icons.library_books), label: "Precedents"),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: "AI Help"),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance_outlined), activeIcon: Icon(Icons.account_balance), label: "Explorer"),
            BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics), label: "Stats"),
          ],
        ),
      ),
    );
  }
}