import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/translation_screen.dart';

class TentangAppScreen extends StatelessWidget {
  const TentangAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final accentColor = const Color(0xFFF59E0B);

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- CUSTOM HEADER ---
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
                              color: Colors.grey.withOpacity(
                                isDark ? 0.05 : 0.1,
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
                      Text(
                        AppTranslations.getText('about_title', lang),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- MAIN CONTENT ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),

                        // 1. Logo Wordmark Nexa (Logic Switch & Glow)
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: isDark
                                  ? [
                                      BoxShadow(
                                        color: accentColor.withOpacity(0.2),
                                        blurRadius: 40,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Image.asset(
                              isDark
                                  ? 'assets/images/Nexa_wordmark_light.png'
                                  : 'assets/images/Nexa_wordmark.png',
                              height: 60,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 60,
                                    color: accentColor,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. Version Tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            "Stable Release 1.0.0",
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 3. Mission / Description
                        Text(
                          lang == 'en'
                              ? "Nexa is a minimalist personal workspace designed for IT students to unify academic tracking, coding projects, and productivity in one elegant interface."
                              : "Nexa adalah workspace personal minimalis yang dirancang khusus mahasiswa IT untuk menyatukan data akademik, proyek ngoding, dan produktivitas dalam satu interface elegan.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            height: 1.7,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // 4. "Built With" Header
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                "TECH STACK",
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: textColor?.withOpacity(0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 5. Tech Chips
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          alignment: WrapAlignment.center,
                          children: [
                            _buildTechChip("Flutter", isDark),
                            _buildTechChip("Dart", isDark),
                          ],
                        ),

                        const SizedBox(height: 60),

                        // 6. Developer Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.grey.withOpacity(
                                isDark ? 0.05 : 0.1,
                              ),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  isDark ? 0.0 : 0.02,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      accentColor,
                                      accentColor.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "AS",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppTranslations.getText(
                                      'dev_by',
                                      lang,
                                    ).toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Ahmad Syahani",
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTechChip(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
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
