import 'package:flutter/material.dart';

class SimpleAvatar extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Widget child;

  const SimpleAvatar({
    super.key,
    required this.size,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
