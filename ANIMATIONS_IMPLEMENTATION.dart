// ==========================================
// PROFESSIONAL ANIMATIONS & TRANSITIONS
// Luxury Theme - Subtle, Elegant, Not Playful
// ==========================================

import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';

// ==========================================
// 1. PAGE TRANSITIONS
// ==========================================

class LuxuryPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  LuxuryPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Slide up with fade
            const begin = Offset(0.0, 0.05);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var slideTween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );
            var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(slideTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            );
          },
        );
}

// Usage in Navigator:
// Navigator.of(context).push(
//   LuxuryPageRoute(page: ProfileScreen()),
// );

// ==========================================
// 2. ANIMATED GOLD CARD
// ==========================================

class AnimatedGoldCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Duration duration;
  final Curve curve;

  const AnimatedGoldCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedGoldCard> createState() => _AnimatedGoldCardState();
}

class _AnimatedGoldCardState extends State<AnimatedGoldCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.forward();
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
        padding: widget.padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LuxuryColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LuxuryColors.borderGold,
            width: 1,
          ),
          boxShadow: LuxuryColors.cardShadow,
        ),
        child: widget.onTap != null
            ? InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(16),
                splashColor: LuxuryColors.primaryGold.withOpacity(0.1),
                highlightColor: LuxuryColors.softGold.withOpacity(0.05),
                child: widget.child,
              )
            : widget.child,
      ),
    );
  }
}

// ==========================================
// 3. GOLD BUTTON WITH RIPPLE ANIMATION
// ==========================================

class AnimatedGoldButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double? width;
  final double? height;
  final bool isLoading;

  const AnimatedGoldButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  State<AnimatedGoldButton> createState() => _AnimatedGoldButtonState();
}

class _AnimatedGoldButtonState extends State<AnimatedGoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height ?? 50,
          decoration: BoxDecoration(
            gradient: LuxuryColors.goldGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isPressed
                ? []
                : LuxuryColors.goldGlow(opacity: 0.4),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: LuxuryColors.mainBackground,
                          strokeWidth: 2,
                        ),
                      )
                    : widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 4. SHIMMER LOADING EFFECT
// ==========================================

class GoldShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const GoldShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<GoldShimmer> createState() => _GoldShimmerState();
}

class _GoldShimmerState extends State<GoldShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                LuxuryColors.cardBackground,
                LuxuryColors.borderGold.withOpacity(0.3),
                LuxuryColors.cardBackground,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

// ==========================================
// 5. PULSING AVATAR ANIMATION
// ==========================================

class PulsingAvatar extends StatefulWidget {
  final String? imageUrl;
  final String initials;
  final double size;

  const PulsingAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.size = 120,
  });

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

class _PulsingAvatarState extends State<PulsingAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.2,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: LuxuryColors.goldGlow(
                opacity: _glowAnimation.value,
              ),
            ),
            child: child,
          ),
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: LuxuryColors.primaryGold,
          shape: BoxShape.circle,
          border: Border.all(
            color: LuxuryColors.softGold,
            width: 3,
          ),
        ),
        child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
            ? ClipOval(
                child: Image.network(
                  widget.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials();
                  },
                ),
              )
            : _buildInitials(),
      ),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        widget.initials,
        style: TextStyle(
          fontSize: widget.size * 0.4,
          fontWeight: FontWeight.bold,
          color: LuxuryColors.mainBackground,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

// ==========================================
// 6. FADE-IN LIST ANIMATION
// ==========================================

class FadeInList extends StatelessWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;

  const FadeInList({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => FadeInItem(
          delay: delay * index,
          duration: duration,
          child: children[index],
        ),
      ),
    );
  }
}

class FadeInItem extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const FadeInItem({
    super.key,
    required this.child,
    required this.delay,
    required this.duration,
  });

  @override
  State<FadeInItem> createState() => _FadeInItemState();
}

class _FadeInItemState extends State<FadeInItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
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
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ==========================================
// USAGE EXAMPLES
// ==========================================

/*
// Example 1: Page Navigation with Animation
Navigator.of(context).push(
  LuxuryPageRoute(page: ProfileScreen()),
);

// Example 2: Animated Card
AnimatedGoldCard(
  child: Text('Content here'),
  onTap: () => print('Tapped'),
);

// Example 3: Animated Button
AnimatedGoldButton(
  onPressed: () => _submit(),
  child: Text('Submit'),
  isLoading: _isLoading,
);

// Example 4: Shimmer Loading
GoldShimmer(
  isLoading: _isLoading,
  child: GoldCard(
    child: Container(height: 100),
  ),
);

// Example 5: Pulsing Avatar
PulsingAvatar(
  imageUrl: user.profilePictureUrl,
  initials: getInitials(user.name),
  size: 120,
);

// Example 6: Fade-in List
FadeInList(
  children: [
    GoldCard(child: Text('Item 1')),
    GoldCard(child: Text('Item 2')),
    GoldCard(child: Text('Item 3')),
  ],
);
*/
