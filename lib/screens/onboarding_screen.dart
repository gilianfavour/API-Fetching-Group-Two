import 'package:flutter/material.dart';

// ===================== GOLDEN GLOW ONBOARDING =====================
// STANDALONE MODULE (NO EXTERNAL NAVIGATION)

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
      debugPrint("Onboarding complete");
    }
  }

  void skip() {
    _controller.jumpToPage(2);
    setState(() => currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            children: const [
              OnboardPage(
                imageUrl:
                    "https://unsplash.com/photos/white-and-black-plastic-bottles-_42NKYROG7g?auto=format&fit=crop&w=800&q=80",
                title: "Healthy Skin Starts Here",
                desc:
                    "Discover skincare products designed to enhance your natural glow.",
              ),
              OnboardPage(
                imageUrl:
                    "https://unsplash.com/photos/white-and-orange-plastic-bottle-7tDGb3HrITg?auto=format&fit=crop&w=800&q=80",
                title: "Hydrate & Refresh",
                desc: "Keep your skin nourished and hydrated every day.",
              ),
              OnboardPage(
                imageUrl:
                    "https://unsplash.com/photos/an-assortment-of-makeup-products-on-a-pink-background-sCFL6R7loQk?auto=format&fit=crop&w=800&q=80",
                title: "Glow Naturally",
                desc:
                    "Achieve radiant, smooth and glowing skin with Golden Glow.",
              ),
            ],
          ),

          // SKIP BUTTON
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.orange),
              onPressed: skip,
              child: const Text("Skip", style: TextStyle(fontSize: 16)),
            ),
          ),

          // NEXT BUTTON
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 18),
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF1F1F1F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),

          const SizedBox(height: 30),

          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            desc,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
