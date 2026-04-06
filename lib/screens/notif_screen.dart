import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';

class NotifScreen extends StatefulWidget {
  final String email;
  final String password;

  const NotifScreen({super.key, required this.email, required this.password});

  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  final EtholApiService _apiService = EtholApiService();
  late Future<dynamic> _notifFuture;

  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _notifFuture = _apiService.getNotif(widget.email, widget.password);
  }

  Map<String, dynamic> _getNotifStyle(String type, bool isDark) {
    switch (type.toUpperCase()) {
      case 'PRESENSI':
        return {
          'icon': Icons.fingerprint_rounded,
          'color': isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
          'bg': isDark
              ? const Color(0xFF10B981).withOpacity(0.15)
              : const Color(0xFFD1FAE5),
        };
      case 'TUGAS':
        return {
          'icon': Icons.assignment_rounded,
          'color': isDark ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B),
          'bg': isDark
              ? const Color(0xFFF59E0B).withOpacity(0.15)
              : const Color(0xFFFEF3C7),
        };
      case 'PENGUMUMAN':
        return {
          'icon': Icons.campaign_rounded,
          'color': isDark ? const Color(0xFF60A5FA) : const Color(0xFF3B82F6),
          'bg': isDark
              ? const Color(0xFF3B82F6).withOpacity(0.15)
              : const Color(0xFFDBEAFE),
        };
      default:
        return {
          'icon': Icons.notifications_rounded,
          'color': isDark ? Colors.grey.shade400 : const Color(0xFF6B7280),
          'bg': isDark ? Colors.grey.shade800 : const Color(0xFFF3F4F6),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // 👇 BUNGKUS DENGAN NOTIFIER BAHASA 👇
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
                      M3BouncyButton(
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
                          'notif_title',
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

                // --- HORIZONTAL FILTER BAR ---
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildFilterChip(
                        AppTranslations.getText('filter_all', lang),
                        'Semua',
                        cardColor,
                        textColor,
                        isDark,
                      ),
                      _buildFilterChip(
                        AppTranslations.getText('filter_task', lang),
                        'Tugas',
                        cardColor,
                        textColor,
                        isDark,
                      ),
                      _buildFilterChip(
                        AppTranslations.getText('filter_presence', lang),
                        'Presensi',
                        cardColor,
                        textColor,
                        isDark,
                      ),
                      _buildFilterChip(
                        AppTranslations.getText('filter_announcement', lang),
                        'Pengumuman',
                        cardColor,
                        textColor,
                        isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: _notifFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              minHeight: 6,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF346EE0),
                              ),
                              backgroundColor: isDark
                                  ? Colors.grey.shade800
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            AppTranslations.getText(
                              'notif_error',
                              lang,
                            ), // 👈 DINAMIS
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }

                      final List<dynamic> allNotifs =
                          snapshot.data?['data'] ?? [];
                      final filteredNotifs = allNotifs.where((n) {
                        if (_selectedFilter == 'Semua') return true;
                        return n['notif_type'].toString().toUpperCase() ==
                            _selectedFilter.toUpperCase();
                      }).toList();

                      return PageTransitionSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder:
                            (child, primaryAnimation, secondaryAnimation) {
                              return FadeThroughTransition(
                                animation: primaryAnimation,
                                secondaryAnimation: secondaryAnimation,
                                fillColor: Colors.transparent,
                                child: child,
                              );
                            },
                        child: filteredNotifs.isEmpty
                            ? _buildEmptyState(
                                key: ValueKey('empty_$_selectedFilter'),
                                textColor: textColor,
                                lang: lang, // 👈 OPER BAHASA
                              )
                            : ListView.separated(
                                key: ValueKey('list_$_selectedFilter'),
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  24,
                                ),
                                itemCount: filteredNotifs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final item = filteredNotifs[index];
                                  final style = _getNotifStyle(
                                    item['notif_type'] ?? '',
                                    isDark,
                                  );

                                  return Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isDark ? 0.0 : 0.02,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: style['bg'],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            style['icon'],
                                            color: style['color'],
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['keterangan'] ??
                                                    'Pemberitahuan Baru',
                                                style: TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                  color: textColor,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item['time_since'] ?? '-',
                                                style: TextStyle(
                                                  fontFamily: 'PlusJakartaSans',
                                                  color: isDark
                                                      ? Colors.grey.shade400
                                                      : Colors.grey.shade500,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
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

  Widget _buildFilterChip(
    String label,
    String logicValue,
    Color cardColor,
    Color? textColor,
    bool isDark,
  ) {
    bool isSelected = _selectedFilter == logicValue;
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: M3BouncyButton(
        onTap: () => setState(() => _selectedFilter = logicValue),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF346EE0) : cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.grey.withOpacity(0.1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF346EE0).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label, // Teks yang tampil (Diterjemahkan)
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    Key? key,
    required Color? textColor,
    required String lang,
  }) {
    // Ambil teks kategori filter buat ditampilin di pesan kosong
    String filterName = 'Semua';
    if (_selectedFilter == 'Tugas') {
      filterName = AppTranslations.getText('filter_task', lang);
    }
    if (_selectedFilter == 'Presensi') {
      filterName = AppTranslations.getText('filter_presence', lang);
    }
    if (_selectedFilter == 'Pengumuman') {
      filterName = AppTranslations.getText('filter_announcement', lang);
    }
    if (_selectedFilter == 'Semua') {
      filterName = AppTranslations.getText('filter_all', lang);
    }

    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 64,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "${AppTranslations.getText('notif_empty', lang)} $filterName", // 👈 DINAMIS
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Colors.grey.shade500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ... (Class M3BouncyButton tetap sama)
class M3BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const M3BouncyButton({super.key, required this.child, this.onTap});
  @override
  State<M3BouncyButton> createState() => _M3BouncyButtonState();
}

class _M3BouncyButtonState extends State<M3BouncyButton> {
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
