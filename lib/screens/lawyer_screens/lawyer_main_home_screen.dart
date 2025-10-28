// lib/lawyer_screens/main_home_screen.dart
import 'package:flutter/material.dart';
import 'package:nyaya_marg/screens/lawyer_screens/lawyer_home_screen.dart';
import 'package:nyaya_marg/screens/lawyer_screens/lawyer_profile_screen.dart';
import 'package:nyaya_marg/theme/colors.dart';  

class LawyerMainHomeScreen extends StatefulWidget {
  const LawyerMainHomeScreen({super.key});

  @override
  State<LawyerMainHomeScreen> createState() => _LawyerMainHomeScreenState();
}

class _LawyerMainHomeScreenState extends State<LawyerMainHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    LawyerHomeScreen(),
    // LawyerChatScreen(),
    // LawyerRightsScreen(),
    // LawyerToolsScreen(),
    LawyerProfileScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          // BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          // BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Rights'),
          // BottomNavigationBarItem(icon: Icon(Icons.build_outlined), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}