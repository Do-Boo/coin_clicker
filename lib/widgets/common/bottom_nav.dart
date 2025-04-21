import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'custom_button.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA500),
        border: Border(
          top: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(
              'assets/images/icon_settings.svg',
              () => print('Settings'),
            ),
            _buildNavButton(
              'assets/images/icon_home.svg',
              () => print('Home'),
            ),
            _buildNavButton(
              'assets/images/icon_stats.svg',
              () => print('Stats'),
            ),
            _buildNavButton(
              'assets/images/icon_shop.svg',
              () => print('Shop'),
            ),
            _buildNavButton(
              'assets/images/icon_gift.svg',
              () => print('Gift'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton(String icon, VoidCallback onPressed) {
    return CustomButton(
      width: 56,
      height: 56,
      onPressed: onPressed,
      child: SvgPicture.asset(
        icon,
        width: 32,
        height: 32,
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
      ),
    );
  }
} 