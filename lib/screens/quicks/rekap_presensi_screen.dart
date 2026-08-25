import 'package:flutter/material.dart';
import '../../services/api_services.dart';
import '../../services/translation_screen.dart';
import '../../main.dart';

class RekapPresensiScreen extends StatefulWidget {
  final String email;
  final String password;

  const RekapPresensiScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<RekapPresensiScreen> createState() => _RekapPresensiScreenState();
}

class _RekapPresensiScreenState extends State<RekapPresensiScreen> {
  final EtholApiService _apiService = EtholApiService();
  late Future<dynamic> _presensiFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData({bool refresh = false}) {
    setState(() {
      _presensiFuture = _apiService.getPresensiRekap(
        widget.email,
        widget.password,
        refresh: refresh,
      );
    });
  }

  Future<void> _handleRefresh() async {
    _loadData(refresh: true);
    await _presensiFuture;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, _) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // --- TOP BAR ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _M3BouncyButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.0 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 18,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.getText('rekap_title', lang),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'PlusJakartaSans',
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            Text(
                              AppTranslations.getText('rekap_subtitle', lang),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'PlusJakartaSans',
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _M3BouncyButton(
                        onTap: _handleRefresh,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.0 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            size: 20,
                            color: Color(0xFF346EE0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- CONTENT ---
                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: _presensiFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF346EE0),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                lang == 'en'
                                    ? 'Fetching attendance data...'
                                    : 'Mengambil data presensi...',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'PlusJakartaSans',
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.cloud_off_rounded,
                                    size: 40,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  snapshot.error.toString().replaceAll('Exception: ', ''),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'PlusJakartaSans',
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                _M3BouncyButton(
                                  onTap: () => _loadData(refresh: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF346EE0),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      lang == 'en' ? 'Try Again' : 'Coba Lagi',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final dynamic res = snapshot.data;
                      final List<dynamic> presensiList =
                          (res is Map &&
                                  res['data'] is Map &&
                                  res['data']['presensi'] is List)
                              ? res['data']['presensi']
                              : [];

                      if (presensiList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_available_rounded,
                                size: 54,
                                color: isDark ? Colors.white30 : Colors.black26,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                AppTranslations.getText('rekap_empty', lang),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'PlusJakartaSans',
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Calculate Overall Stats
                      int totalAttended = 0;
                      int totalAbsent = 0;
                      int totalRecorded = 0;

                      for (final item in presensiList) {
                        final List<dynamic> weeks = item['week'] ?? [];
                        for (final w in weeks) {
                          if (w == true) {
                            totalAttended++;
                            totalRecorded++;
                          } else if (w == false) {
                            totalAbsent++;
                            totalRecorded++;
                          }
                        }
                      }

                      final double overallRate = totalRecorded > 0
                          ? (totalAttended / totalRecorded) * 100
                          : 100.0;

                      // Filter by search query
                      final filteredList = presensiList.where((item) {
                        final String matkul = (item['matkul'] ?? '').toString().toLowerCase();
                        return matkul.contains(_searchQuery.toLowerCase());
                      }).toList();

                      return RefreshIndicator(
                        color: Colors.white,
                        backgroundColor: const Color(0xFF346EE0),
                        onRefresh: _handleRefresh,
                        child: ListView(
                          physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          children: [
                            // --- STATS HERO CARD ---
                            _buildStatsHero(
                              isDark: isDark,
                              textColor: textColor,
                              lang: lang,
                              totalMatkul: presensiList.length,
                              attendedCount: totalAttended,
                              absentCount: totalAbsent,
                              totalRecorded: totalRecorded,
                              rate: overallRate,
                            ),

                            const SizedBox(height: 20),

                            // --- SEARCH BAR ---
                            Container(
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(isDark ? 0.2 : 0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) {
                                  setState(() {
                                    _searchQuery = val;
                                  });
                                },
                                style: TextStyle(
                                  color: textColor,
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: AppTranslations.getText(
                                    'rekap_search_placeholder',
                                    lang,
                                  ),
                                  hintStyle: TextStyle(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                    fontSize: 13,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search_rounded,
                                    size: 20,
                                    color: isDark ? Colors.white54 : Colors.black45,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear_rounded, size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {
                                              _searchQuery = '';
                                            });
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // --- SECTION TITLE ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${AppTranslations.getText('rekap_total_matkul', lang)} (${filteredList.length})",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'PlusJakartaSans',
                                    color: textColor,
                                  ),
                                ),
                                _buildLegend(isDark: isDark, lang: lang),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // --- LIST OF COURSES ---
                            if (filteredList.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 36),
                                child: Center(
                                  child: Text(
                                    lang == 'en'
                                        ? 'No matching course found'
                                        : 'Tidak ada mata kuliah yang cocok',
                                    style: TextStyle(
                                      color: isDark ? Colors.white38 : Colors.black38,
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...filteredList.map((item) {
                                return _buildCourseAttendanceCard(
                                  courseItem: item,
                                  isDark: isDark,
                                  cardColor: cardColor,
                                  textColor: textColor,
                                  lang: lang,
                                );
                              }),

                            const SizedBox(height: 24),
                          ],
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

  // --- STATS HERO CARD (REDESIGNED) ---
  Widget _buildStatsHero({
    required bool isDark,
    required Color? textColor,
    required String lang,
    required int totalMatkul,
    required int attendedCount,
    required int absentCount,
    required int totalRecorded,
    required double rate,
  }) {
    final bool hasData = totalRecorded > 0;

    Color statusColor = const Color(0xFF10B981);
    String statusLabel = AppTranslations.getText('rekap_safe', lang);
    String mainDisplay = "${rate.toStringAsFixed(rate % 1 == 0 ? 0 : 1)}%";

    if (!hasData) {
      statusColor = const Color(0xFF38BDF8); // Sky blue
      statusLabel = lang == 'en' ? 'In Progress' : 'Sedang Berjalan';
      mainDisplay = "100%";
    } else if (rate < 75) {
      statusColor = const Color(0xFFEF4444);
      statusLabel = AppTranslations.getText('rekap_danger', lang);
    } else if (rate < 85) {
      statusColor = const Color(0xFFF59E0B);
      statusLabel = AppTranslations.getText('rekap_warning', lang);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF1D4ED8), const Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF2563EB))
                .withOpacity(0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppTranslations.getText('rekap_avg_attendance', lang),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'PlusJakartaSans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        mainDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'PlusJakartaSans',
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: statusColor, width: 1.2),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor == const Color(0xFF10B981)
                                ? const Color(0xFF6EE7B7)
                                : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),

          // 3 Metric Badges
          Row(
            children: [
              _buildMiniMetric(
                label: AppTranslations.getText('rekap_total_matkul', lang),
                value: "$totalMatkul",
                icon: Icons.menu_book_rounded,
              ),
              _buildMiniMetric(
                label: AppTranslations.getText('rekap_hadir', lang),
                value: "$attendedCount",
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF6EE7B7),
              ),
              _buildMiniMetric(
                label: AppTranslations.getText('rekap_alpha', lang),
                value: "$absentCount",
                icon: Icons.cancel_rounded,
                iconColor: const Color(0xFFFCA5A5),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required IconData icon,
    Color iconColor = Colors.white70,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PlusJakartaSans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- LEGEND INDICATOR ---
  Widget _buildLegend({required bool isDark, required String lang}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLegendDot(
          color: const Color(0xFF10B981),
          label: AppTranslations.getText('rekap_hadir', lang),
          isDark: isDark,
        ),
        const SizedBox(width: 8),
        _buildLegendDot(
          color: const Color(0xFFEF4444),
          label: AppTranslations.getText('rekap_alpha', lang),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLegendDot({
    required Color color,
    required String label,
    required bool isDark,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white54 : Colors.black45,
            fontWeight: FontWeight.w600,
            fontFamily: 'PlusJakartaSans',
          ),
        ),
      ],
    );
  }

  // --- COURSE ATTENDANCE CARD (REDESIGNED) ---
  Widget _buildCourseAttendanceCard({
    required dynamic courseItem,
    required bool isDark,
    required Color cardColor,
    required Color? textColor,
    required String lang,
  }) {
    final String matkul = courseItem['matkul'] ?? '-';
    final List<dynamic> weeks = courseItem['week'] ?? [];

    int attended = 0;
    int absent = 0;
    int totalLogged = 0;

    for (final w in weeks) {
      if (w == true) {
        attended++;
        totalLogged++;
      } else if (w == false) {
        absent++;
        totalLogged++;
      }
    }

    final bool hasActivity = totalLogged > 0;
    final double courseRate = hasActivity ? (attended / totalLogged) * 100 : 100.0;

    Color badgeColor = const Color(0xFF10B981);
    if (!hasActivity) {
      badgeColor = const Color(0xFF38BDF8);
    } else if (courseRate < 75) {
      badgeColor = const Color(0xFFEF4444);
    } else if (courseRate < 85) {
      badgeColor = const Color(0xFFF59E0B);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(isDark ? 0.16 : 0.09),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(isDark ? 0.18 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: 18,
                  color: badgeColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      matkul,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlusJakartaSans',
                        color: textColor,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      hasActivity
                          ? "$attended ${AppTranslations.getText('rekap_hadir', lang)} • $absent ${AppTranslations.getText('rekap_alpha', lang)} ($totalLogged/16 ${AppTranslations.getText('rekap_week', lang)})"
                          : (lang == 'en'
                              ? '16 Sessions scheduled'
                              : '16 Pertemuan terjadwal'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PlusJakartaSans',
                        color: isDark ? Colors.white54 : Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(isDark ? 0.18 : 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: badgeColor.withOpacity(0.35),
                    width: 1,
                  ),
                ),
                child: Text(
                  hasActivity ? "${courseRate.toStringAsFixed(0)}%" : "16 Mg",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'PlusJakartaSans',
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 16-Week Compact Segment Track
          _buildWeeklyMatrix(weeks: weeks, isDark: isDark, lang: lang),
        ],
      ),
    );
  }

  Widget _buildWeeklyMatrix({
    required List<dynamic> weeks,
    required bool isDark,
    required String lang,
  }) {
    const int totalWeeks = 16;

    return LayoutBuilder(
      builder: (context, constraints) {
        const int cols = 8;
        const double spacing = 6.0;
        final double itemWidth = (constraints.maxWidth - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: List.generate(totalWeeks, (index) {
            final dynamic weekStatus = index < weeks.length ? weeks[index] : null;

            Color bgColor;
            Color borderColor;
            Color textLabelColor = isDark ? Colors.white38 : Colors.black38;
            Widget statusIcon;

            if (weekStatus == true) {
              bgColor = const Color(0xFF10B981).withOpacity(isDark ? 0.22 : 0.14);
              borderColor = const Color(0xFF10B981).withOpacity(0.45);
              textLabelColor = const Color(0xFF10B981);
              statusIcon = const Icon(
                Icons.check_rounded,
                size: 11,
                color: Color(0xFF10B981),
              );
            } else if (weekStatus == false) {
              bgColor = const Color(0xFFEF4444).withOpacity(isDark ? 0.22 : 0.14);
              borderColor = const Color(0xFFEF4444).withOpacity(0.45);
              textLabelColor = const Color(0xFFEF4444);
              statusIcon = const Icon(
                Icons.close_rounded,
                size: 11,
                color: Color(0xFFEF4444),
              );
            } else {
              bgColor = isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.withOpacity(0.08);
              borderColor = Colors.grey.withOpacity(isDark ? 0.12 : 0.1);
              statusIcon = Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  shape: BoxShape.circle,
                ),
              );
            }

            return Tooltip(
              message: "${AppTranslations.getText('rekap_week', lang)} ${index + 1}: ${weekStatus == true ? AppTranslations.getText('rekap_hadir', lang) : (weekStatus == false ? AppTranslations.getText('rekap_alpha', lang) : AppTranslations.getText('rekap_upcoming', lang))}",
              child: Container(
                width: itemWidth,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${index + 1}",
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: textLabelColor,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                    const SizedBox(height: 2),
                    statusIcon,
                  ],
                ),
              ),
            );
          }),
        );
      },
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

class _M3BouncyButtonState extends State<_M3BouncyButton>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.05,
    )..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}
