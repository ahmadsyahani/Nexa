import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';

class PortalScreen extends StatelessWidget {
  const PortalScreen({super.key});

  // --- DATA PORTAL LINK PENS & KELAS ---
  final List<Map<String, dynamic>> _portalLinks = const [
    {
      'title': 'ETHOL PENS',
      'desc': 'Presensi & Kuliah Online',
      'icon': Icons.school_rounded,
      'color': 0xFF3B82F6, // Blue
      'url': 'https://ethol.pens.ac.id/',
    },
    {
      'title': 'MIS PENS',
      'desc': 'Sistem Informasi Manajemen',
      'icon': Icons.account_balance_rounded,
      'color': 0xFFF59E0B, // Amber
      'url': 'https://mis.pens.ac.id/',
    },
    {
      'title': 'MIS ITByte',
      'desc': 'Information Center Kelas',
      'icon': Icons.webhook_rounded,
      'color': 0xFF10B981, // Emerald
      'url': 'https://mis.itbyte.my.id/',
    },
    {
      'title': 'GitHub Kelas',
      'desc': 'Repository Tugas & Project',
      'icon': Icons.code_rounded,
      'color': 0xFF6B7280, // Gray
      'url': 'https://github.com/Bytes-Creative-Teams',
    },
  ];

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuka link: $urlString"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    children: [
                      _BouncyIconButton(
                        onTap: () => Navigator.pop(context),
                        icon: Icons.arrow_back_ios_new_rounded,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        lang == 'en' ? 'Quick Portal' : 'Portal Kampus',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    lang == 'en'
                        ? 'Fast access to your essential campus tools.'
                        : 'Jalan pintas ke semua website penting PENS.',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // --- KONTEN GRID MENU ---
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 kolom sejajar
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85, // Biar kotaknya proporsional
                        ),
                    itemCount: _portalLinks.length,
                    itemBuilder: (context, index) {
                      final link = _portalLinks[index];
                      final linkColor = Color(link['color']);

                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(
                          milliseconds: 400 + (index * 100),
                        ), // Animasi Pop-up beruntun
                        curve: Curves.easeOutBack,
                        builder: (context, val, child) {
                          return Transform.scale(
                            scale: val,
                            child: Opacity(
                              opacity: val.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: _BouncyButton(
                          onTap: () => _launchURL(context, link['url']),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black.withOpacity(0.05),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: linkColor.withOpacity(
                                    isDark ? 0.05 : 0.1,
                                  ),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Ikon Link
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: linkColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    link['icon'],
                                    color: linkColor,
                                    size: 28,
                                  ),
                                ),
                                const Spacer(),

                                // Teks Judul
                                Text(
                                  link['title'],
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),

                                // Teks Deskripsi
                                Text(
                                  link['desc'],
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                    height: 1.3,
                                    color: isDark
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- WIDGET HELPER ---
class _BouncyIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BouncyIconButton({required this.icon, required this.onTap});
  @override
  State<_BouncyIconButton> createState() => _BouncyIconButtonState();
}

class _BouncyIconButtonState extends State<_BouncyIconButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Icon(widget.icon, size: 20),
        ),
      ),
    );
  }
}

class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BouncyButton({required this.child, required this.onTap});
  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
