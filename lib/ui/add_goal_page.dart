// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/goal.dart';
import '../providers/data_provider.dart';

class AddGoalPage extends StatefulWidget {
  final Goal? goal;
  const AddGoalPage({super.key, this.goal});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  late TextEditingController _unitController;

  String _selectedIcon = 'star';
  String _selectedColor = '#6366f1';

  final List<Map<String, dynamic>> _icons = [
    {'id': 'book', 'icon': Icons.menu_book_rounded},
    {'id': 'briefcase', 'icon': Icons.work_outline_rounded},
    {'id': 'coffee', 'icon': Icons.coffee_rounded},
    {'id': 'heart', 'icon': Icons.favorite_border_rounded},
    {'id': 'music', 'icon': Icons.music_note_rounded},
    {'id': 'sun', 'icon': Icons.wb_sunny_outlined},
    {'id': 'moon', 'icon': Icons.nights_stay_outlined},
    {'id': 'star', 'icon': Icons.star_border_rounded},
    {'id': 'droplet', 'icon': Icons.water_drop_outlined},
    {'id': 'activity', 'icon': Icons.fitness_center_rounded},
  ];

  final List<String> _colors = [
    '#6366f1',
    '#3b82f6',
    '#06b6d4',
    '#22c55e',
    '#84cc16',
    '#eab308',
    '#f97316',
    '#ef4444',
    '#ec4899',
    '#a855f7',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.goal?.name ?? '');
    _targetController = TextEditingController(
      text: widget.goal != null ? widget.goal!.target.toString() : '1',
    );
    _unitController = TextEditingController(text: widget.goal?.unit ?? 'times');
    if (widget.goal != null) {
      _selectedIcon = widget.goal!.icon;
      _selectedColor = widget.goal!.color;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _saveGoal() {
    final name = _nameController.text.trim();
    final target = int.tryParse(_targetController.text) ?? 1;
    final unit = _unitController.text.trim();
    if (name.isEmpty) return;

    final provider = context.read<DataProvider>();
    if (widget.goal == null) {
      provider.addGoal(name, target, unit, _selectedIcon, _selectedColor);
    } else {
      provider.updateGoal(
        widget.goal!.id,
        name: name,
        target: target,
        unit: unit,
        icon: _selectedIcon,
        color: _selectedColor,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<DataProvider>().isDarkMode;
    final bg = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);
    final surface = isDark ? const Color(0xFF141920) : Colors.white;
    final onBg = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    final border = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final inputBg = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);
    const accent = Color(0xFF6366F1);

    InputDecoration _field(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: muted, fontSize: 14),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
    );

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.goal == null ? 'New Goal' : 'Edit Goal',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: onBg,
          ),
        ),
        iconTheme: IconThemeData(color: onBg),
        actions: [
          if (widget.goal != null)
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFef4444),
              ),
              onPressed: () {
                context.read<DataProvider>().deleteGoal(widget.goal!.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Name ─────────────────────────────────────────────
            _Label('GOAL NAME', muted),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: TextStyle(
                color: onBg,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              decoration: _field('e.g. Read a book'),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // ── Target + Unit row ─────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('TARGET', muted),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: TextStyle(
                          color: onBg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _field('100'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Label('UNIT', muted),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _unitController,
                        style: TextStyle(
                          color: onBg,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: _field('pages, mins, km…'),
                        textCapitalization: TextCapitalization.none,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Icon picker ───────────────────────────────────────
            _Label('ICON', muted),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _icons.map((item) {
                  final isSelected = _selectedIcon == item['id'];
                  Color selColor = accent;
                  try {
                    selColor = Color(
                      int.parse(_selectedColor.replaceFirst('#', '0xFF')),
                    );
                  } catch (_) {}

                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = item['id']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selColor.withOpacity(0.15)
                            : inputBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? selColor : border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Icon(
                        item['icon'],
                        color: isSelected ? selColor : muted,
                        size: 22,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // ── Color picker ──────────────────────────────────────
            _Label('COLOR', muted),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _colors.map((c) {
                  final clr = Color(int.parse(c.replaceFirst('#', '0xFF')));
                  final isSelected = _selectedColor == c;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isSelected ? 32 : 28,
                      height: isSelected ? 32 : 28,
                      decoration: BoxDecoration(
                        color: clr,
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: clr.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 36),

            // ── Save button ───────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.goal == null ? 'Create Goal' : 'Save Changes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.3,
        color: color,
      ),
    );
  }
}
