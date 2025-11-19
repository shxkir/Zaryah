import 'package:flutter/material.dart';
import '../theme/neon_palette.dart';

class ZaryahWordmark extends StatelessWidget {
  const ZaryahWordmark({
    super.key,
    this.fontSize = 48,
    this.textAlign = TextAlign.center,
  });

  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final baseStyle = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: 4,
      color: NeonColors.text,
    );

    return ShaderMask(
      shaderCallback: (rect) {
        return const LinearGradient(
          colors: [NeonColors.cyan, NeonColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect);
      },
      child: RichText(
        textAlign: textAlign,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Z',
              style: baseStyle.copyWith(fontSize: fontSize + 6),
            ),
            TextSpan(
              text: 'ARYAH',
              style: baseStyle.copyWith(
                fontSize: fontSize - 2,
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
