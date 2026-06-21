import 'package:flutter/material.dart';
import 'dart:async';
import '../../main.dart';
import '../../services/translation_screen.dart';
import '../../services/notification_service.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Timer Settings (in minutes)
  int _workDuration = 25;
  int _breakDuration = 5;

  // Timer State
  late int _remainingSeconds;
  bool _isRunning = false;
  bool _isWorkMode = true;
  Timer? _timer;
  DateTime? _endTime;

  // Stats
  int _totalFocusMinutes = 0;

  // Animation for pulsing glow
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _remainingSeconds = _workDuration * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _pulseController.dispose();
    NotificationService().cancelPomodoroNotification(999);
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _pulseController.repeat(reverse: true);

    _endTime = DateTime.now().add(Duration(seconds: _remainingSeconds));

    NotificationService().showPomodoroNotification(
      id: 999,
      title: _isWorkMode ? 'Sesi Fokus' : 'Waktu Istirahat',
      body: 'Sedang berjalan...',
      remainingSeconds: _remainingSeconds,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_endTime != null) {
        int newRemaining = _endTime!.difference(DateTime.now()).inSeconds;
        if (newRemaining > 0) {
          setState(() {
            _remainingSeconds = newRemaining;
          });
        } else {
          _timer?.cancel();
          _pulseController.stop();
          _pulseController.reset();

          setState(() {
            _isRunning = false;
            _endTime = null;
            if (_isWorkMode) {
              _totalFocusMinutes += _workDuration;
              _isWorkMode = false;
              _remainingSeconds = _breakDuration * 60;
            } else {
              _isWorkMode = true;
              _remainingSeconds = _workDuration * 60;
            }
          });
          NotificationService().cancelPomodoroNotification(999);
        }
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _endTime = null;
    });
    NotificationService().cancelPomodoroNotification(999);
  }

  void _resetTimer() {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();
    setState(() {
      _isRunning = false;
      _endTime = null;
      _remainingSeconds = (_isWorkMode ? _workDuration : _breakDuration) * 60;
    });
    NotificationService().cancelPomodoroNotification(999);
  }

  void _switchMode(bool isWork) {
    if (_isWorkMode == isWork) return;
    _pauseTimer();
    setState(() {
      _isWorkMode = isWork;
      _remainingSeconds = (_isWorkMode ? _workDuration : _breakDuration) * 60;
    });
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isRunning && _endTime != null) {
      int newRemaining = _endTime!.difference(DateTime.now()).inSeconds;
      setState(() {
        if (newRemaining > 0) {
          _remainingSeconds = newRemaining;
        } else {
          _remainingSeconds = 0;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    // Colors
    final Color primaryColor = _isWorkMode
        ? const Color(0xFFEF4444)
        : const Color(0xFF10B981);
    final Color gradientEnd = _isWorkMode
        ? const Color(0xFFB91C1C)
        : const Color(0xFF059669);

    return ValueListenableBuilder<String>(
      valueListenable: languageNotifier,
      builder: (context, lang, child) {
        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // --- HEADER ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _BouncyIconButton(
                        onTap: () => Navigator.pop(context),
                        icon: Icons.arrow_back_ios_new_rounded,
                      ),
                      Text(
                        AppTranslations.getText('menu_ipk', lang),
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                        ),
                      ),
                      _BouncyIconButton(
                        onTap: () => _showSettingsDialog(context, lang),
                        icon: Icons.settings_rounded,
                      ),
                    ],
                  ),
                ),

                // --- STATS ---
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          lang == 'en'
                              ? "Today's Focus: $_totalFocusMinutes min"
                              : "Fokus Hari Ini: $_totalFocusMinutes menit",
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // --- TOGGLE TABS ---
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 60),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchMode(true),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isWorkMode
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                AppTranslations.getText('pomodoro_work', lang),
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontWeight: FontWeight.bold,
                                  color: _isWorkMode
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchMode(false),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isWorkMode
                                  ? primaryColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(
                                AppTranslations.getText('pomodoro_break', lang),
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontWeight: FontWeight.bold,
                                  color: !_isWorkMode
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // --- TIMER CIRCLE ---
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isRunning ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [primaryColor, gradientEnd],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            if (_isRunning)
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.4),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _formatTime(_remainingSeconds),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 72,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 80),

                // --- CONTROLS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BouncyWrapper(
                      onTap: _resetTimer,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.refresh_rounded,
                          size: 28,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    _BouncyWrapper(
                      onTap: _isRunning ? _pauseTimer : _startTimer,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: textColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (textColor ?? Colors.black).withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 40,
                          color: bgColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    _BouncyWrapper(
                      onTap: () {}, // Future: Skip to next phase
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.skip_next_rounded,
                          size: 28,
                          color: Colors.grey.withValues(alpha: 0.3),
                        ), // Disabled looking
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context, String lang) {
    int tempWork = _workDuration;
    int tempBreak = _breakDuration;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final textColor = Theme.of(context).textTheme.bodyLarge?.color;

          return Container(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'en' ? "Timer Settings" : "Pengaturan Timer",
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 24),

                // Work Duration
                Text(
                  lang == 'en'
                      ? "Focus Duration (minutes)"
                      : "Durasi Fokus (menit)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Slider(
                  value: tempWork.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  activeColor: const Color(0xFFEF4444),
                  label: "$tempWork",
                  onChanged: (val) =>
                      setModalState(() => tempWork = val.toInt()),
                ),

                const SizedBox(height: 16),

                // Break Duration
                Text(
                  lang == 'en'
                      ? "Break Duration (minutes)"
                      : "Durasi Istirahat (menit)",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Slider(
                  value: tempBreak.toDouble(),
                  min: 1,
                  max: 30,
                  divisions: 29,
                  activeColor: const Color(0xFF10B981),
                  label: "$tempBreak",
                  onChanged: (val) =>
                      setModalState(() => tempBreak = val.toInt()),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _workDuration = tempWork;
                        _breakDuration = tempBreak;
                        if (!_isRunning) {
                          _remainingSeconds =
                              (_isWorkMode ? _workDuration : _breakDuration) *
                              60;
                        }
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      lang == 'en' ? "Save Settings" : "Simpan Pengaturan",
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? Colors.black : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- WIDGET HELPERS ---

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
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

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
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
