import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'theme/luxury_theme.dart';
import 'widgets/brand_logo.dart';
import 'widgets/luxury_components.dart';
import 'widgets/zaryah_wordmark.dart';
import 'widgets/animated_components.dart';

void main() {
  runApp(const ZaryahApp());
}

class ZaryahApp extends StatelessWidget {
  const ZaryahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaryah',
      debugShowCheckedModeBanner: false,
      theme: LuxuryTheme.theme,
      home: const SplashScreen(),
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const SmoothScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}

/// Custom scroll behavior for smooth scrolling throughout the app
class SmoothScrollBehavior extends ScrollBehavior {
  const SmoothScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(
      parent: AlwaysScrollableScrollPhysics(),
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    // Use stretch indicator for iOS-like smooth overscroll
    return StretchingOverscrollIndicator(
      axisDirection: details.direction,
      child: child,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 1));

    final isLoggedIn = await _apiService.isLoggedIn();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        LuxuryPageRoute(
          page: isLoggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: GoldGradientBackground(child: _SplashContent()),
    );
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          BrandLogo(size: 160, style: BrandLogoStyle.minimal),
          SizedBox(height: 18),
          ZaryahWordmark(fontSize: 52),
          SizedBox(height: 12),
          _SplashTagline(),
          SizedBox(height: 40),
          _SplashLoader(),
        ],
      ),
    );
  }
}

class _SplashTagline extends StatelessWidget {
  const _SplashTagline();

  @override
  Widget build(BuildContext context) {
    return Text(
      'AI-Powered Personalized Learning',
      textAlign: TextAlign.center,
      style: LuxuryTextStyles.bodyLarge.copyWith(
            color: LuxuryColors.softGold,
            letterSpacing: 2,
          ),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: 54,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: const AlwaysStoppedAnimation<Color>(LuxuryColors.primaryGold),
        backgroundColor: LuxuryColors.borderGold,
      ),
    );
  }
}
