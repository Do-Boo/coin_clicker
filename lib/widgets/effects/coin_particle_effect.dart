import 'dart:math';
import 'package:flutter/material.dart';

class CoinParticleEffect extends StatefulWidget {
  final Offset position;
  final double amount;
  final String imagePath;
  final bool isText;

  const CoinParticleEffect({
    super.key,
    required this.position,
    required this.amount,
    required this.imagePath,
    this.isText = false,
  });

  @override
  State<CoinParticleEffect> createState() => _CoinParticleEffectState();
}

class _CoinParticle {
  final double angle;
  final double velocity;
  final double rotationSpeed;

  _CoinParticle({
    required this.angle,
    required this.velocity,
    required this.rotationSpeed,
  });
}

class _CoinParticleEffectState extends State<CoinParticleEffect> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_CoinParticle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    if (!widget.isText) {
      // 8-12개의 랜덤한 파티클 생성
      final particleCount = _random.nextInt(5) + 8;
      _particles = List.generate(particleCount, (index) {
        final angle = _random.nextDouble() * 2 * pi;
        final velocity = _random.nextDouble() * 100 + 100;
        final rotationSpeed = _random.nextDouble() * 10 - 5;
        
        return _CoinParticle(
          angle: angle,
          velocity: velocity,
          rotationSpeed: rotationSpeed,
        );
      });
    } else {
      _particles = [];
    }

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
    if (widget.isText) {
      // 코인 획득량 텍스트 표시
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final opacity = 1.0 - progress;
          final offset = Offset(0, -50 * progress); // 위로 올라가는 효과

          return Positioned(
            left: widget.position.dx,
            top: widget.position.dy,
            child: Transform.translate(
              offset: offset,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  '+${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    // 코인 파티클 효과
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _particles.map((particle) {
            final progress = _controller.value;
            final distance = particle.velocity * progress;
            final gravity = 500.0;
            final dx = distance * cos(particle.angle);
            final dy = distance * sin(particle.angle) + (0.5 * gravity * progress * progress);
            
            final scale = (1 - progress) * 0.5 + 0.2;
            final opacity = 1 - progress;
            
            final particleSize = 30 * scale;
            
            return Positioned(
              left: widget.position.dx - (particleSize / 2) + dx,
              top: widget.position.dy - (particleSize / 2) + dy,
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
          }).toList(),
        );
      },
    );
  }
} 