import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:coin_clicker/providers/game_provider.dart';
import 'package:coin_clicker/widgets/common/stroke_text.dart';
import 'package:coin_clicker/widgets/common/custom_button.dart';
import 'package:coin_clicker/widgets/common/image_button.dart';

class BoosterStatus extends StatelessWidget {
  const BoosterStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        return Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 2,
                      top: 2,
                      child: CustomButton(
                        width: 64,
                        height: 64,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        borderColor: Colors.white.withOpacity(0.1),
                        onPressed: () {
                          // TODO: Handle click booster activation
                        },
                        child: _buildBoosterContent(
                          'assets/images/icon_touch_app.svg',
                          'Click',
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: _buildMultiplierBadge('x2'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: 2,
                      top: 2,
                      child: CustomButton(
                        width: 64,
                        height: 64,
                        backgroundColor: Colors.black.withOpacity(0.2),
                        borderColor: Colors.white.withOpacity(0.1),
                        onPressed: () {
                          // TODO: Handle auto booster activation
                        },
                        child: _buildBoosterContent(
                          'assets/images/icon_fire.svg',
                          'Auto',
                        ),
                      ),
                    ),
                    Positioned(
                      top: -4,
                      right: -4,
                      child: _buildMultiplierBadge('x3'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoosterContent(String imagePath, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          imagePath,
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildMultiplierBadge(String multiplier) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          multiplier,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
} 