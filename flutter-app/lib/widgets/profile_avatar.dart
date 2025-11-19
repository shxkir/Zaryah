import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/initials_helper.dart';
import 'simple_avatar.dart';

/// A widget that displays user profile pictures with proper fallback handling.
/// Supports three cases:
/// 1. HTTP URLs (starts with 'http') - uses Image.network
/// 2. Base64 data URIs (starts with 'data:image/') - decodes and uses Image.memory
/// 3. No picture - shows initials avatar with customizable colors
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    required this.size,
    this.backgroundColor = const Color(0xFFFFD700),
    this.textColor = const Color(0xFF000000),
  });

  @override
  Widget build(BuildContext context) {
    // Case 1: HTTP URL - use network image
    if (imageUrl != null && imageUrl!.startsWith('http')) {
      return CircleAvatar(
        radius: size / 2,
        backgroundColor: backgroundColor,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {
          // On error, fall back to initials (handled by child)
        },
        child: _buildInitialsFallback(),
      );
    }

    // Case 2: Base64 data URI - decode and use memory image
    if (imageUrl != null && imageUrl!.startsWith('data:image/')) {
      try {
        final base64String = imageUrl!.split(',').last;
        final imageBytes = base64Decode(base64String);
        return CircleAvatar(
          radius: size / 2,
          backgroundColor: backgroundColor,
          backgroundImage: MemoryImage(imageBytes),
          onBackgroundImageError: (_, __) {
            // On error, fall back to initials (handled by child)
          },
          child: _buildInitialsFallback(),
        );
      } catch (e) {
        // If decoding fails, fall back to initials
        return _buildInitialsAvatar();
      }
    }

    // Case 3: No picture - show initials
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = initialsFromName(name, fallback: '?');
    return SimpleAvatar(
      size: size,
      backgroundColor: backgroundColor,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget? _buildInitialsFallback() {
    // Return null to let CircleAvatar's backgroundImage show when available
    // Only show initials when image fails to load
    return null;
  }
}
