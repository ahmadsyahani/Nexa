import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/db_helper.dart';
import 'form_catatan_screen.dart';

class CatatanScreen extends StatefulWidget {
  const CatatanScreen({super.key});

  @override
  State<CatatanScreen> createState() => _CatatanScreenState();
}

class _CatatanScreenState extends State<CatatanScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    final data = await _dbHelper.getNotes();
    setState(() {
      _notes = data;
      _isLoading = false;
    });
  }

  Future<void> _deleteNote(int id) async {
    await _dbHelper.deleteNote(id);
    _fetchNotes();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

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
                  child: Row(
                    children: [
                      _M3BouncyButton(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(
                                isDark ? 0.05 : 0.1,
                              ),
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
                        lang == 'en' ? 'My Notes' : 'Catatan',
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

                // --- CONTENT ---
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFF59E0B),
                          ),
                        )
                      : _notes.isEmpty
                      ? _buildEmptyState(isDark, textColor, lang)
                      : _buildNotesGrid(isDark, textColor!),
                ),
              ],
            ),
          ),

          // --- FAB TAMBAH CATATAN ---
          floatingActionButton: _notes.isNotEmpty
              ? _M3BouncyButton(
                  onTap: () => _goToForm(null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          lang == 'en' ? "New Note" : "Catatan Baru",
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  // --- UI STATE KOSONG ---
  Widget _buildEmptyState(bool isDark, Color? textColor, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 140,
            width: 140,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFF59E0B).withOpacity(0.1)
                  : const Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFFF59E0B).withOpacity(0.2)
                        : const Color(0xFFFDE68A),
                    shape: BoxShape.circle,
                  ),
                ),
                const Icon(
                  Icons.edit_note_rounded,
                  size: 50,
                  color: Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            lang == 'en' ? "No Notes Yet" : "Belum Ada Catatan",
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang == 'en'
                ? "Your brilliant ideas and study notes will live here."
                : "Ide-ide cemerlang dan catatan matkul lu bakal kumpul di sini.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 14,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _M3BouncyButton(
            onTap: () => _goToForm(null),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    lang == 'en' ? "Create New Note" : "Buat Catatan Baru",
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // --- UI GRID CATATAN DENGAN ANIMASI ---
  Widget _buildNotesGrid(bool isDark, Color textColor) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        final noteColor = Color(note['color'] ?? 0xFF346EE0);

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + ((index % 6) * 100)),
          curve: Curves.easeOutBack,
          builder: (context, val, child) {
            return Transform.scale(
              scale: val,
              child: Opacity(opacity: val.clamp(0.0, 1.0), child: child),
            );
          },
          child: _M3BouncyButton(
            onTap: () => _goToForm(note),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? noteColor.withOpacity(0.15)
                    : noteColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? noteColor.withOpacity(0.3)
                      : noteColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          note['title'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showDeleteDialog(note['id']),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      note['content'],
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        height: 1.5,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note['date'],
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- DIALOG HAPUS ---
  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Hapus Catatan?",
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Catatan yang dihapus tidak bisa dikembalikan.",
          style: TextStyle(fontFamily: 'PlusJakartaSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote(id);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVIGASI KE FORM ---
  void _goToForm(Map<String, dynamic>? note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormCatatanScreen(note: note)),
    );
    if (result == true) {
      _fetchNotes();
    }
  }
}

class _M3BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _M3BouncyButton({required this.child, this.onTap});
  @override
  State<_M3BouncyButton> createState() => _M3BouncyButtonState();
}

class _M3BouncyButtonState extends State<_M3BouncyButton> {
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
