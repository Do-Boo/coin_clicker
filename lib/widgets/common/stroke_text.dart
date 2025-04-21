import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color textColor;
  final Color strokeColor;
  final double strokeWidth;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final List<Shadow>? shadows;
  final TextAlign? textAlign;

  const StrokeText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.textColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3,
    this.fontFamily,
    this.fontWeight,
    this.shadows,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stroke layers
        for (double i = 0; i < 360; i += 45)
          Transform.translate(
            offset: Offset(
              strokeWidth * 0.5 * cos(i * 3.14159 / 180),
              strokeWidth * 0.5 * sin(i * 3.14159 / 180),
            ),
            child: Text(
              text,
              textAlign: textAlign,
              style: _getTextStyle(strokeColor),
            ),
          ),
        // Main text
        Text(
          text,
          textAlign: textAlign,
          style: _getTextStyle(textColor, shadows: shadows),
        ),
      ],
    );
  }

  TextStyle _getTextStyle(Color color, {List<Shadow>? shadows}) {
    TextStyle style;
    
    if (fontFamily != null) {
      style = TextStyle(
        fontSize: fontSize,
        color: color,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
        shadows: shadows,
      );
    } else {
      style = GoogleFonts.fredoka(
        fontSize: fontSize,
        color: color,
        fontWeight: fontWeight,
        shadows: shadows,
      );
    }
    
    return style;
  }
} 