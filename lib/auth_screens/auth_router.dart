// lib/auth_screens/auth_router.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nyaya_marg/screens/client_screen/main_home_screen.dart';
import 'package:nyaya_marg/screens/lawyer_screens/lawyer_main_home_screen.dart';

Future<Widget> getHomeAfterAuth() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const MainHomeScreen(); // fallback

  final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final role = doc.data()?['role'] as String?;

  if (role == 'client') {
    return const MainHomeScreen();
  } else if (role == 'lawyer') {
    return const LawyerMainHomeScreen();
  } else {
    return const MainHomeScreen(); // fallback
  }
}