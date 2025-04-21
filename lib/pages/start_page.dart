import 'package:coin_clicker/widgets/effects/sunburst_painter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:google_fonts/google_fonts.dart';
import 'package:coin_clicker/pages/main_game_page.dart';
import 'package:coin_clicker/widgets/common/image_button.dart';
import 'package:coin_clicker/widgets/common/animated_logo.dart';
import 'package:coin_clicker/widgets/common/text_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _buttonScale;
  
  // 배경 애니메이션을 위한 컨트롤러
  late final AnimationController _backgroundController;
  final double _parallaxFactor = 0.1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 로고 페이드인 애니메이션 (0-1초)
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // 버튼 스케일 애니메이션 (0.5-1.5초)
    _buttonScale = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.75, curve: Curves.elasticOut),
      ),
    );

    // 애니메이션 시작
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  void _handleStartGame() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const MainGamePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/bg_main.png'),
            fit: BoxFit.cover,
            alignment: Alignment(
              math.sin(_backgroundController.value * 2 * math.pi) * _parallaxFactor,
              math.cos(_backgroundController.value * 2 * math.pi) * _parallaxFactor,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Game Logo (Top Center)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: const AnimatedLogo(
                    imagePath: 'assets/images/logo.png',
                    width: 240,
                  ),
                ),
              ),
              
              // Settings Button (Top Right)
              Positioned(
                top: 16,
                right: 16,
                child: ImageButton(
                  imagePath: 'assets/images/icon_setting.svg',
                  size: 60,
                  onPressed: () {
                    // TODO: Navigate to SettingsPage
                  },
                ),
              ),
              
              // Ranking Button (Bottom Right)
              Positioned(
                bottom: 18,
                right: 16,
                child: ImageButton(
                  imagePath: 'assets/images/icon_ranking.svg',
                  size: 60,
                  onPressed: () {
                    // TODO: Navigate to RankingPage
                  },
                ),
              ),
              
              // Center Button and Text (Center)
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 500),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 60),
                      RotatingSunburst(
                        size: 350,
                        child: ScaleTransition(
                          scale: _buttonScale,
                          child: ImageButton(
                            imagePath: 'assets/images/coin_level6.png',
                            size: 300,
                            onPressed: () {},
                          ),
                        ),
                      ),
                      AnimatedTextButton(
                        text: 'TAP TO START',
                        textColor: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: 48,
                        onPressed: _handleStartGame,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 