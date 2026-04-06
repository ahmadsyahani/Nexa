import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../../services/translation_screen.dart';

class PersonalisasiScreen extends StatefulWidget {
  const PersonalisasiScreen({super.key});

  @override
  State<PersonalisasiScreen> createState() => _PersonalisasiScreenState();
}

class _PersonalisasiScreenState extends State<PersonalisasiScreen> {
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = themeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data tema saat ini
    final isDarkNow = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: bgColor,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      children: [
                        _M3BouncyButton(
                          onTap: () => Navigator.pop(context),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.withOpacity(
                                  isDarkNow ? 0.05 : 0.1,
                                ),
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
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                          child: Text(
                            AppTranslations.getText('theme_title', lang),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey.withOpacity(
                            isDarkNow ? 0.05 : 0.1,
                          ),
                        ),
                      ),
                      child: Theme(
                        // 👇 KILL EFEK SPLASH/HIGHLIGHT ABU-ABU DI SWITCH 👇
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                        ),
                        child: SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          title: Text(
                            AppTranslations.getText('dark_mode', lang),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor,
                            ),
                          ),
                          subtitle: Text(
                            AppTranslations.getText('dark_mode_desc', lang),
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          value: isDarkMode,
                          activeThumbColor: const Color(0xFF346EE0),
                          activeTrackColor: const Color(
                            0xFF346EE0,
                          ).withOpacity(0.3),
                          onChanged: (value) async {
                            setState(() => isDarkMode = value);

                            // Update tema global
                            themeNotifier.value = value
                                ? ThemeMode.dark
                                : ThemeMode.light;

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('isDarkMode', value);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- BOUNCY BUTTON COMPONENT ---
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
