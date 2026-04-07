import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';
import 'notif_screen.dart';
import '../screens/quicks/portal_screen.dart';
import '../screens/quicks/catatan_screen.dart';
import '../screens/quicks/ipk_calculator_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String email;
  final String password;

  const HomeScreen({
    super.key,
    required this.profileData,
    required this.email,
    required this.password,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EtholApiService _apiService = EtholApiService();
  late Future<dynamic> _jadwalFuture;
  late Future<dynamic> _tugasFuture;
  String _selectedFilter = 'Undone';

  @override
  void initState() {
    super.initState();
    _jadwalFuture = _apiService.getJadwal(widget.email, widget.password);
    _tugasFuture = _apiService.getTugas(widget.email, widget.password);
  }

  Future<void> _refreshData() async {
    setState(() {
      _jadwalFuture = _apiService.getJadwal(widget.email, widget.password);
      _tugasFuture = _apiService.getTugas(widget.email, widget.password);
    });
    await Future.wait([_jadwalFuture, _tugasFuture]);
  }

  String _getSystemDay() {
    int weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return "Jum'at";
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  Future<void> _handlePresensi() async {
    // 👇 Tarik info bahasa saat ini 👇
    final String currentLang = languageNotifier.value;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeCap: StrokeCap.round,
        ),
      ),
    );

    try {
      final res = await _apiService.getAbsen(widget.email, widget.password);

      final now = DateTime.now();
      final submitTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      final bool isSuccess =
          res != null &&
          res['error'] == false &&
          res['data'] != null &&
          res['data']['matkul'] != null;

      String namaMatkul = '';
      if (res != null && res['data'] != null && res['data']['matkul'] != null) {
        namaMatkul = res['data']['matkul'];
      }

      _showStatusDialog(
        isSuccess: isSuccess,
        namaMatkul: namaMatkul,
        submitTime: submitTime,
        lang: currentLang, // 👈 Lempar bahasa ke pop-up
      );
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      final now = DateTime.now();
      final submitTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      _showStatusDialog(
        isSuccess: false,
        namaMatkul: '',
        submitTime: submitTime,
        lang: currentLang,
      );
    }
  }

  void _showStatusDialog({
    required bool isSuccess,
    required String namaMatkul,
    required String submitTime,
    required String lang, // 👈 Parameter baru buat translasi
  }) {
    showDialog(
      context: context,
      builder: (context) {
        // 👇 Cek apakah HP user lagi pakai Dark Mode 👇
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          // Background menyesuaikan tema
          backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(isDark ? 0.1 : 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  // 👇 Logika 2 Bahasa buat Judul 👇
                  isSuccess
                      ? (lang == 'en'
                            ? 'Attendance Successful!'
                            : 'Berhasil Absen!')
                      : (lang == 'en' ? 'All Good!' : 'Aman Sentosa!'),
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? Colors.white
                        : Colors.black87, // Warna teks dinamis
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  isSuccess
                      ? (lang == 'en'
                            ? 'Successfully recorded attendance for $namaMatkul at $submitTime.'
                            : 'Berhasil Absensi untuk Matkul $namaMatkul pada pukul $submitTime WIB.')
                      : (lang == 'en'
                            ? 'You have already attended, or the lecturer has not opened the attendance yet.'
                            : 'Kamu sudah melakukan presensi, atau dosen belum membuka absensi.'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    height: 1.4,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // Warna tombol ngikutin tema
                      backgroundColor: isDark
                          ? const Color(0xFF2C2C2E)
                          : Colors.grey.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      lang == 'en' ? 'Close' : 'Tutup',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    final rawProfile = widget.profileData['data'];
    final Map<String, dynamic> data =
        (rawProfile is List && rawProfile.isNotEmpty)
        ? Map<String, dynamic>.from(rawProfile.first)
        : (rawProfile is Map ? Map<String, dynamic>.from(rawProfile) : {});

    final String fullName = data['nama'] ?? 'User';
    final String firstName = fullName.split(' ')[0];
    final String systemDay = _getSystemDay();

    // 👇 BUNGKUS SELURUH BODY 👇
    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            // 👇 BUNGKUS DENGAN REFRESH INDICATOR 👇
            child: RefreshIndicator(
              color: Colors.white,
              backgroundColor: const Color(0xFF346EE0),
              strokeWidth: 3.0,
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                // 👇 UBAH PHYSICS BIAR SELALU BISA DITARIK 👇
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // --- HEADER ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${AppTranslations.getText('hi_greeting', lang)}, $firstName", // 👈 DINAMIS
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            fontFamily: 'PlusJakartaSans',
                            letterSpacing: -1,
                          ),
                        ),
                        M3BouncyButton(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => NotifScreen(
                                email: widget.email,
                                password: widget.password,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    isDark ? 0.0 : 0.04,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: textColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildDigitalIDCard(
                      fullName,
                      data['nrp'] ?? '-',
                      data['semester']?.toString() ?? '-',
                      lang,
                    ),
                    const SizedBox(height: 32),

                    // --- QUICK MENU ---
                    Text(
                      AppTranslations.getText('quick_menu', lang),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickMenuItem(
                          icon: Icons.fingerprint_rounded,
                          label: AppTranslations.getText('menu_absen', lang),
                          bgColor: isDark
                              ? const Color(0xFF059669).withOpacity(0.15)
                              : const Color(0xFFD1FAE5),
                          iconColor: isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF059669),
                          textColor: textColor,
                          onTap: _handlePresensi,
                        ),
                        _buildQuickMenuItem(
                          icon: Icons.link_rounded,
                          label: AppTranslations.getText(
                            'menu_links',
                            lang,
                          ), // 👈 DINAMIS
                          bgColor: isDark
                              ? const Color(0xFFD97706).withOpacity(0.15)
                              : const Color(0xFFFEF3C7),
                          iconColor: isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFD97706),
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PortalScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickMenuItem(
                          icon: Icons.library_books_rounded,
                          label: AppTranslations.getText(
                            'menu_notes',
                            lang,
                          ), // 👈 DINAMIS
                          bgColor: isDark
                              ? const Color(0xFF2563EB).withOpacity(0.15)
                              : const Color(0xFFDBEAFE),
                          iconColor: isDark
                              ? const Color(0xFF60A5FA)
                              : const Color(0xFF2563EB),
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CatatanScreen(),
                              ),
                            );
                          },
                        ),
                        _buildQuickMenuItem(
                          icon: Icons.calculate_rounded,
                          label: AppTranslations.getText('menu_ipk', lang),
                          bgColor: isDark
                              ? const Color(0xFF7C3AED).withOpacity(0.15)
                              : const Color(0xFFEDE9FE),
                          iconColor: isDark
                              ? const Color(0xFFA78BFA)
                              : const Color(0xFF7C3AED),
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const IpkCalculatorScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 36),
                    Text(
                      AppTranslations.getText('schedule_today', lang),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailedJadwalHorizontal(
                      systemDay,
                      isDark,
                      cardColor,
                      textColor,
                      lang,
                    ),

                    const SizedBox(height: 36),
                    Text(
                      AppTranslations.getText('task_list', lang),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTugasFilters(isDark, textColor, lang),
                    const SizedBox(height: 16),
                    _buildDetailedTugasList(isDark, cardColor, textColor, lang),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER ---
  Widget _buildDigitalIDCard(
    String name,
    String nrp,
    String semester,
    String lang,
  ) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF346EE0),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF346EE0).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // --- BACKGROUND PATTERN (Positioned Right untuk constraints eksplisit) ---
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 150, // width pattern eksplisit
              child: Opacity(
                opacity: 0.4,
                child: Image.asset(
                  'assets/images/pattern.png',
                  fit: BoxFit
                      .cover, // pattern_width + overall_padded_stack_padding = constraints_OK
                  color: const Color(0xFF346EE0),
                  colorBlendMode: BlendMode.lighten,
                ),
              ),
            ),

            // --- KONTEN KARTU (Non-positioned child filling Stack content padded card bounds) ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo_pens.png',
                    height: 40,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.school, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 16),

                  // 👇 INI YANG DIPERBAIKI (Hapus Redundant nested column padding & pass explicit constraints) 👇
                  Align(
                    alignment: Alignment
                        .centerLeft, // constraints are now properly passed with softWrap
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 120.0,
                      ), // constraints OK with pattern bounds
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines:
                                2, // kepanjangan dipaksa wrap ke bawah di multiple words kepanjangan
                            overflow: TextOverflow.ellipsis,
                            softWrap: true, // 👇 DIPAKSA KEBETULAN 👇
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.2, //Constraints OK
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            nrp,
                            maxLines:
                                1, //constraints are met so wraps to multiple words kepanjangan OK
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),

                  // --- BAGIAN BAWAH (Semester & Status) ---
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.getText('id_semester', lang),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          Text(
                            semester,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 40),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTranslations.getText('id_status', lang),
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                          Text(
                            AppTranslations.getText('id_active', lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required Color? textColor,
    VoidCallback? onTap,
  }) {
    return M3BouncyButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedJadwalHorizontal(
    String systemDay,
    bool isDark,
    Color cardColor,
    Color? textColor,
    String lang,
  ) {
    return FutureBuilder<dynamic>(
      future: _jadwalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 110,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            ),
          );
        }
        final List<dynamic> all = snapshot.data?['data'] ?? [];
        final today = all
            .where(
              (item) =>
                  (item['day']?.toString().toLowerCase() ?? '') ==
                  systemDay.toLowerCase(),
            )
            .toList();

        today.sort((a, b) {
          String startA = a['start']?.toString() ?? '23:59';
          String startB = b['start']?.toString() ?? '23:59';
          return startA.compareTo(startB);
        });

        if (today.isEmpty) {
          return Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E3A8A).withOpacity(0.1)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E3A8A).withOpacity(0.5)
                    : const Color(0xFFBFDBFE),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              AppTranslations.getText('no_class', lang),
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF60A5FA)
                    : const Color(0xFF2563EB),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: today
                .map(
                  (item) => Container(
                    width: 220,
                    height: 110,
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.0 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "${item['start']} - ${item['end']}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF60A5FA)
                                : const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['matkul'] ?? 'Mata Kuliah',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (item['room'] == null ||
                                  item['room'].toString().toLowerCase() ==
                                      'null' ||
                                  item['room'] == 'TBA')
                              ? "TBA"
                              : item['room'].toString(),
                          style: TextStyle(
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildTugasFilters(bool isDark, Color? textColor, String lang) {
    bool isDone = _selectedFilter == 'Done';
    return Container(
      width: 210,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubicEmphasized,
            alignment: isDone ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 105,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF346EE0),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'Done'),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: isDone ? Colors.white : textColor,
                        fontSize: 13,
                        fontWeight: isDone ? FontWeight.bold : FontWeight.w600,
                      ),
                      child: Text(AppTranslations.getText('task_done', lang)),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = 'Undone'),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        color: !isDone ? Colors.white : textColor,
                        fontSize: 13,
                        fontWeight: !isDone ? FontWeight.bold : FontWeight.w600,
                      ),
                      child: Text(AppTranslations.getText('task_undone', lang)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedTugasList(
    bool isDark,
    Color cardColor,
    Color? textColor,
    String lang,
  ) {
    return FutureBuilder<dynamic>(
      future: _tugasFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            height: 150,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
            ),
          );
        }
        final List<dynamic> all = snapshot.data?['data'] ?? [];
        final isDone = _selectedFilter == 'Done';
        final filtered = all
            .where((t) => (t['submited'] == true) == isDone)
            .take(3)
            .toList();

        if (filtered.isEmpty) {
          return Container(
            width: double.infinity,
            height: 110,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF064E3B).withOpacity(0.1)
                  : const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF064E3B).withOpacity(0.5)
                    : const Color(0xFFA7F3D0),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              AppTranslations.getText('task_all_done', lang),
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF34D399)
                    : const Color(0xFF059669),
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        return Column(
          children: filtered
              .map(
                (item) => Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title'] ?? 'Judul Tugas',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['matkul'] ?? 'Mata Kuliah',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.black87,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Deadline: ${item['deadline']}",
                        style: TextStyle(
                          color: isDone
                              ? (isDark ? Colors.greenAccent : Colors.green)
                              : (isDark ? Colors.redAccent : Colors.red),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildLinkTile(
    String title,
    IconData icon,
    Color color,
    bool isDark,
    Color? textColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: textColor,
          ),
        ),
        trailing: Icon(
          Icons.open_in_new_rounded,
          size: 16,
          color: isDark ? Colors.grey.shade600 : Colors.grey,
        ),
        onTap: () => Navigator.pop(context),
      ),
    );
  }
}

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
        scale: _isPressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
