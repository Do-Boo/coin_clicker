import 'package:flutter/material.dart';
import 'package:coin_clicker/widgets/common/top_bar copy.dart';
import 'package:coin_clicker/widgets/common/bottom_bar.dart';

class GameScaffold extends StatelessWidget {
  final Widget child;
  final String backgroundImage;
  final bool showTopBar;
  final bool showBottomBar;
  final Color? backgroundColor;

  const GameScaffold({
    super.key,
    required this.child,
    this.backgroundImage = 'assets/images/bg_main.png',
    this.showTopBar = true,
    this.showBottomBar = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          image: backgroundImage.isNotEmpty ? DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ) : null,
        ),
        child: Column(
          children: [
            if (showTopBar) const TopBar(),
            Expanded(child: child),
            if (showBottomBar) const BottomBar(),
          ],
        ),
      ),
    );
  }
} 