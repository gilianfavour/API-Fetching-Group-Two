import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        centerTitle: true,
        title: Text("Checkout", style: theme.textTheme.headlineMedium),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= CART ITEMS =================
            Text("Cart Summary", style: theme.textTheme.titleMedium),

            const SizedBox(height: 20),

            _cartItem(context, "Glow Serum", "UGX 80,000"),

            _cartItem(context, "Hydrating Face Cream", "UGX 60,000"),

            _cartItem(context, "Sunscreen SPF 50", "UGX 50,000"),

            const SizedBox(height: 30),

            // ================= SHIPPING =================
            Text("Shipping Details", style: theme.textTheme.titleMedium),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                hintText: "Enter delivery address",
                hintStyle: theme.textTheme.bodyMedium,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              decoration: InputDecoration(
                hintText: "Phone Number",
                hintStyle: theme.textTheme.bodyMedium,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            // ================= TOTAL =================
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total", style: theme.textTheme.titleMedium),
                  Text("UGX 190,000", style: theme.textTheme.bodyLarge),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ================= PAYMENT BUTTON =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  "Proceed to Payment",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cartItem(BuildContext context, String title, String price) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE0F2FE),
          child: Icon(Icons.spa),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        trailing: Text(price, style: theme.textTheme.bodyLarge),
      ),
    );
  }
}
