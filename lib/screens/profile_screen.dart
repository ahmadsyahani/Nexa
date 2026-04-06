import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_services.dart';
import '../screens/login_screen.dart';
import '../main.dart'; 
import '../services/translation_screen.dart';

import '../screens/menus/detail_profle_screen.dart';
import '../screens/menus/bahasa_screen.dart';
import '../screens/menus/personalisasi_screen.dart';
import '../screens/menus/bantuan_screen.dart';
import '../screens/menus/tentang_app_screen.dart';

class ProfileScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const ProfileScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    // 1. Variabel Tema Dinamis
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    // 2. Parsing Data Profil
    final rawProfile = profileData['data'];
    final Map<String, dynamic> data =
        (rawProfile is List && rawProfile.isNotEmpty)
        ? Map<String, dynamic>.from(rawProfile.first)
        : (rawProfile is Map ? Map<String, dynamic>.from(rawProfile) : {});

    final String fullName = data['nama'] ?? 'Mahasiswa PENS';
    final String nrp = data['nrp'] ?? '-';
    final String initials = fullName.isNotEmpty
        ? fullName[0].toUpperCase()
        : 'P';

    // 3. Bungkus dengan ValueListenableBuilder agar Bahasa berubah INSTAN
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // --- HERO AVATAR ---
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF2563EB,
                          ).withOpacity(isDark ? 0.1 : 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- NAMA & NRP ---
                  Text(
                    fullName,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF346EE0).withOpacity(0.15)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "NRP. $nrp",
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFF818CF8)
                            : const Color(0xFF4F46E5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- BAGIAN PENGATURAN AKUN ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppTranslations.getText('settings_acc', lang),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuRow(
                    title: AppTranslations.getText('menu_detail', lang),
                    icon: Icons.person_outline_rounded,
                    iconColor: isDark
                        ? const Color(0xFF60A5FA)
                        : const Color(0xFF2563EB),
                    bgColor: isDark
                        ? const Color(0xFF2563EB).withOpacity(0.15)
                        : const Color(0xFFDBEAFE),
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) =>
                            DetailProfilScreen(profileData: profileData),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuRow(
                    title: AppTranslations.getText('menu_lang', lang),
                    icon: Icons.translate_outlined,
                    iconColor: isDark
                        ? const Color(0xFFFBBF24)
                        : const Color(0xFFF59E0B),
                    bgColor: isDark
                        ? const Color(0xFFF59E0B).withOpacity(0.15)
                        : const Color(0xFFFEF3C7),
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const BahasaScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuRow(
                    title: AppTranslations.getText('menu_theme', lang),
                    icon: Icons.color_lens_outlined,
                    iconColor: isDark
                        ? const Color(0xFF34D399)
                        : const Color(0xFF10B981),
                    bgColor: isDark
                        ? const Color(0xFF10B981).withOpacity(0.15)
                        : const Color(0xFFD1FAE5),
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const PersonalisasiScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // --- BAGIAN LAINNYA ---
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppTranslations.getText('section_other', lang),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildMenuRow(
                    title: AppTranslations.getText('menu_help', lang),
                    icon: Icons.help_outline_rounded,
                    iconColor: isDark
                        ? const Color(0xFFA78BFA)
                        : const Color(0xFF8B5CF6),
                    bgColor: isDark
                        ? const Color(0xFF8B5CF6).withOpacity(0.15)
                        : const Color(0xFFEDE9FE),
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const BantuanScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuRow(
                    title: AppTranslations.getText('menu_about', lang),
                    icon: Icons.info_outline_rounded,
                    iconColor: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    bgColor: isDark
                        ? const Color(0xFF64748B).withOpacity(0.15)
                        : const Color(0xFFF1F5F9),
                    cardColor: cardColor,
                    textColor: textColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const TentangAppScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // --- TOMBOL LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        EtholApiService().clearAllCache();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      icon: Icon(
                        Icons.logout_rounded,
                        color: isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFEF4444),
                      ),
                      label: Text(
                        AppTranslations.getText('btn_logout', lang),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          color: isDark
                              ? const Color(0xFFF87171)
                              : const Color(0xFFEF4444),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? const Color(0xFFEF4444).withOpacity(0.1)
                            : const Color(0xFFFEF2F2),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER MENU LIST ---
  Widget _buildMenuRow({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color cardColor,
    required Color? textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: iconColor.withOpacity(0.1),
        highlightColor: iconColor.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
