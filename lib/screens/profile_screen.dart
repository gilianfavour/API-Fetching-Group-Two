import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Color(0xFF141414)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, size: 60, color: Colors.black),
              ),

              const SizedBox(height: 10),

              const Text(
                "Golden Glow User",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Skincare Lover ✨",
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 30),

              _profileCard(Icons.email, "user@goldenglow.com"),
              _profileCard(Icons.phone, "+256 700 000 000"),
              _profileCard(Icons.location_on, "Kampala, Uganda"),
              _profileCard(Icons.favorite, "Skin Type: Normal / Dry Combo"),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: () {},
                    child: const Text("Edit Profile"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard(IconData icon, String text) {
    return Card(
      color: const Color(0xFF1F1F1F),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
