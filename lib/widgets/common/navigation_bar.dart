import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000435),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000435).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(
            _navItems.length,
            (i) => Expanded(
              child: _NavItem(
                icon: _navItems[i].icon,
                activeIcon: _navItems[i].activeIcon,
                label: _navItems[i].label,
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItemData(this.icon, this.activeIcon, this.label);
}

const _navItems = [
  _NavItemData(Icons.home_outlined, Icons.home_rounded, 'Home'),
  _NavItemData(Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Products'),
  _NavItemData(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                size: 20,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}