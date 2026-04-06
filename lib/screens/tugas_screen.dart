import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';

class TugasScreen extends StatefulWidget {
  final String email;
  final String password;

  const TugasScreen({super.key, required this.email, required this.password});

  @override
  State<TugasScreen> createState() => _TugasScreenState();
}

class _TugasScreenState extends State<TugasScreen> {
  final EtholApiService _apiService = EtholApiService();
  late Future<dynamic> _tugasFuture;
  bool _isDoneFilter = false;

  @override
  void initState() {
    super.initState();
    _tugasFuture = _apiService.getTugas(widget.email, widget.password);
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
                // --- 1. HEADER ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                  child: Text(
                    AppTranslations.getText('tugas_header', lang), // 👈 DINAMIS
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // --- 2. SLIDING FILTER ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade900
                          : const Color(0xFFEBEBEB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubicEmphasized,
                          alignment: _isDoneFilter
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.2 : 0.04,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildFilterTab(
                                AppTranslations.getText(
                                  'task_undone',
                                  lang,
                                ), // 👈 DINAMIS
                                !_isDoneFilter,
                                textColor,
                              ),
                            ),
                            Expanded(
                              child: _buildFilterTab(
                                AppTranslations.getText(
                                  'task_done',
                                  lang,
                                ), // 👈 DINAMIS
                                _isDoneFilter,
                                textColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- 3. LIST TUGAS ---
                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: _tugasFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF2563EB),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            AppTranslations.getText(
                              'tugas_error',
                              lang,
                            ), // 👈 DINAMIS
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }

                      final List<dynamic> allTugas =
                          snapshot.data?['data'] ?? [];
                      final List<dynamic> filteredTugas = allTugas.where((t) {
                        bool isTugasDone = t['submited'] == true;
                        return _isDoneFilter ? isTugasDone : !isTugasDone;
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
                        child: filteredTugas.isEmpty
                            ? _buildEmptyState(
                                key: ValueKey('empty_$_isDoneFilter'),
                                textColor: textColor,
                                lang: lang, // 👈 OPER BAHASA
                              )
                            : ListView.separated(
                                key: ValueKey('list_$_isDoneFilter'),
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  0,
                                  24,
                                  24,
                                ),
                                itemCount: filteredTugas.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  return _buildTugasCard(
                                    filteredTugas[index],
                                    isDark,
                                    cardColor,
                                    textColor,
                                    lang, // 👈 OPER BAHASA
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

  Widget _buildFilterTab(String label, bool isSelected, Color? textColor) {
    return GestureDetector(
      onTap: () => setState(
        () => _isDoneFilter =
            label ==
            AppTranslations.getText('task_done', languageNotifier.value),
      ),
      onTapDown: (_) => setState(
        () => _isDoneFilter = (label == "Selesai" || label == "Done"),
      ),
      // Kita pakai pengecekan label sederhana biar logic internal switch tetap jalan
      onTapUp: (_) {},
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: isSelected ? textColor : Colors.grey.shade500,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildTugasCard(
    dynamic item,
    bool isDark,
    Color cardColor,
    Color? textColor,
    String lang,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B82F6).withOpacity(0.15)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['matkul'] ??
                        AppTranslations.getText('default_matkul', lang),
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF60A5FA)
                          : const Color(0xFF3B82F6),
                      fontSize: 10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                _isDoneFilter
                    ? Icons.check_circle_rounded
                    : Icons.assignment_late_outlined,
                color: _isDoneFilter
                    ? (isDark
                          ? const Color(0xFF34D399)
                          : const Color(0xFF10B981))
                    : (isDark
                          ? const Color(0xFFFBBF24)
                          : const Color(0xFFF59E0B)),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            item['title'] ?? 'Judul Tugas',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: textColor,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withOpacity(0.08)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: isDark
                      ? const Color(0xFFF87171)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${AppTranslations.getText('label_deadline', lang)}: ${item['deadline'] ?? '-'}", // 👈 DINAMIS
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: isDark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFEF4444),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    Key? key,
    required Color? textColor,
    required String lang,
  }) {
    return Center(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isDoneFilter
                ? Icons.assignment_turned_in_outlined
                : Icons.celebration_rounded,
            size: 64,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _isDoneFilter
                ? AppTranslations.getText('empty_done', lang)
                : AppTranslations.getText('empty_undone', lang), // 👈 DINAMIS
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
