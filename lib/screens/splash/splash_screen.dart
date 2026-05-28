import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return; // 👈 prevents crash

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const OnboardingScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ================= LOGO =================
            Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF000435),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(Icons.spa, color: Colors.white, size: 60),
            ),

            const SizedBox(height: 30),

            // ================= APP NAME =================
            Text(
              "Golden Glow",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Skincare & Beauty",
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 40),

            // ================= LOADING =================
            const CircularProgressIndicator(color: Color(0xFF0EA5E9)),
          ],
        ),
      ),
    );
  }
}
