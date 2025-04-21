import 'dart:math';
import 'package:flutter/material.dart';

class MoneyRainEffect extends StatefulWidget {
  final int numberOfBills;
  final double billSize;
  
  const MoneyRainEffect({
    super.key,
    this.numberOfBills = 20,
    this.billSize = 40,
  });

  @override
  State<MoneyRainEffect> createState() => _MoneyRainEffectState();
}

class _MoneyRainEffectState extends State<MoneyRainEffect> with TickerProviderStateMixin {
  final List<MoneyBill> _bills = [];
  final Random _random = Random();
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initializeBills();
      _initialized = true;
    }
  }

  void _initializeBills() {
    // Clear existing bills and their controllers
    for (var bill in _bills) {
      bill.controller.dispose();
    }
    _bills.clear();

    final size = MediaQuery.of(context).size;
    
    for (int i = 0; i < widget.numberOfBills; i++) {
      final position = Offset(
        _random.nextDouble() * (size.width + 100) - 50,
        -widget.billSize - _random.nextDouble() * size.height,
      );
      
      _bills.add(MoneyBill(
        position: position,
        speed: _random.nextDouble() * 100 + 50, // Speed between 50-150
        size: widget.billSize,
        rotation: _random.nextDouble() * 360,
        controller: AnimationController(
          vsync: this,
          duration: Duration(seconds: _random.nextInt(5) + 8), // Duration between 8-12 seconds
        ),
      ));
    }

    // Start animations
    for (var bill in _bills) {
      bill.controller.repeat();
    }
  }

  @override
  void dispose() {
    for (var bill in _bills) {
      bill.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Stack(
      children: _bills.map((bill) {
        return AnimatedBuilder(
          animation: bill.controller,
          builder: (context, child) {
            final progress = bill.controller.value;
            final yPosition = bill.position.dy +
                progress * (size.height + widget.billSize * 2);

            return Positioned(
              left: bill.position.dx,
              top: yPosition,
              child: Transform.rotate(
                angle: (bill.rotation + progress * 2) * pi / 180,
                child: Opacity(
                  opacity: 0.3, // Make bills semi-transparent
                  child: Image.asset(
                    'assets/images/icon_bill.png',
                    width: bill.size,
                    height: bill.size,
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class MoneyBill {
  final Offset position;
  final double speed;
  final double size;
  final double rotation;
  final AnimationController controller;

  MoneyBill({
    required this.position,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.controller,
  });
} 