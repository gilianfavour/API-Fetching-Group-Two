import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../main_navigation_screen.dart';
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

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final Widget nextScreen = authProvider.isLoggedIn ? const MainNavigationScreen() : const OnboardingScreen();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => nextScreen,
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
              "NutriBlend",
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "Health & Wellness",
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xFF64748B),
              ),
            ),

            const SizedBox(height: 40),

            // ================= LOADING =================
            const CircularProgressIndicator(color: Color(0xFF000435)),
          ],
        ),
      ),
    );
  }
}
