import 'package:flutter/material.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.orange,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111111), Color(0xFF1F1F1F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Your Skincare Cart 🧴",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            _cartItem(
              "Glow Serum",
              "Intense skin radiance treatment",
              "UGX 80,000",
              "https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&w=150&q=80",
            ),
            _cartItem(
              "Hydrating Face Cream",
              "Deep moisture for soft skin",
              "UGX 60,000",
              "https://images.unsplash.com/photo-1556228578-8c89e6adf883?auto=format&fit=crop&w=150&q=80",
            ),
            _cartItem(
              "Sunscreen SPF 50",
              "Daily UV protection",
              "UGX 50,000",
              "https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=150&q=80",
            ),

            const Spacer(),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange, width: 0.8),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: TextStyle(fontSize: 18)),
                  Text(
                    "UGX 190,000",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () {},
                child: const Text("Proceed to Payment"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartItem(String title, String desc, String price, String imageUrl) {
    return Card(
      color: const Color(0xFF1F1F1F),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.orange),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(desc, style: const TextStyle(color: Colors.white70)),
        trailing: Text(
          price,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
