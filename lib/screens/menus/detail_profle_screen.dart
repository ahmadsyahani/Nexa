import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/translation_screen.dart';

class DetailProfilScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const DetailProfilScreen({super.key, required this.profileData});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    final rawProfile = profileData['data'];
    final Map<String, dynamic> data =
        (rawProfile is List && rawProfile.isNotEmpty)
        ? Map<String, dynamic>.from(rawProfile.first)
        : (rawProfile is Map ? Map<String, dynamic>.from(rawProfile) : {});

    final String fullName = data['nama'] ?? 'Mahasiswa PENS';
    final String nrp = data['nrp'] ?? '-';

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        // 👇 Logika fallback dipindah ke sini biar dinamis 👇
        final String email =
            data['email'] ?? AppTranslations.getText('no_email', lang);

        // Cek jika status dari API adalah 'Aktif', kita terjemahkan.
        // Jika statusnya lain (misal: 'Cuti'), dia bakal balik ke teks asli kalau kuncinya ga ada.
        final String rawStatus = data['status'] ?? 'Aktif';
        final String displayStatus = (rawStatus == 'Aktif')
            ? AppTranslations.getText('status_active', lang)
            : rawStatus;

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
                        AppTranslations.getText('detail_title', lang),
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

                // --- KONTEN ---
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildInfoCard(
                          AppTranslations.getText('label_nama', lang),
                          fullName,
                          Icons.badge_rounded,
                          isDark,
                          cardColor,
                          textColor,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          AppTranslations.getText('label_nrp', lang),
                          nrp,
                          Icons.pin_rounded,
                          isDark,
                          cardColor,
                          textColor,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          AppTranslations.getText('label_email', lang),
                          email, // 👈 Udah dinamis
                          Icons.alternate_email_rounded,
                          isDark,
                          cardColor,
                          textColor,
                        ),
                        const SizedBox(height: 16),
                        _buildInfoCard(
                          AppTranslations.getText('label_status', lang),
                          displayStatus, // 👈 Udah dinamis
                          Icons.school_rounded,
                          isDark,
                          cardColor,
                          textColor,
                        ),
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

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    bool isDark,
    Color cardColor,
    Color? textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF346EE0).withOpacity(0.15)
                  : const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF346EE0),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... (Class _M3BouncyButton tetap sama)
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
