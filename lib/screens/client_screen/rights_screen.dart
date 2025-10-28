import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RightsScreen extends StatelessWidget {
  const RightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Know Your Rights',
        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
      ),
    );
  }
}
