import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      debugPrint("Onboarding Completed");
    }
  }

  void skip() {
    _controller.jumpToPage(2);

    setState(() {
      currentIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

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

                desc: "Keep your skin nourished and hydrated every day.",
              ),

              OnboardPage(
                imageUrl:
                    "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80",

                title: "Glow Naturally",

                desc: "Achieve radiant and smooth skin with Golden Glow.",
              ),
            ],
          ),

          // ================= SKIP BUTTON =================
          Positioned(
            top: 55,
            right: 20,

            child: TextButton(
              onPressed: skip,

              child: Text(
                "Skip",

                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),

          // ================= PAGE INDICATORS =================
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

                  margin: const EdgeInsets.symmetric(horizontal: 4),

                  height: 8,

                  width: currentIndex == index ? 24 : 8,

                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? theme.colorScheme.primary
                        : Colors.grey.shade400,

                    borderRadius: BorderRadius.circular(12),
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
                backgroundColor: theme.colorScheme.primary,

                padding: const EdgeInsets.symmetric(vertical: 18),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

              onPressed: nextPage,

              child: Text(
                currentIndex == 2 ? "Finish" : "Next",

                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
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
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          // ================= IMAGE =================
          ClipRRect(
            borderRadius: BorderRadius.circular(24),

            child: Image.network(
              imageUrl,

              height: 320,
              width: double.infinity,

              fit: BoxFit.cover,

              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const SizedBox(
                  height: 320,

                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),

          const SizedBox(height: 40),

          // ================= TITLE =================
          Text(
            title,

            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onBackground,
            ),
          ),

          const SizedBox(height: 16),

          // ================= DESCRIPTION =================
          Text(
            desc,

            textAlign: TextAlign.center,

            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.6,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
