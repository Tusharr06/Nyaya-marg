import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Legal Tools & Utilities',
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}
