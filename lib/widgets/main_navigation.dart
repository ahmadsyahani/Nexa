import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../screens/home_screen.dart';
import '../screens/jadwal_screen.dart';
import '../screens/tugas_screen.dart';
import '../screens/profile_screen.dart';
import '../main.dart';
import '../services/translation_screen.dart';

class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String email;
  final String password;

  const MainNavigation({
    super.key,
    required this.profileData,
    required this.email,
    required this.password,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(
        profileData: widget.profileData,
        email: widget.email,
        password: widget.password,
      ),
      JadwalScreen(email: widget.email, password: widget.password),
      TugasScreen(email: widget.email, password: widget.password),
      ProfileScreen(profileData: widget.profileData),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final navColor = isDark ? const Color(0xFF111827) : Colors.white;
    final activeIconColor = isDark
        ? const Color(0xFF818CF8)
        : const Color(0xFF2563EB);
    final indicatorCol = isDark
        ? const Color(0xFF346EE0).withOpacity(0.3)
        : const Color(0xFFD1E4FF);

    // 👇 BUNGKUS DENGAN NOTIFIER BAHASA 👇
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: PageTransitionSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: primaryAnimation,
                secondaryAnimation: secondaryAnimation,
                fillColor: bgColor,
                child: child,
              );
            },
            child: _pages[_selectedIndex],
          ),

          bottomNavigationBar: NavigationBar(
            elevation: 0,
            backgroundColor: navColor,
            surfaceTintColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            indicatorColor: indicatorCol,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: activeIconColor),
                // 👇 DINAMIS 👇
                label: AppTranslations.getText('nav_home', lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.calendar_month_outlined),
                selectedIcon: Icon(
                  Icons.calendar_month_rounded,
                  color: activeIconColor,
                ),
                // 👇 DINAMIS 👇
                label: AppTranslations.getText('nav_jadwal', lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.assignment_outlined),
                selectedIcon: Icon(
                  Icons.assignment_rounded,
                  color: activeIconColor,
                ),
                // 👇 DINAMIS 👇
                label: AppTranslations.getText('nav_tugas', lang),
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(
                  Icons.person_rounded,
                  color: activeIconColor,
                ),
                // 👇 DINAMIS 👇
                label: AppTranslations.getText('profil_title', lang),
              ),
            ],
          ),
        );
      },
    );
  }
}
