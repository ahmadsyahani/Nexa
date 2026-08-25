import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../main.dart';
import '../services/translation_screen.dart';
import 'notif_screen.dart';
import '../screens/quicks/portal_screen.dart';
import '../screens/quicks/catatan_screen.dart';
import '../screens/quicks/rekap_presensi_screen.dart';

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

    debugPrint("==================================================");
    debugPrint("💳 [HomeScreen] DATA PROFILE UNTUK DIGITAL CARD:");
    debugPrint("  - Nama         : ${data['nama']}");
    debugPrint("  - NRP          : ${data['nrp']}");
    debugPrint("  - Semester     : ${data['semester']}");
    debugPrint("  - Tahun Aktif  : ${data['tahun_aktif']}");
    debugPrint("  - Tahun Ajaran : ${data['tahun_ajaran']}");
    debugPrint("==================================================");

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
                      name: fullName,
                      nrp: data['nrp']?.toString() ?? '-',
                      tahunAjaran: data['tahun_ajaran']?.toString() ?? '-',
                      lang: lang,
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
                      children: [
                        Expanded(
                          child: _buildQuickMenuItem(
                            icon: Icons.fingerprint_rounded,
                            label: AppTranslations.getText('menu_absen', lang),
                            accentColor: const Color(0xFF10B981),
                            isDark: isDark,
                            textColor: textColor,
                            onTap: _handlePresensi,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickMenuItem(
                            icon: Icons.fact_check_rounded,
                            label: AppTranslations.getText('menu_rekap', lang),
                            accentColor: const Color(0xFF8B5CF6),
                            isDark: isDark,
                            textColor: textColor,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RekapPresensiScreen(
                                    email: widget.email,
                                    password: widget.password,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickMenuItem(
                            icon: Icons.link_rounded,
                            label: AppTranslations.getText('menu_links', lang),
                            accentColor: const Color(0xFFF59E0B),
                            isDark: isDark,
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
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildQuickMenuItem(
                            icon: Icons.library_books_rounded,
                            label: AppTranslations.getText('menu_notes', lang),
                            accentColor: const Color(0xFF3B82F6),
                            isDark: isDark,
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

  // --- WIDGET HELPER: DIGITAL ID CARD (API DRIVEN) ---
  Widget _buildDigitalIDCard({
    required String name,
    required String nrp,
    required String tahunAjaran,
    required String lang,
  }) {
    return Container(
      width: double.infinity,
      height: 195,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A), // Slate Navy
            Color(0xFF1E3A8A), // Royal Blue
            Color(0xFF2563EB), // Cobalt
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.32),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            // Geometric Pattern Accent
            Positioned(
              right: -10,
              top: -10,
              bottom: -10,
              width: 160,
              child: Opacity(
                opacity: 0.22,
                child: Image.asset(
                  'assets/images/pattern.png',
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
              ),
            ),

            // Light reflection sheen
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.12),
                      Colors.transparent,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

            // Card Inner Layout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // TOP ROW: Logo & Text
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo_pens.png',
                        height: 30,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "PENS STUDENT CARD",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          fontFamily: 'PlusJakartaSans',
                        ),
                      ),
                    ],
                  ),

                  // MIDDLE ROW: Name & NRP
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'PlusJakartaSans',
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          nrp,
                          style: const TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'PlusJakartaSans',
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // BOTTOM ROW: Dynamic Tahun Ajaran Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.school_outlined, color: Colors.white70, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              "TA $tahunAjaran",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                fontFamily: 'PlusJakartaSans',
                              ),
                            ),
                          ],
                        ),
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
    required Color accentColor,
    required bool isDark,
    required Color? textColor,
    VoidCallback? onTap,
  }) {
    return M3BouncyButton(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDark
                ? accentColor.withOpacity(0.09)
                : accentColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(isDark ? 0.22 : 0.16),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(isDark ? 0.0 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: accentColor,
                size: 24,
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'PlusJakartaSans',
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
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
