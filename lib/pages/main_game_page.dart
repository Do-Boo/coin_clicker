import 'package:coin_clicker/widgets/common/stroke_text.dart';
import 'package:coin_clicker/widgets/effects/sunburst_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game/clickable_coin.dart';
import '../widgets/common/game_scaffold.dart';
import '../widgets/common/image_button.dart';

class MainGamePage extends StatelessWidget {
  const MainGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GameScaffold(
      backgroundImage: 'assets/images/bg_level1.png',
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 100),
              Expanded(
                child: Center(
                  child: RotatingSunburst(
                    size: 600,
                    child: ClickableCoin(
                      imagePath: 'assets/images/coin_main.png',
                      size: 300,
                      onTap: (amount) {
                        final gameProvider = context.read<GameProvider>();
                        gameProvider.clickCoin();
                      },
                    ),
                  ),
                ),
              ),
              Container(
                width: 200,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(100, 24),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          // Left top button
          Positioned(
            top: 16,
            left: 16,
            child: ImageButton(
              imagePath: 'assets/images/icon_daily.png',
              size: 56,
              onPressed: () {},
              title: 'DAILY\nMISSIONS',
              effect: ButtonEffect.slime,
            ),
          ),
          // Right top buttons
          Positioned(
            top: 16,
            right: 8,
            child: Column(
              children: [
                ImageButton(
                  imagePath: 'assets/images/icon_ranking.png',
                  size: 64,
                  onPressed: () {},
                  title: 'RANKING',
                  effect: ButtonEffect.slime,
                ),
                const SizedBox(height: 8),
                ImageButton(
                  imagePath: 'assets/images/icon_boost.png',
                  size: 64,
                  onPressed: () {},
                  title: 'BOOST',
                  effect: ButtonEffect.slime,
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    width: 56,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00477d),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                    child: const Center(
                      child: StrokeText(
                        text: '01:00',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textColor: Colors.white,
                        strokeColor: Colors.black,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ImageButton(
                  imagePath: 'assets/images/icon_gift.png',
                  size: 64,
                  onPressed: () {},
                  title: 'GIFT',
                  effect: ButtonEffect.slime,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
