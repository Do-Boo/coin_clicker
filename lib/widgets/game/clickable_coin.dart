import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:coin_clicker/providers/game_provider.dart';
import 'package:coin_clicker/widgets/common/stroke_text.dart';
import 'package:coin_clicker/utils/number_formatter.dart';

class ClickableCoin extends StatefulWidget {
  final String imagePath;
  final double size;
  final Function(double amount)? onTap;

  const ClickableCoin({
    super.key,
    required this.imagePath,
    this.size = 200,
    this.onTap,
  });

  @override
  State<ClickableCoin> createState() => _ClickableCoinState();
}

class _ClickableCoinState extends State<ClickableCoin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final List<_ParticleInfo> _particles = [];
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _isPressed = true;
    _controller.forward(from: 0.0);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse(from: 1.0);
    final gameProvider = context.read<GameProvider>();
    final earnedAmount = gameProvider.playerData.effectiveClickPower;
    
    if (widget.onTap != null) {
      widget.onTap!(earnedAmount);
    }

    if (earnedAmount > gameProvider.playerData.clickPower) {
      HapticFeedback.heavyImpact();
    }

    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    setState(() {
      _particles.add(_ParticleInfo(
        position: localPosition,
        amount: earnedAmount,
        imagePath: widget.imagePath,
      ));
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _particles.removeWhere((particle) =>
              particle.createdAt.difference(DateTime.now()).inMilliseconds.abs() >= 1000);
        });
      }
    });
  }

  void _handleTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          // 메인 코인 레이어
          GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Image.asset(
                widget.imagePath,
                width: widget.size,
                height: widget.size,
              ),
            ),
          ),
          // 파티클 효과 레이어 (터치 이벤트 무시)
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                clipBehavior: Clip.none,
                children: _particles.map((particle) {
                  return _CoinParticleEffect(
                    key: ValueKey(particle.createdAt),
                    position: particle.position,
                    amount: particle.amount,
                    imagePath: particle.imagePath,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticleInfo {
  final Offset position;
  final double amount;
  final String imagePath;
  final DateTime createdAt;

  _ParticleInfo({
    required this.position,
    required this.amount,
    required this.imagePath,
  }) : createdAt = DateTime.now();
}

class _Particle {
  final double angle;
  final double velocity;
  final double rotationSpeed;

  _Particle({
    required this.angle,
    required this.velocity,
    required this.rotationSpeed,
  });
}

class _CoinParticleEffect extends StatefulWidget {
  final Offset position;
  final double amount;
  final String imagePath;

  const _CoinParticleEffect({
    super.key,
    required this.position,
    required this.amount,
    required this.imagePath,
  });

  @override
  State<_CoinParticleEffect> createState() => _CoinParticleEffectState();
}

class _CoinParticleEffectState extends State<_CoinParticleEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    final particleCount = _random.nextInt(5) + 8;
    _particles = List.generate(particleCount, (index) {
      final angle = _random.nextDouble() * 2 * pi;
      final velocity = _random.nextDouble() * 100 + 100;
      final rotationSpeed = _random.nextDouble() * 10 - 5;
      
      return _Particle(
        angle: angle,
        velocity: velocity,
        rotationSpeed: rotationSpeed,
      );
    });

    _controller.forward().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final progress = _controller.value;
            final opacity = 1.0 - progress;
            final offset = Offset(0, -50 * progress);

            return Positioned(
              left: widget.position.dx - 20,
              top: widget.position.dy + offset.dy - 40,
              child: Opacity(
                opacity: opacity,
                child: StrokeText(
                  text: '+${formatNumber(widget.amount)}',
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  textColor: const Color(0xFFFEF9E7),
                  strokeColor: const Color(0xFF5D4037),
                  strokeWidth: 6,
                  shadows: const [
                    Shadow(
                      color: Colors.black54,
                      offset: Offset(4, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ..._particles.map((particle) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              final distance = particle.velocity * progress;
              const gravity = 500.0;
              final dx = distance * cos(particle.angle);
              final dy = distance * sin(particle.angle) + (0.5 * gravity * progress * progress);
              
              final scale = (1 - progress) * 0.5 + 0.2;
              final opacity = 1 - progress;
              
              final particleSize = 30 * scale;
              
              return Positioned(
                left: widget.position.dx + dx,
                top: widget.position.dy + dy,
                child: Transform.rotate(
                  angle: particle.rotationSpeed * progress * 2 * pi,
                  child: Opacity(
                    opacity: opacity,
                    child: Image.asset(
                      widget.imagePath,
                      width: particleSize,
                      height: particleSize,
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }
} 