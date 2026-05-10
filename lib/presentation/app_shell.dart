import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smart_money/core/theme/app_colors.dart';
import 'package:smart_money/presentation/screens/add_transaction/add_transaction_screen.dart';
import 'package:smart_money/presentation/screens/home/home_screen.dart';
import 'package:smart_money/presentation/screens/profile/profile_screen.dart';
import 'package:smart_money/presentation/screens/report/report_screen.dart';
import 'package:smart_money/presentation/screens/wishlist/wishlist_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    ReportScreen(),
    WishlistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Needed for glass effect
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + MediaQuery.of(context).padding.bottom),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.insert_chart_rounded, 'Report'),
                _buildAddButton(),
                _buildNavItem(2, Icons.stars_rounded, 'Goals'),
                _buildNavItem(3, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AddTransactionScreen(),
            fullscreenDialog: true,
          ),
        );
      },
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary, // Green color
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: isActive
                    ? AppColors.primary
                    : AppColors.outline.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : AppColors.outline.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
