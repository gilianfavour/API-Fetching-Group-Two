import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/common/navigation_bar.dart';
import 'home/home_screen.dart';
import 'products/products_screen.dart';
import 'wishlist/wishlist_screen.dart';
import '../profile/profile.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> screens = [
      const HomePage(),
      const ProductPage(),
      const WishlistScreen(showBackButton: false),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: navProvider.currentIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: navProvider.currentIndex,
        onTap: (index) {
          navProvider.setIndex(index);
        },
      ),
    );
  }
}
