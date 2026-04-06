import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/translation_screen.dart';

class IpkCalculatorScreen extends StatefulWidget {
  const IpkCalculatorScreen({super.key});

  @override
  State<IpkCalculatorScreen> createState() => _IpkCalculatorScreenState();
}

class _CourseInput {
  String name = '';
  double sks = 2.0;
  double point = 4.0;
  String gradeLabel = 'A';
}

class _SemesterInput {
  int semesterNumber;
  List<_CourseInput> courses;

  _SemesterInput({required this.semesterNumber, required this.courses});
}

class _IpkCalculatorScreenState extends State<IpkCalculatorScreen> {
  final List<_SemesterInput> _semesters = [
    _SemesterInput(semesterNumber: 1, courses: [_CourseInput()]),
  ];

  double _prevIpk = 0.0;
  int _prevTotalSks = 0;

  // Controller khusus buat IPK Terakhir biar bisa auto-format
  final TextEditingController _prevIpkController = TextEditingController();

  final Map<String, double> _gradePoints = {
    'A': 4.0,
    'AB': 3.5,
    'B': 3.0,
    'BC': 2.5,
    'C': 2.0,
    'D': 1.0,
    'E': 0.0,
  };

  @override
  void initState() {
    super.initState();
    // Pasang listener biar tiap ngetik langsung di-format
    _prevIpkController.addListener(_formatPrevIpk);
  }

  @override
  void dispose() {
    _prevIpkController.dispose();
    super.dispose();
  }

  // --- LOGIKA AUTO FORMAT 2.34 ---
  void _formatPrevIpk() {
    // 1. Ambil cuma angka doang dari inputan
    String text = _prevIpkController.text.replaceAll(RegExp(r'[^\d]'), '');

    if (text.isEmpty) {
      if (_prevIpk != 0.0) setState(() => _prevIpk = 0.0);
      return;
    }

    // 2. Ubah misal "234" -> 2.34
    double value = double.parse(text) / 100;

    // 3. Validasi maksimal IPK itu 4.00
    if (value > 4.0) value = 4.0;

    String newText = value.toStringAsFixed(2);

    // 4. Update nilai di field kalau beda
    if (_prevIpkController.text != newText) {
      _prevIpkController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: newText.length,
        ), // Taruh kursor di ujung
      );
    }

    // 5. Update state buat dikalkulasi
    setState(() {
      _prevIpk = value;
    });
  }

  double _calculateIps(_SemesterInput sem) {
    double totalPoint = 0;
    double totalSks = 0;
    for (var c in sem.courses) {
      totalPoint += (c.point * c.sks);
      totalSks += c.sks;
    }
    return totalSks == 0 ? 0 : totalPoint / totalSks;
  }

  int _calculateTotalSks() {
    int totalSks = _prevTotalSks;
    for (var sem in _semesters) {
      for (var c in sem.courses) {
        totalSks += c.sks.toInt();
      }
    }
    return totalSks;
  }

  double _calculateIpk() {
    double currentTotalPoint = 0;
    double currentTotalSks = 0;

    for (var sem in _semesters) {
      for (var c in sem.courses) {
        currentTotalPoint += (c.point * c.sks);
        currentTotalSks += c.sks;
      }
    }

    double prevTotalPoint = _prevIpk * _prevTotalSks;
    double cumulativePoint = currentTotalPoint + prevTotalPoint;
    double cumulativeSks = currentTotalSks + _prevTotalSks;

    return cumulativeSks == 0 ? 0 : cumulativePoint / cumulativeSks;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final accentColor = const Color(0xFFF59E0B);

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
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
                        AppTranslations.getText('menu_ipk', lang),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- RESULT CARD DENGAN ANIMASI ROLLING ANGKA ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF346EE0), Color(0xFF6366F1)],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF346EE0).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAnimatedResultItem(
                          "Total SKS",
                          _calculateTotalSks()
                              .toDouble(), // Jadi double biar bisa di-tween
                          Colors.white,
                          isInteger: true,
                        ),
                        Container(width: 1, height: 40, color: Colors.white24),
                        _buildAnimatedResultItem(
                          "IPK",
                          _calculateIpk(),
                          Colors.white,
                          isInteger: false,
                        ),
                      ],
                    ),
                  ),
                ),

                // --- INPUT LIST ---
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 16),

                      // Looping Data Semester (Animasi Pindah Layout otomatis bawaan Flutter)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        child: Column(
                          children: _semesters
                              .asMap()
                              .entries
                              .map(
                                (entry) => _buildSemesterSection(
                                  entry.key,
                                  cardColor,
                                  textColor!,
                                  isDark,
                                  lang,
                                  accentColor,
                                ),
                              )
                              .toList(),
                        ),
                      ),

                      // Tombol Tambah Semester Bouncy
                      _BouncyWrapper(
                        onTap: () => setState(() {
                          int nextSem = _semesters.isNotEmpty
                              ? _semesters.last.semesterNumber + 1
                              : 1;
                          _semesters.add(
                            _SemesterInput(
                              semesterNumber: nextSem,
                              courses: [_CourseInput()],
                            ),
                          );
                        }),
                        child: _M3Button(
                          label: lang == 'en'
                              ? "Add Semester"
                              : "Tambah Semester",
                          icon: Icons.add_to_photos_rounded,
                          color: accentColor,
                        ),
                      ),

                      const SizedBox(height: 40),
                      Text(
                        lang == 'en'
                            ? "Previous Cumulative Data"
                            : "Data Kumulatif Sebelumnya",
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPrevDataInput(cardColor, textColor!, isDark),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSemesterSection(
    int semIndex,
    Color cardColor,
    Color textColor,
    bool isDark,
    String lang,
    Color accentColor,
  ) {
    final semester = _semesters[semIndex];
    final ips = _calculateIps(semester);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.05 : 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Semester ",
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: textColor,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: semester.semesterNumber,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: textColor,
                        size: 20,
                      ),
                      items: List.generate(14, (index) => index + 1)
                          .map(
                            (val) => DropdownMenuItem(
                              value: val,
                              child: Text(
                                val.toString(),
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: textColor,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setState(() => semester.semesterNumber = v!),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Muter animasi buat IPS per semester juga
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: ips),
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                    builder: (context, val, child) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "IPS: ${val.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  _BouncyWrapper(
                    onTap: () => setState(() => _semesters.removeAt(semIndex)),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Animasi list matkul
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            child: Column(
              children: semester.courses
                  .asMap()
                  .entries
                  .map(
                    (cEntry) => _buildCourseRow(
                      semIndex,
                      cEntry.key,
                      cardColor,
                      textColor,
                      isDark,
                    ),
                  )
                  .toList(),
            ),
          ),

          // Tombol Tambah Matkul (Bouncy)
          _BouncyWrapper(
            onTap: () => setState(() => semester.courses.add(_CourseInput())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF374151).withOpacity(0.5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: accentColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    lang == 'en' ? "Add Course" : "Tambah Matkul",
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseRow(
    int semIndex,
    int courseIndex,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    final course = _semesters[semIndex].courses[courseIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(isDark ? 0.05 : 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: textColor,
            ),
            decoration: InputDecoration(
              hintText: "Nama Matkul (Opsional)",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (v) => course.name = v,
          ),
          const SizedBox(height: 12),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SKS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<double>(
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        value: course.sks,
                        items: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(
                                  "${s.toInt()} SKS",
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => course.sks = v!),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nilai",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.grey.shade400,
                          size: 18,
                        ),
                        value: course.gradeLabel,
                        items: _gradePoints.keys
                            .map(
                              (g) => DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    fontFamily: 'PlusJakartaSans',
                                    fontWeight: FontWeight.w900,
                                    color: textColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() {
                          course.gradeLabel = v!;
                          course.point = _gradePoints[v]!;
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              _BouncyWrapper(
                onTap: () => setState(() {
                  if (_semesters[semIndex].courses.length > 1) {
                    _semesters[semIndex].courses.removeAt(courseIndex);
                  }
                }),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.remove_circle_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Animasi Rolling Angka
  Widget _buildAnimatedResultItem(
    String label,
    double endValue,
    Color valueColor, {
    required bool isInteger,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'PlusJakartaSans',
            color: Colors.white70,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: endValue),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          builder: (context, val, child) {
            return Text(
              isInteger ? val.toInt().toString() : val.toStringAsFixed(2),
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                color: valueColor,
                fontWeight: FontWeight.w900,
                fontSize: 32,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrevDataInput(Color cardColor, Color textColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(isDark ? 0.05 : 0.2)),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total SKS Lalu",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                  ),
                  onChanged: (v) =>
                      setState(() => _prevTotalSks = int.tryParse(v) ?? 0),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 30, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "IPK Terakhir",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                TextField(
                  controller:
                      _prevIpkController, // 👇 Controller Auto Format dipasang disini
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: Colors.grey),
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

// --- REUSABLE WIDGETS ---

// Animasi Bouncy Universal
class _BouncyWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BouncyWrapper({required this.child, required this.onTap});

  @override
  State<_BouncyWrapper> createState() => _BouncyWrapperState();
}

class _BouncyWrapperState extends State<_BouncyWrapper> {
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
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

class _BouncyIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _BouncyIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _BouncyWrapper(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _M3Button extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _M3Button({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
