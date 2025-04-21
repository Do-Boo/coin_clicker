import 'package:coin_clicker/widgets/effects/sunburst_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/game/clickable_coin.dart';
import '../widgets/common/game_scaffold.dart';
import '../widgets/common/booster_status.dart';

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
              Expanded(
                child: Center(
                  child: RotatingSunburst(
                    size: 600,
                    child: ClickableCoin(
                      imagePath: 'assets/images/coin_level1.png',
                      size: 400,
                      onTap: (amount) {
                        final gameProvider = context.read<GameProvider>();
                        gameProvider.clickCoin();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: BoosterStatus(),
          ),
        ],
      ),
    );
  }
} 