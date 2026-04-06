import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';

class AbsenScreen extends StatefulWidget {
  final String email;
  final String password;

  const AbsenScreen({super.key, required this.email, required this.password});

  @override
  State<AbsenScreen> createState() => _AbsenScreenState();
}

class _AbsenScreenState extends State<AbsenScreen> {
  final EtholApiService _apiService = EtholApiService();
  late Future<dynamic> _historyFuture;

  // State internal tetap pake 'Semua' biar kodingan filter lu nggak pecah
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _historyFuture = _apiService.getNotif(widget.email, widget.password);
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
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // --- HEADER ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Text(
                      AppTranslations.getText(
                        'absen_header',
                        lang,
                      ), // 👈 DINAMIS
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -0.5,
                        fontFamily: 'PlusJakartaSans',
                      ),
                    ),
                  ),
                ),

                // --- LIST RIWAYAT & FILTER DROPDOWN ---
                FutureBuilder<dynamic>(
                  future: _historyFuture,
                  builder: (context, snapshot) {
                    bool isHistoryLoading =
                        snapshot.connectionState == ConnectionState.waiting;

                    final List<dynamic> allNotifs =
                        snapshot.data?['data'] ?? [];
                    final List<dynamic> presensiHistory = allNotifs
                        .where((n) => n['notif_type'] == 'PRESENSI')
                        .toList();

                    // 1. Ekstrak nama matkul unik buat menu Dropdown
                    List<String> filterOptions = ['Semua'];
                    if (!isHistoryLoading) {
                      for (var h in presensiHistory) {
                        final String matkulName = h['keterangan']
                            .toString()
                            .replaceAll(
                              "Dosen telah melakukan presensi untuk matakuliah ",
                              "",
                            )
                            .trim();
                        if (!filterOptions.contains(matkulName)) {
                          filterOptions.add(matkulName);
                        }
                      }
                    }

                    if (!filterOptions.contains(_selectedFilter)) {
                      _selectedFilter = 'Semua';
                    }

                    final filteredHistory = _selectedFilter == 'Semua'
                        ? presensiHistory
                        : presensiHistory.where((h) {
                            final String matkulName = h['keterangan']
                                .toString()
                                .replaceAll(
                                  "Dosen telah melakukan presensi untuk matakuliah ",
                                  "",
                                )
                                .trim();
                            return matkulName == _selectedFilter;
                          }).toList();

                    return SliverMainAxisGroup(
                      slivers: [
                        // --- DROPDOWN FILTER SECTION ---
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isHistoryLoading &&
                                    filterOptions.length > 1)
                                  Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(
                                            isDark ? 0.0 : 0.02,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        value: _selectedFilter,
                                        dropdownColor: cardColor,
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: isDark
                                              ? Colors.grey
                                              : Colors.grey.shade400,
                                        ),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: textColor,
                                          fontFamily: 'PlusJakartaSans',
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        items: filterOptions.map((
                                          String value,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              // 👇 Tampilkan "All" jika nilai value-nya "Semua" 👇
                                              value == 'Semua'
                                                  ? AppTranslations.getText(
                                                      'filter_all',
                                                      lang,
                                                    )
                                                  : value,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            setState(
                                              () => _selectedFilter = newValue,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // --- DAFTAR RIWAYAT ---
                        if (isHistoryLoading)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: isDark
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                            ),
                          )
                        else if (filteredHistory.isEmpty)
                          SliverToBoxAdapter(
                            child: _buildEmptyState(cardColor, isDark, lang),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final h = filteredHistory[index];
                                final String matkul = h['keterangan']
                                    .toString()
                                    .replaceAll(
                                      "Dosen telah melakukan presensi untuk matakuliah ",
                                      "",
                                    )
                                    .trim();

                                return _buildHistoryCard(
                                  matkul,
                                  h['time_since'],
                                  cardColor,
                                  textColor,
                                  isDark,
                                  lang,
                                );
                              }, childCount: filteredHistory.length),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryCard(
    String matkul,
    String? time,
    Color cardColor,
    Color? textColor,
    bool isDark,
    String lang,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF10B981).withOpacity(0.15)
                  : const Color(0xFFD1FAE5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF10B981),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  matkul,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: textColor,
                    fontFamily: 'PlusJakartaSans',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  // 👇 Terjemahkan "Baru saja" jika datanya null 👇
                  time ?? AppTranslations.getText('time_just_now', lang),
                  style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

  Widget _buildEmptyState(Color cardColor, bool isDark, String lang) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.getText('absen_empty', lang), // 👈 DINAMIS
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
