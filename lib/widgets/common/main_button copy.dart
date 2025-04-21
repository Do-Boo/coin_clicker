import 'package:flutter/material.dart';
import 'package:ninepatch_image/ninepatch_image.dart';

class NativeButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double? width;
  final double? height;

  const NativeButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = 200,
    this.height = 200,
  });

  @override
  State<NativeButton> createState() => _NativeButtonState();
}

class _NativeButtonState extends State<NativeButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: NinePatchImage(
                imageProvider: AssetImage('assets/images/IconButton_Large_Blue_Rounded.9.png'),
                child: Center(child: SizedBox()),
              ),
            ),
          );
        },
      ),
    );
  }
}