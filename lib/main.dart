import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';
import 'widgets/main_navigation.dart';
import 'services/api_services.dart';
import 'screens/splash_screen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<String> languageNotifier = ValueNotifier('id');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final isDark = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final savedLang = prefs.getString('selectedLanguage') ?? 'id';
  languageNotifier.value = savedLang;

  final String? email = prefs.getString('saved_email');
  final String? password = prefs.getString('saved_password');

  Widget startWidget = const LoginScreen();

  if (email != null &&
      password != null &&
      email.isNotEmpty &&
      password.isNotEmpty) {
    try {
      final profile = await EtholApiService().getProfile(
        email,
        password,
        refresh: true,
      );

      if (profile != null && profile['error'] == false) {
        startWidget = MainNavigation(
          profileData: profile,
          email: email,
          password: password,
        );
      }
    } catch (e) {
      debugPrint("Auto-login failed: $e");
      startWidget = const LoginScreen();
    }
  }

  runApp(MyApp(homeScreen: startWidget));
}

class MyApp extends StatelessWidget {
  final Widget homeScreen;
  const MyApp({super.key, required this.homeScreen});

  @override
  Widget build(BuildContext context) {
    // 👇 3. Bungkus dengan Notifier Bahasa
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentMode, child) {
            return MaterialApp(
              title: 'Nexa',
              debugShowCheckedModeBanner: false,
              locale: Locale(lang),

              themeMode: currentMode,

              // --- TEMA TERANG ---
              theme: ThemeData(
                fontFamily: 'PlusJakartaSans',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF346EE0),
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFFF7F7F7),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                    TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                  },
                ),
              ),

              // --- TEMA GELAP ---
              darkTheme: ThemeData(
                brightness: Brightness.dark,
                fontFamily: 'PlusJakartaSans',
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF346EE0),
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                scaffoldBackgroundColor: const Color(0xFF111827),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                    TargetPlatform.iOS: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                  },
                ),
              ),

              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
