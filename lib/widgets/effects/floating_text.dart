import 'package:flutter/material.dart';

class FloatingText {
  static void show({
    required BuildContext context,
    required String text,
    required TextStyle style,
  }) {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + renderBox.size.width / 2 - 50,
        top: position.dy + renderBox.size.height / 2 - 50,
        child: _FloatingTextWidget(
          text: text,
          style: style,
          onComplete: () {
            entry.remove();
          },
        ),
      ),
    );
    
    overlay.insert(entry);
  }
}

class _FloatingTextWidget extends StatefulWidget {
  final String text;
  final TextStyle style;
  final VoidCallback onComplete;

  const _FloatingTextWidget({
    required this.text,
    required this.style,
    required this.onComplete,
  });

  @override
  State<_FloatingTextWidget> createState() => _FloatingTextWidgetState();
}

class _FloatingTextWidgetState extends State<_FloatingTextWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 20.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 20.0,
      ),
    ]).animate(_controller);

    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -2.0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.5, end: 1.2),
        weight: 30.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 70.0,
      ),
    ]).animate(_controller);

    _controller.forward().whenComplete(() {
      widget.onComplete();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _position.value.dy * 100),
            child: Transform.scale(
              scale: _scale.value,
              child: SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: Text(
                    widget.text,
                    style: widget.style,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 