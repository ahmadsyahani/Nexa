import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/translation_screen.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    // 👇 BUNGKUS PAKE NOTIFIER BAHASA 👇
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
                          'menu_help',
                          lang,
                        ), // 👈 DINAMIS
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- KONTEN FAQ ---
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    children: [
                      _buildFaqItem(
                        AppTranslations.getText('help_q1', lang), 
                        AppTranslations.getText('help_a1', lang), 
                        isDark,
                        cardColor,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      _buildFaqItem(
                        AppTranslations.getText('help_q2', lang), // 👈 DINAMIS
                        AppTranslations.getText('help_a2', lang), // 👈 DINAMIS
                        isDark,
                        cardColor,
                        textColor,
                      ),
                      const SizedBox(height: 16),
                      _buildFaqItem(
                        AppTranslations.getText('help_q3', lang), // 👈 DINAMIS
                        AppTranslations.getText('help_a3', lang), // 👈 DINAMIS
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

  Widget _buildFaqItem(
    String question,
    String answer,
    bool isDark,
    Color cardColor,
    Color? textColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          collapsedShape: const RoundedRectangleBorder(side: BorderSide.none),
          iconColor: const Color(0xFF346EE0),
          collapsedIconColor: isDark
              ? Colors.grey.shade600
              : Colors.grey.shade400,
          title: Text(
            question,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: textColor,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          expandedAlignment: Alignment.centerLeft,
          children: [
            Text(
              answer,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.6,
              ),
            ),
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
