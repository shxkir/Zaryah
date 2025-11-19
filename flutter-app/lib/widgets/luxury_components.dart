import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

/// Professional Luxury Components Library
/// Enterprise-grade reusable components for consistent styling

/// Gold-bordered card with gradient background
class GoldCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final bool showGlow;

  const GoldCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.showGlow = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LuxuryColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: LuxuryColors.borderGold,
          width: 1,
        ),
        boxShadow: showGlow ? LuxuryColors.goldGlow() : LuxuryColors.cardShadow,
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Gold icon button with proper styling
class GoldIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? color;
  final String? tooltip;
  final EdgeInsetsGeometry? padding;

  const GoldIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 24,
    this.color,
    this.tooltip,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconButton = IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      iconSize: size,
      color: color ?? LuxuryColors.primaryGold,
      padding: padding ?? const EdgeInsets.all(8),
      tooltip: tooltip,
    );

    return iconButton;
  }
}

/// Gold-outlined text field matching luxury theme
class GoldTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  const GoldTextField({
    Key? key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      style: LuxuryTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: LuxuryColors.softGold)
            : null,
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: LuxuryColors.softGold),
                onPressed: onSuffixIconTap,
              )
            : null,
        filled: true,
        fillColor: LuxuryColors.secondaryBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.primaryGold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: LuxuryColors.errorGold,
            width: 1,
          ),
        ),
        labelStyle: LuxuryTextStyles.label,
        hintStyle: TextStyle(
          color: LuxuryColors.mutedText.withOpacity(0.5),
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Bold gold text for section headers
class GoldSectionHeader extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const GoldSectionHeader({
    Key? key,
    required this.text,
    this.icon,
    this.trailing,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: LuxuryColors.primaryGold, size: 24),
                const SizedBox(width: 12),
              ],
              Text(
                text,
                style: LuxuryTextStyles.h3,
              ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Consistent AppBar with luxury styling
class GoldAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const GoldAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: LuxuryColors.secondaryBackground,
      elevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: LuxuryColors.primaryGold,
          letterSpacing: 1.0,
        ),
      ),
      iconTheme: const IconThemeData(
        color: LuxuryColors.primaryGold,
        size: 24,
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );
}

/// Modal bottom sheet with gold border
class GoldBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  final double? height;

  const GoldBottomSheet({
    Key? key,
    required this.title,
    required this.child,
    this.height,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget child,
    double? height,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GoldBottomSheet(
        title: title,
        child: child,
        height: height,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: LuxuryColors.cardBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: LuxuryColors.borderGold,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: LuxuryColors.borderGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              title,
              style: LuxuryTextStyles.h2,
            ),
          ),
          const Divider(color: LuxuryColors.borderGold),
          // Content
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Gradient background wrapper for screens
class GoldGradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GoldGradientBackground({
    Key? key,
    required this.child,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? LuxuryColors.primaryGradient,
      ),
      child: child,
    );
  }
}

/// Gold-bordered circular avatar frame
class GoldAvatarFrame extends StatelessWidget {
  final String? imageUrl;
  final String? base64Image;
  final String initials;
  final double size;
  final double borderWidth;
  final bool showGlow;
  final VoidCallback? onTap;

  const GoldAvatarFrame({
    Key? key,
    this.imageUrl,
    this.base64Image,
    required this.initials,
    this.size = 100,
    this.borderWidth = 3,
    this.showGlow = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget avatarContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LuxuryColors.goldGradient,
        boxShadow: showGlow ? LuxuryColors.goldGlow(opacity: 0.4) : null,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LuxuryColors.cardBackground,
        ),
        child: ClipOval(
          child: _buildAvatarImage(),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }

    return avatarContent;
  }

  Widget _buildAvatarImage() {
    // Priority: HTTP URL > Base64 > Initials
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
      );
    } else if (base64Image != null && base64Image!.isNotEmpty) {
      try {
        // Handle data URI format
        String base64String = base64Image!;
        if (base64String.startsWith('data:')) {
          base64String = base64String.split(',')[1];
        }
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(),
        );
      } catch (e) {
        return _buildInitialsAvatar();
      }
    }

    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    return Container(
      color: LuxuryColors.secondaryBackground,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
            color: LuxuryColors.primaryGold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Gold elevated button with proper styling
class GoldButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool isLoading;
  final double? width;

  const GoldButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: LuxuryColors.mainBackground,
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          child: buttonChild,
        ),
      );
    }

    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: buttonChild,
      ),
    );
  }
}

/// Gold-styled stats card for metrics
class GoldStatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const GoldStatsCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoldCard(
      onTap: onTap,
      showGlow: true,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: LuxuryColors.primaryGold, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: LuxuryTextStyles.h2.copyWith(
              color: LuxuryColors.primaryGold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: LuxuryTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Professional luxury-themed dropdown selector
class GoldDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T) itemLabel;
  final String? hint;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const GoldDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemLabel,
    this.hint,
    this.width,
    this.padding,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 48,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LuxuryColors.borderGold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: LuxuryColors.primaryGold.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemLabel(item),
                style: LuxuryTextStyles.bodyMedium.copyWith(
                  color: LuxuryColors.primaryGold,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          hint: hint != null
              ? Text(
                  hint!,
                  style: LuxuryTextStyles.bodyMedium.copyWith(
                    color: LuxuryColors.mutedText,
                    fontSize: 14,
                  ),
                )
              : null,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: LuxuryColors.primaryGold,
            size: 24,
          ),
          dropdownColor: const Color(0xFF0A0A0A),
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
          style: LuxuryTextStyles.bodyMedium.copyWith(
            color: LuxuryColors.primaryGold,
          ),
          isExpanded: true,
          menuMaxHeight: 300,
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((T item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  itemLabel(item),
                  style: LuxuryTextStyles.bodyMedium.copyWith(
                    color: LuxuryColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
