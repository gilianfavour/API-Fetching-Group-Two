import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nutriblend_group2/screens/home/home_screen.dart';

// ===================== GOLDEN GLOW ONBOARDING =====================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextPage() {
  if (currentIndex < 2) {
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }
}

void skip() {
  nextPage(); // reuse same logic
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // ================= PAGE VIEW =================
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            children: const [
              OnboardPage(
                imageUrl:
                    "https://images.unsplash.com/photo-1620916566398-39f1143ab7be?auto=format&fit=crop&w=800&q=80",
                title: "Healthy Skin Starts Here",
                desc:
                    "Discover skincare products designed to enhance your natural glow.",
              ),

              OnboardPage(
                imageUrl:
                    "https://images.unsplash.com/photo-1556228578-8c89e6adf883?auto=format&fit=crop&w=800&q=80",
                title: "Hydrate & Refresh",
                desc: "Keep your skin nourished and hydrated every single day.",
              ),

              OnboardPage(
                imageUrl:
                    "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80",
                title: "Glow Naturally",
                desc:
                    "Achieve radiant, smooth and glowing skin with Golden Glow.",
              ),
            ],
          ),

          // ================= SKIP BUTTON =================
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF000435),
              ),
              onPressed: skip,
              child: Text(
                "Skip",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF000435),
                ),
              ),
            ),
          ),

          // ================= DOT INDICATORS =================
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: currentIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? const Color(0xFF000435)
                        : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          // ================= NEXT BUTTON =================
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000435),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: nextPage,
              child: Text(currentIndex == 2 ? "Finish" : "Next"),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== ONBOARD PAGE =====================

class OnboardPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String desc;

  const OnboardPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      color: const Color(0xFFF8FAFC),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ================= IMAGE =================
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              imageUrl,
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,

              // LOADING EFFECT
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF000435)),
                  ),
                );
              },

              // ERROR HANDLING
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 60,
                      color: Color(0xFF64748B),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 35),

          // ================= TITLE =================
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 15),

          // ================= DESCRIPTION =================
          Text(
            desc,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
