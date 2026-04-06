import 'package:flutter/material.dart';
import '../../services/db_helper.dart';

class FormCatatanScreen extends StatefulWidget {
  final Map<String, dynamic>? note;

  const FormCatatanScreen({super.key, this.note});

  @override
  State<FormCatatanScreen> createState() => _FormCatatanScreenState();
}

class _FormCatatanScreenState extends State<FormCatatanScreen> {
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  final List<int> _noteColors = [
    0xFFF59E0B, // Amber
    0xFF3B82F6, // Blue
    0xFF10B981, // Emerald
    0xFFF43F5E, // Rose
    0xFF8B5CF6, // Purple
    0xFF6B7280, // Gray
  ];

  late int _selectedColor;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'];
      _contentController.text = widget.note!['content'];
      _selectedColor = widget.note!['color'] ?? _noteColors[0];
    } else {
      _selectedColor = _noteColors[0];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context, false);
      return;
    }

    final now = DateTime.now();
    final String dateStr =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    final noteData = {
      'title': title.isEmpty ? 'Tanpa Judul' : title,
      'content': content,
      'date': dateStr,
      'color': _selectedColor,
    };

    if (widget.note == null) {
      await _dbHelper.insertNote(noteData);
    } else {
      noteData['id'] = widget.note!['id'];
      await _dbHelper.updateNote(noteData);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    final dynamicBgColor = isDark
        ? Color(_selectedColor).withValues(alpha: 0.15)
        : Color(_selectedColor).withValues(alpha: 0.1);

    return Scaffold(
      backgroundColor: dynamicBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- CUSTOM APP BAR ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: textColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _saveNote,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Color(_selectedColor),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(_selectedColor).withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Text(
                        "Simpan",
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // --- COLOR PICKER ---
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _noteColors.length,
                itemBuilder: (context, index) {
                  final colorVal = _noteColors[index];
                  final isSelected = _selectedColor == colorVal;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = colorVal),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      width: isSelected ? 36 : 30,
                      height: isSelected ? 36 : 30,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: textColor!, width: 2.5)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Color(colorVal).withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- FORM INPUT ---
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: "Judul Catatan",
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 16,
                        height: 1.6,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.grey.shade700,
                      ),
                      decoration: InputDecoration(
                        hintText: "Mulai ngetik apa aja di sini...",
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
