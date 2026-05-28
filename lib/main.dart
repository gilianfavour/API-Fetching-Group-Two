import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';

import 'screens/home/home_screen.dart';
import 'screens/products/products_screen.dart'; 



void main() {

  runApp(

    MultiProvider(

      providers: [

        ChangeNotifierProvider(

          create: (_) => ProductProvider(),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce App',
      debugShowCheckedModeBanner: false,
      
      // --- CRITICAL DESIGN SYSTEM CONFIGURATION ---
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Light Background
        
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2596BE),        // Brand Ocean Blue
          secondary: Color(0xFF0EA5E9),     // Light Neutral
          surface: Color(0xFFFFFFFF),   // Dark Neutral Text
          onSurface: Color(0xFF1E293B),      // Dark Neutral Text on Cards
        ),

        // Global Typography Configurations
        textTheme: TextTheme(
          // For AppBars and Major Screen Headers
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E293B),
          ),
          // For Product Titles / Section Titles
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E293B),
          ),
          // For Highlights (e.g., Prices)
          titleSmall: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF2596BE),
          ),
          // For Body Paragraphs/Descriptions
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B), // Medium Neutral
          ),
        ),

        // Button Style Overrides
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2596BE),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      // --------------------------------------------
      
      home: const Scaffold(
          body: HomePage(),
        ),
      home: const ProductPage(), 
    );
  }
}