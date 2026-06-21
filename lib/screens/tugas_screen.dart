import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:animations/animations.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';
import '../services/notification_service.dart';
import 'package:home_widget/home_widget.dart';

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
    _tugasFuture = _apiService.getTugas(widget.email, widget.password).then((response) {
      _scheduleTaskReminders(response);
      return response;
    });
  }

  void _scheduleTaskReminders(dynamic response) async {
    if (response == null || response['error'] == true) return;
    
    final List<dynamic> tugasList = response['data'] ?? [];
    
    // UPDATE WIDGET DATA
    try {
      final undoneTasks = tugasList.where((t) => t['submited'] == false).toList();
      String nearestDeadline = "Deadline: -";
      if (undoneTasks.isNotEmpty) {
         final firstTask = undoneTasks.firstWhere((t) => t['deadline'] != null, orElse: () => undoneTasks.first);
         nearestDeadline = "Deadline: ${firstTask['deadline'] ?? '-'}";
      }
      await HomeWidget.saveWidgetData<String>('undone_tasks', 'Tugas Belum Selesai: ${undoneTasks.length}');
      await HomeWidget.saveWidgetData<String>('nearest_deadline', nearestDeadline);
      await HomeWidget.updateWidget(name: 'AppWidgetProvider', androidName: 'AppWidgetProvider');
    } catch (e) {
      debugPrint("Failed to update widget: $e");
    }

    int notifId = 1000; // Offset for task reminders
    
    for (var tugas in tugasList) {
      if (tugas['submited'] == false && tugas['deadline'] != null) {
        try {
          // Parse string date to DateTime
          // Try to handle standard ISO-8601 or similar database string formats
          final String deadlineStr = tugas['deadline'].toString();
          // Provide basic normalization if needed, e.g., '2024-06-25 23:59:00' to '2024-06-25T23:59:00'
          final normalizedStr = deadlineStr.replaceFirst(' ', 'T');
          final DateTime deadlineDate = DateTime.parse(normalizedStr);
          final DateTime reminder1Day = deadlineDate.subtract(const Duration(days: 1));
          final DateTime reminder12Hours = deadlineDate.subtract(const Duration(hours: 12));
          final DateTime reminder6Hours = deadlineDate.subtract(const Duration(hours: 6));
          
          if (reminder1Day.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: notifId,
              title: 'Pengingat Tugas!',
              body: 'Tugas ${tugas['title'] ?? 'baru'} deadline besok (H-1)!',
              scheduledDate: reminder1Day,
            );
          }
          
          if (reminder12Hours.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: notifId + 10000,
              title: 'Peringatan Tugas!',
              body: 'Tugas ${tugas['title'] ?? 'baru'} deadline sisa 12 Jam lagi!',
              scheduledDate: reminder12Hours,
            );
          }
          
          if (reminder6Hours.isAfter(DateTime.now())) {
            NotificationService().scheduleNotification(
              id: notifId + 20000,
              title: 'Darurat Tugas!',
              body: 'Tugas ${tugas['title'] ?? 'baru'} deadline sisa 6 Jam lagi! Segera selesaikan!',
              scheduledDate: reminder6Hours,
            );
          }
        } catch (e) {
          debugPrint('Gagal mem-parsing tanggal tugas: ${tugas['deadline']} - error: $e');
        }
      }
      notifId++;
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
                                    context,
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
    BuildContext context,
  ) {
    final String title = item['title'] ?? 'Judul Tugas';
    final String matkul = item['matkul'] ?? AppTranslations.getText('default_matkul', lang);
    final String deadline = item['deadline'] ?? '-';
    final String description = item['keterangan'] ?? item['deskripsi'] ?? item['description'] ?? item['isi'] ?? 'Tidak ada deskripsi.';

    return GestureDetector(
      onTap: () {
        _showTugasDetailModal(context, title, matkul, deadline, description, isDark, cardColor, textColor, lang);
      },
      child: Container(
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
                      matkul,
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
              title,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: textColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.4,
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
                      "${AppTranslations.getText('label_deadline', lang)}: $deadline", // 👈 DINAMIS
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
      ),
    );
  }

  void _showTugasDetailModal(
    BuildContext context,
    String title,
    String matkul,
    String deadline,
    String description,
    bool isDark,
    Color cardColor,
    Color? textColor,
    String lang,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Tugas Detail",
      barrierColor: Colors.black.withOpacity(0.4), // Slightly lighter barrier for blur
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              matkul,
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF60A5FA)
                                    : const Color(0xFF3B82F6),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: textColor,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.red.withOpacity(0.08)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.red.withOpacity(0.2)
                              : Colors.red.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 18,
                            color: isDark
                                ? const Color(0xFFF87171)
                                : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppTranslations.getText('label_deadline', lang),
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: isDark
                                        ? const Color(0xFFF87171)
                                        : const Color(0xFFEF4444),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  deadline,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    color: isDark
                                        ? const Color(0xFFF87171)
                                        : const Color(0xFFEF4444),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Deskripsi",
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 14,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: anim1,
            curve: Curves.easeOutBack,
          )),
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
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
