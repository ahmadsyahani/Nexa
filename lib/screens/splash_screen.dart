import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../widgets/main_navigation.dart';
import '../services/api_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final EtholApiService _apiService = EtholApiService();

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));

    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');

    if (!mounted) return;

    if (savedEmail != null &&
        savedEmail.isNotEmpty &&
        savedPassword != null &&
        savedPassword.isNotEmpty) {
      try {
        final response = await _apiService.getProfile(
          savedEmail,
          savedPassword,
        );

        if (response != null && response['error'] == false) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainNavigation(
                profileData: response,
                email: savedEmail,
                password: savedPassword,
              ),
            ),
          );
          return;
        }
      } catch (e) {
        debugPrint("Auto login gagal: $e");
      }
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF111827)
          : const Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: Opacity(
                    opacity: val.clamp(0.0, 1.0),
                    child: Image.asset(
                      'assets/images/Nexa.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 48),

            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Color(0xFFF59E0B),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
