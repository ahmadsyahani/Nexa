import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../services/translation_screen.dart';

class BahasaScreen extends StatefulWidget {
  const BahasaScreen({super.key});

  @override
  State<BahasaScreen> createState() => _BahasaScreenState();
}

class _BahasaScreenState extends State<BahasaScreen> {
  void _changeLanguage(String langCode) async {
    languageNotifier.value = langCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', langCode);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    children: [
                      _M3BouncyButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        AppTranslations.getText(
                          'menu_lang',
                          lang,
                        ), // Pakai 'menu_lang'
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildOption(
                        "Indonesia",
                        'id',
                        lang == 'id',
                        isDark,
                        cardColor,
                        textColor,
                      ),
                      const SizedBox(height: 12),
                      _buildOption(
                        "English (US)",
                        'en',
                        lang == 'en',
                        isDark,
                        cardColor,
                        textColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption(
    String name,
    String code,
    bool isSelected,
    bool isDark,
    Color cardColor,
    Color? textColor,
  ) {
    return GestureDetector(
      onTap: () => _changeLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF346EE0).withOpacity(0.1)
              : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF346EE0)
                : Colors.grey.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(
              name,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF346EE0) : textColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF346EE0)),
          ],
        ),
      ),
    );
  }
}

class _M3BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _M3BouncyButton({required this.child, this.onTap});
  @override
  State<_M3BouncyButton> createState() => _M3BouncyButtonState();
}

class _M3BouncyButtonState extends State<_M3BouncyButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) {
          setState(() => _isPressed = false);
          widget.onTap!();
        }
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
