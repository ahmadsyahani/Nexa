import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';

class JadwalScreen extends StatefulWidget {
  final String email;
  final String password;

  const JadwalScreen({super.key, required this.email, required this.password});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  final EtholApiService _apiService = EtholApiService();
  late Future<dynamic> _jadwalFuture;

  @override
  void initState() {
    super.initState();
    _jadwalFuture = _apiService.getJadwal(widget.email, widget.password);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

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
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Text(
                    AppTranslations.getText('jadwal_title', lang), // 👈 DINAMIS
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                Expanded(
                  child: FutureBuilder<dynamic>(
                    future: _jadwalFuture,
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
                              'jadwal_error',
                              lang,
                            ), // 👈 DINAMIS
                            style: TextStyle(color: textColor),
                          ),
                        );
                      }

                      final rawData = snapshot.data?['data'];
                      List<dynamic> allData = [];
                      if (rawData is List) {
                        allData = List.from(rawData);
                      } else if (rawData is Map) {
                        allData = [rawData];
                      }

                      if (allData.isEmpty) {
                        return _buildEmptyState(textColor, lang);
                      }

                      allData.sort((a, b) {
                        String timeA = a['start']?.toString() ?? '24:00';
                        String timeB = b['start']?.toString() ?? '24:00';
                        return timeA.compareTo(timeB);
                      });

                      Map<String, List<dynamic>> groupedJadwal = {};
                      for (var item in allData) {
                        String hari = item['day'] ?? 'Lainnya';
                        if (!groupedJadwal.containsKey(hari)) {
                          groupedJadwal[hari] = [];
                        }
                        groupedJadwal[hari]!.add(item);
                      }

                      // Mapping logic buat hari (Key API : Key Kamus)
                      final List<Map<String, String>> urutanHari = [
                        {'api': 'Senin', 'key': 'day_senin'},
                        {'api': 'Selasa', 'key': 'day_selasa'},
                        {'api': 'Rabu', 'key': 'day_rabu'},
                        {'api': 'Kamis', 'key': 'day_kamis'},
                        {'api': "Jum'at", 'key': 'day_jumat'},
                        {'api': 'Sabtu', 'key': 'day_sabtu'},
                        {'api': 'Minggu', 'key': 'day_minggu'},
                      ];

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: urutanHari.length,
                        itemBuilder: (context, index) {
                          final dayMap = urutanHari[index];
                          final String apiDayName = dayMap['api']!;
                          final String translationKey = dayMap['key']!;

                          // Cari data berdasarkan nama hari Indo (API)
                          var matchingKey = groupedJadwal.keys.firstWhere(
                            (k) => k.toLowerCase() == apiDayName.toLowerCase(),
                            orElse: () => "",
                          );

                          if (matchingKey == "" ||
                              groupedJadwal[matchingKey]!.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 👇 Tampilkan nama hari sesuai bahasa pilihan 👇
                              _buildDayHeader(
                                AppTranslations.getText(translationKey, lang),
                                isDark,
                                textColor,
                              ),
                              ...groupedJadwal[matchingKey]!.map(
                                (item) => _buildJadwalCard(
                                  item,
                                  isDark,
                                  cardColor,
                                  textColor,
                                  lang,
                                ),
                              ),
                            ],
                          );
                        },
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

  Widget _buildDayHeader(String hari, bool isDark, Color? textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            hari,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJadwalCard(
    dynamic item,
    bool isDark,
    Color cardColor,
    Color? textColor,
    String lang,
  ) {
    final String rawRoom = item['room']?.toString() ?? '';
    final String displayRoom =
        (rawRoom.isEmpty || rawRoom.toUpperCase() == 'TBA')
        ? AppTranslations.getText('no_room', lang) // 👈 DINAMIS
        : rawRoom;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item['matkul'] ??
                      AppTranslations.getText(
                        'default_matkul',
                        lang,
                      ), // 👈 DINAMIS
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
              _buildRoomBadge(displayRoom, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTimeInfo(
                Icons.access_time_filled_rounded,
                "${item['start']} - ${item['end']}",
                isDark,
              ),
              const SizedBox(width: 20),
              _buildTimeInfo(
                Icons.person_rounded,
                item['dosen']?.toString().split(',')[0] ??
                    AppTranslations.getText(
                      'default_dosen',
                      lang,
                    ), // 👈 DINAMIS
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomBadge(String room, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF346EE0).withOpacity(0.15)
            : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        room,
        style: TextStyle(
          fontFamily: 'PlusJakartaSans',
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildTimeInfo(IconData icon, String text, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 12,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(Color? textColor, String lang) {
    return Center(
      child: Text(
        AppTranslations.getText('jadwal_empty', lang), // 👈 DINAMIS
        style: TextStyle(color: textColor),
      ),
    );
  }
}
