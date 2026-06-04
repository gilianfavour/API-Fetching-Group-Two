import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF000435)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: const Color(0xFF000435),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSectionHeader("App Preferences"),
          _buildCard([
            SwitchListTile(
              title: Text("Dark Mode", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text("Use dark colors in UI", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              value: _darkMode,
              activeColor: const Color(0xFF000435),
              onChanged: (val) {
                setState(() => _darkMode = val);
                showTopNotification(
                  context,
                  val ? "Dark Mode enabled (Mock)" : "Light Mode enabled (Mock)",
                  isSuccess: true,
                );
              },
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            SwitchListTile(
              title: Text("Push Notifications", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              subtitle: Text("Get order & promo notifications", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              value: _notificationsEnabled,
              activeColor: const Color(0xFF000435),
              onChanged: (val) {
                setState(() => _notificationsEnabled = val);
                showTopNotification(
                  context,
                  val ? "Notifications enabled" : "Notifications disabled",
                  isSuccess: val,
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader("System"),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.language_rounded, color: Color(0xFF000435), size: 20),
              title: Text("Language", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: Text("English", style: GoogleFonts.inter(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w600)),
              onTap: () {
                showTopNotification(context, "NutriBlend currently only supports English.", isSuccess: true);
              },
            ),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            ListTile(
              leading: const Icon(Icons.delete_sweep_outlined, color: Color(0xFF000435), size: 20),
              title: Text("Clear Cache", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                showTopNotification(context, "App cache cleared successfully!", isSuccess: true);
              },
            ),
          ]),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Text(
                  "NutriBlend",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF000435),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 2.0.3 (Stable)",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF64748B),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}
