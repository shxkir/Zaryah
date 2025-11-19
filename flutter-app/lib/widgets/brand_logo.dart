import 'package:flutter/material.dart';
import '../theme/neon_palette.dart';

enum BrandLogoStyle { glass, minimal }

class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 140,
    this.style = BrandLogoStyle.glass,
  });

  final double size;
  final BrandLogoStyle style;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/app_logo.png',
      height: size,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.auto_awesome_rounded,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.primary,
        );
      },
    );

    if (style == BrandLogoStyle.minimal) {
      return image;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: NeonColors.cyan.withOpacity(0.4)),
        gradient: const LinearGradient(
          colors: [Color(0x22FFFFFF), Color(0x11060B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: NeonColors.cyan.withOpacity(0.25),
            blurRadius: 45,
            spreadRadius: 2,
            offset: const Offset(0, 20),
          ),
        ],
        color: Colors.white.withOpacity(0.02),
      ),
      child: image,
    );
  }
}
