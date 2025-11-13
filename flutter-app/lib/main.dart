import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/chatbot_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const ZarayahApp());
}

class ZarayahApp extends StatelessWidget {
  const ZarayahApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zaryah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Pure black
        primaryColor: const Color(0xFFFFD700), // Gold
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700), // Gold
          secondary: Color(0xFFFFA500), // Orange-gold accent
          surface: Color(0xFF0D0D0D), // Very dark gray (almost black)
          onPrimary: Color(0xFF000000),
          onSecondary: Color(0xFF000000),
          onSurface: Color(0xFFFFD700),
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000000), // Pure black
          foregroundColor: Color(0xFFFFD700), // Gold
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF0D0D0D), // Very dark cards
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            side: BorderSide(
              color: Color(0xFFFFD700), // Gold border
              width: 1.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0D0D0D),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFD700)), // Gold
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFFD700), width: 1.5), // Gold
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFFFFD700), // Gold
              width: 2.5,
            ),
          ),
          labelStyle: const TextStyle(color: Color(0xFFFFD700)), // Gold
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700), // Gold button
            foregroundColor: const Color(0xFF000000), // Black text
            elevation: 12,
            shadowColor: const Color(0xFFFFD700).withValues(alpha: 0.6), // Gold shadow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFD700), // Gold
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            color: Color(0xFFFFD700), // Gold
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFFFFD700), // Gold
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFFFD700), // Gold
          ),
          bodyLarge: TextStyle(
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFE0E0E0),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFFFD700), // Gold
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

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
        MaterialPageRoute(
          builder: (_) =>
              isLoggedIn ? const ChatbotScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_rounded,
              size: 100,
              color: const Color(0xFFFFD700), // Gold color
            ),
            const SizedBox(height: 24),
            Text(
              'Zaryah',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD700), // Gold color
                    fontSize: 48,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-Powered Personalized Learning',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFFFFD700), // Gold color
                    fontSize: 16,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
