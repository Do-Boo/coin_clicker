import 'package:flutter/material.dart';

class CoinDisplay extends StatelessWidget {
  final double coins;
  final double coinsPerSecond;

  const CoinDisplay({
    super.key,
    required this.coins,
    required this.coinsPerSecond,
  });

  String formatNumber(double number) {
    if (number >= 1e12) return '${(number / 1e12).toStringAsFixed(1)}T';
    if (number >= 1e9) return '${(number / 1e9).toStringAsFixed(1)}B';
    if (number >= 1e6) return '${(number / 1e6).toStringAsFixed(1)}M';
    if (number >= 1e3) return '${(number / 1e3).toStringAsFixed(1)}K';
    return number.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${formatNumber(coins)} 코인',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '초당 ${formatNumber(coinsPerSecond)} 코인',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 