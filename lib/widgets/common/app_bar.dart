import 'package:flutter/material.dart';

class CustomTopBar extends StatelessWidget {
  final VoidCallback? onAccountTap;
  final VoidCallback? onCartTap;
  final Function(String)? onSearchSubmitted;

  const CustomTopBar({
    super.key,
    this.onAccountTap,
    this.onCartTap,
    this.onSearchSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo Icon on the left
              Icon(
                Icons.star,
                color: Colors.amber[700],
                size: 32,
              ),
              const SizedBox(width: 12),
              
              // Search Bar (expanded)
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    onSubmitted: onSearchSubmitted,
                    decoration: InputDecoration(
                      hintText: 'Search products, brands and categories',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      suffixIcon: Icon(Icons.mic, color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              
              // Account Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: InkWell(
                  onTap: onAccountTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Icon(Icons.account_circle_outlined, color: Colors.grey[700], size: 28),
                ),
              ),
              
              // Cart Icon
              InkWell(
                onTap: onCartTap,
                borderRadius: BorderRadius.circular(8),
                child: Icon(Icons.shopping_cart_outlined, color: Colors.grey[700], size: 28),
              ),
            ],
          ),
        ),
      ),
    );
  }
}