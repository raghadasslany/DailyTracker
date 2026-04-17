// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/data_provider.dart';
import '../models/day_log.dart';
import '../models/goal.dart';
import 'widgets/mood_monster.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedDate;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  void _changeMonth(int offset) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + offset, 1);
    });
  }

  bool _isSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final days = <DateTime>[];
    final n = DateUtils.getDaysInMonth(month.year, month.month);
    for (int i = 1; i <= n; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    return days;
  }

  /// Activity level based on productivity percentage stored in log
  String _getActivityLevel(DateTime date, List<DayLog> logs) {
    final idx = logs.indexWhere((l) => _isSameDay(DateTime.tryParse(l.date), date));
    if (idx == -1) return 'none';
    final log = logs[idx];
    // Use count of goals that have ANY progress
    final count = log.goals.length;
    if (count == 0) {
      // Maybe mood was logged but no goals
      return log.moods.isNotEmpty ? 'mood' : 'none';
    }
    if (log.productivity >= 80) return 'high';
    if (log.productivity >= 40) return 'medium';
    return 'low';
  }

  void _handleDayClick(DateTime date, List<DayLog> logs) {
    setState(() => _selectedDate = date);
    final idx = logs.indexWhere((l) => _isSameDay(DateTime.tryParse(l.date), date));
    _noteController.text = idx != -1 ? logs[idx].note : '';
    _showDaySheet(context, date);
  }

  void _handleSaveNote(BuildContext context, DayLog log) async {
    setState(() => _isSaving = true);
    context.read<DataProvider>().updateLog(log.id, note: _noteController.text);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _isSaving = false);
  }

  IconData _getIconData(String name) {
    switch (name) {
      case 'book':      return Icons.menu_book_rounded;
      case 'briefcase': return Icons.work_outline_rounded;
      case 'coffee':    return Icons.coffee_rounded;
      case 'heart':     return Icons.favorite_border_rounded;
      case 'music':     return Icons.music_note_rounded;
      case 'sun':       return Icons.wb_sunny_outlined;
      case 'moon':      return Icons.nights_stay_outlined;
      case 'star':      return Icons.star_border_rounded;
      case 'droplet':   return Icons.water_drop_outlined;
      case 'activity':  return Icons.fitness_center_rounded;
      default:          return Icons.check_rounded;
    }
  }

  // _moodEmoji replaced by MiniMoodMonster widget

  void _showDaySheet(BuildContext context, DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            final provider = context.watch<DataProvider>();
            final isDark = provider.isDarkMode;
            final idx = provider.logs.indexWhere(
                (l) => _isSameDay(DateTime.tryParse(l.date), date));
            final log = idx != -1 ? provider.logs[idx] : null;

            final surface = isDark ? const Color(0xFF141920) : Colors.white;
            final border  = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
            final onBg    = isDark ? Colors.white : const Color(0xFF0F172A);
            final muted   = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
            final inputBg = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);

            // Resolve goal objects that appear in this log (partial or complete)
            List<Map<String, dynamic>> logGoalData = [];
            if (log != null) {
              for (final goalId in log.goals) {
                final matching = provider.goals.where((g) => g.id == goalId).toList();
                final goal = matching.isNotEmpty ? matching.first : null;
                if (goal != null) {
                  final savedProgress = log.goalsProgress[goalId] ?? goal.progress;
                  logGoalData.add({
                    'goal': goal,
                    'savedProgress': savedProgress,
                  });
                }
              }
            }

            return Container(
              margin: EdgeInsets.only(top: MediaQuery.of(ctx).padding.top + 48),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 20, right: 20, top: 8,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(top: 8, bottom: 20),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('EEEE').format(date),
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                                  color: onBg, letterSpacing: -0.3)),
                              Text(DateFormat('MMMM d, yyyy').format(date),
                                style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: muted),
                          onPressed: () => Navigator.pop(ctx),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Moods ─────────────────────────────────────────
                    _SheetSection(label: 'MOOD', isDark: isDark),
                    const SizedBox(height: 10),
                    if (log != null && log.moods.isNotEmpty)
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: log.moods.map((id) {
                          Color c = Colors.grey;
                          if (id == 'happy') c = const Color(0xFF22c55e);
                          if (id == 'good')  c = const Color(0xFF3b82f6);
                          if (id == 'meh')   c = const Color(0xFFeab308);
                          if (id == 'bad')   c = const Color(0xFFf97316);
                          if (id == 'awful') c = const Color(0xFFef4444);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: c.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: c.withOpacity(0.35)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MiniMoodMonster(mood: id, size: 22),
                                const SizedBox(width: 6),
                                Text(id[0].toUpperCase() + id.substring(1),
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: c)),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text('No mood logged.', style: TextStyle(fontSize: 13, color: muted, fontStyle: FontStyle.italic)),

                    const SizedBox(height: 24),

                    // ── Goals ─────────────────────────────────────────
                    _SheetSection(label: 'GOALS', isDark: isDark),
                    const SizedBox(height: 10),
                    if (logGoalData.isNotEmpty)
                      ...logGoalData.map((entry) {
                        final goal = entry['goal'] as Goal;
                        final saved = entry['savedProgress'] as int;
                        final isDone = saved >= goal.target;
                        final pct = (saved / goal.target).clamp(0.0, 1.0);

                        Color gc = const Color(0xFF6366F1);
                        try { gc = Color(int.parse(goal.color.replaceFirst('#', '0xFF'))); } catch (_) {}

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDone ? gc.withOpacity(0.4) : border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: gc.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(_getIconData(goal.icon), color: gc, size: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(goal.name,
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: onBg)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDone ? gc.withOpacity(0.12) : border,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('$saved / ${goal.target}',
                                      style: TextStyle(
                                        fontSize: 11, fontWeight: FontWeight.w800,
                                        color: isDone ? gc : muted,
                                      )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 4,
                                  backgroundColor: gc.withOpacity(0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(gc),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${(pct * 100).round()}% • ${goal.unit}',
                                style: TextStyle(fontSize: 11, color: muted)),
                            ],
                          ),
                        );
                      }).toList()
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Text('No goal activity recorded this day.',
                          style: TextStyle(fontSize: 13, color: muted, fontStyle: FontStyle.italic)),
                      ),

                    const SizedBox(height: 24),

                    // ── Daily Note ────────────────────────────────────
                    Row(
                      children: [
                        Expanded(child: _SheetSection(label: 'NOTE', isDark: isDark)),
                        if (log != null)
                          GestureDetector(
                            onTap: _isSaving ? null : () => _handleSaveNote(context, log),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: _isSaving
                                    ? const Color(0xFF22c55e).withOpacity(0.12)
                                    : const Color(0xFF6366F1).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isSaving
                                      ? const Color(0xFF22c55e).withOpacity(0.4)
                                      : const Color(0xFF6366F1).withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isSaving ? Icons.check_rounded : Icons.save_rounded,
                                    size: 13,
                                    color: _isSaving ? const Color(0xFF22c55e) : const Color(0xFF6366F1),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isSaving ? 'Saved' : 'Save',
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w700,
                                      color: _isSaving ? const Color(0xFF22c55e) : const Color(0xFF6366F1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        readOnly: log == null,
                        style: TextStyle(fontSize: 14, color: onBg, height: 1.5),
                        decoration: InputDecoration(
                          hintText: log == null
                              ? 'Log a mood first to add a note.'
                              : 'What happened today?',
                          hintStyle: TextStyle(fontSize: 13, color: muted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) => setState(() => _selectedDate = null));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final daysInMonth = _getDaysInMonth(_currentMonth);
    final firstDayWeekday = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;
    final isDark = provider.isDarkMode;

    final bg      = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);
    final surface = isDark ? const Color(0xFF141920) : Colors.white;
    final border  = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final onBg    = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted   = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Activity Log',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: onBg, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text('Tap a day to review your entries',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: muted)),
              const SizedBox(height: 24),

              // Month Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left_rounded, color: muted),
                      onPressed: () => _changeMonth(-1),
                      visualDensity: VisualDensity.compact,
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('MMMM yyyy').format(_currentMonth),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: onBg),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.chevron_right_rounded, color: muted),
                      onPressed: () => _changeMonth(1),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Day of week labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((d) {
                  return SizedBox(
                    width: 36,
                    child: Text(d,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted, letterSpacing: 0.5)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Calendar grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: firstDayWeekday + daysInMonth.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1,
                ),
                itemBuilder: (ctx, index) {
                  if (index < firstDayWeekday) return const SizedBox();
                  final day = daysInMonth[index - firstDayWeekday];
                  final level = _getActivityLevel(day, provider.logs);
                  final isToday = _isSameDay(day, DateTime.now());
                  final isSelected = _isSameDay(day, _selectedDate);
                  final isFuture = day.isAfter(DateTime.now());

                  Color cellBg;
                  Color textColor;

                  if (isFuture) {
                    cellBg = Colors.transparent;
                    textColor = isDark ? const Color(0xFF2D3748) : const Color(0xFFCBD5E0);
                  } else {
                    switch (level) {
                      case 'high':
                        cellBg = const Color(0xFF6366F1);
                        textColor = Colors.white;
                        break;
                      case 'medium':
                        cellBg = const Color(0xFF6366F1).withOpacity(0.5);
                        textColor = Colors.white;
                        break;
                      case 'low':
                        cellBg = const Color(0xFF6366F1).withOpacity(0.2);
                        textColor = isDark ? Colors.white70 : const Color(0xFF3730A3);
                        break;
                      case 'mood':
                        cellBg = const Color(0xFF22c55e).withOpacity(0.2);
                        textColor = isDark ? Colors.white70 : const Color(0xFF14532D);
                        break;
                      default:
                        cellBg = isDark ? const Color(0xFF1A2030) : const Color(0xFFEFF2F7);
                        textColor = isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF);
                    }
                  }

                  return GestureDetector(
                    onTap: isFuture ? null : () => _handleDayClick(day, provider.logs),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: cellBg,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF6366F1), width: 2)
                            : isToday && !isSelected
                                ? Border.all(color: isDark ? Colors.white38 : const Color(0xFF475569), width: 1.5)
                                : null,
                      ),
                      alignment: Alignment.center,
                      child: Text('${day.day}',
                        style: TextStyle(
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                          fontSize: 13,
                          color: textColor,
                        )),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Legend
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _LegendDot(label: 'No Data', color: isDark ? const Color(0xFF1A2030) : const Color(0xFFEFF2F7)),
                  _LegendDot(label: 'Mood Only', color: const Color(0xFF22c55e).withOpacity(0.4)),
                  _LegendDot(label: 'Low', color: const Color(0xFF6366F1).withOpacity(0.25)),
                  _LegendDot(label: 'Medium', color: const Color(0xFF6366F1).withOpacity(0.55)),
                  _LegendDot(label: 'High', color: const Color(0xFF6366F1)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ──────────────────────────────────────────────────────────

class _SheetSection extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SheetSection({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ));
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 5),
        Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
      ],
    );
  }
}
