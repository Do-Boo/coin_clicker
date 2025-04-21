import 'package:coin_clicker/widgets/common/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coin_clicker/providers/game_provider.dart';
import 'package:coin_clicker/utils/number_formatter.dart';
import 'package:coin_clicker/widgets/common/stroke_text.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        bottom: false,
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomButton(
                  width: 48,
                  height: 48,
                  onPressed: () {},
                  backgroundColor: Colors.black.withOpacity(0.2),
                  borderColor: Colors.white.withOpacity(0.1),
                  child: SvgPicture.asset(
                    'assets/images/icon_menu.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/coin_main.png',
                            width: 32,
                            height: 32,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StrokeText(
                              text: formatNumber(gameProvider.playerData.coins),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              textColor: Colors.white,
                              strokeColor: const Color(0xFF8B6B23),
                              strokeWidth: 3,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.trending_up,
                            color: Color(0xFFFFD700),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: StrokeText(
                              text: formatNumber(gameProvider.playerData.coinsPerSecond),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              textColor: Colors.white,
                              strokeColor: const Color(0xFF8B6B23),
                              strokeWidth: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CustomButton(
                  width: 48,
                  height: 48,
                  onPressed: () {},
                  backgroundColor: Colors.black.withOpacity(0.2),
                  borderColor: Colors.white.withOpacity(0.1),
                  child: SvgPicture.asset(
                    'assets/images/icon_setting.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 