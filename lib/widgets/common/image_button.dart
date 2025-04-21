import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageButton extends StatefulWidget {
  final String imagePath;
  final double size;
  final VoidCallback? onPressed;
  final Color? color;

  const ImageButton({
    super.key,
    required this.imagePath,
    required this.size,
    this.onPressed,
    this.color,
  });

  @override
  State<ImageButton> createState() => _ImageButtonState();
}

class _ImageButtonState extends State<ImageButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _scale;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
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
    if (!_isPressed) {
      _isPressed = true;
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _isPressed = false;
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    _isPressed = false;
    _controller.reverse();
  }

  Widget _buildImage() {
    final isIcon = widget.imagePath.toLowerCase().endsWith('.svg');
    return Container(
      width: widget.size,
      height: widget.size,
      padding: isIcon ? EdgeInsets.all(widget.size * 0.2) : EdgeInsets.zero,
      child: isIcon
          ? SvgPicture.asset(
              widget.imagePath,
              colorFilter: ColorFilter.mode(
                widget.color ?? Colors.white,
                BlendMode.srcIn,
              ),
            )
          : Image.asset(
              widget.imagePath,
              width: widget.size,
              height: widget.size,
              color: widget.color,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scale ?? AlwaysStoppedAnimation(1.0),
        child: _buildImage(),
      ),
    );
  }
} 