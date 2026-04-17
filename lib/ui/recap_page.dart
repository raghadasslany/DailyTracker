import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';
import 'widgets/mood_monster.dart';

class RecapPage extends StatelessWidget {
  const RecapPage({super.key});

  // ── Design tokens (passed down) ──────────────────────────────────
  static const _accent  = Color(0xFF6366F1);
  static const _green   = Color(0xFF22c55e);
  static const _yellow  = Color(0xFFeab308);
  static const _orange  = Color(0xFFf97316);
  static const _red     = Color(0xFFef4444);
  static const _blue    = Color(0xFF3b82f6);

  Color _moodColor(String id) {
    switch (id) {
      case 'happy': return _green;
      case 'good':  return _blue;
      case 'meh':   return _yellow;
      case 'bad':   return _orange;
      case 'awful': return _red;
      default:      return Colors.grey;
    }
  }

  // _moodEmoji replaced by MiniMoodMonster widget

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DataProvider>();
    final goals    = provider.goals;
    final logs     = provider.logs;
    final isDark   = provider.isDarkMode;

    final bg      = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);
    final surface = isDark ? const Color(0xFF141920) : Colors.white;
    final border  = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final onBg    = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted   = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    // ── Computed stats ───────────────────────────────────────────────
    final streak = provider.currentStreak;

    DateTime? bestDay;
    int maxGoals = -1;
    for (final log in logs) {
      if (log.goals.length > maxGoals) {
        maxGoals = log.goals.length;
        bestDay  = DateTime.tryParse(log.date);
      }
    }

    double avgProductivity = 0;
    if (logs.isNotEmpty) {
      avgProductivity = logs.fold<int>(0, (s, l) => s + l.productivity) / logs.length;
    }
    
    final productivityScore = avgProductivity.round().clamp(0, 100);

    final Map<String, int> moodCounts = {};
    for (final log in logs) {
      for (final m in log.moods) {
        moodCounts[m] = (moodCounts[m] ?? 0) + 1;
      }
    }
    String topMood = '';
    if (moodCounts.isNotEmpty) {
      topMood = moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    // Weekly bar chart
    final today = DateTime.now();
    final List<Map<String, dynamic>> chartData = [];
    double maxBar = 100.0; // Productivity is a percentage
    for (int i = 6; i >= 0; i--) {
      final day = today.subtract(Duration(days: i));
      final found = logs.where((l) {
        final d = DateTime.tryParse(l.date);
        return d != null && d.year == day.year && d.month == day.month && d.day == day.day;
      }).toList();
      final val = found.isNotEmpty ? found.first.productivity.toDouble() : 0.0;
      chartData.add({'day': DateFormat('E').format(day)[0], 'val': val, 'date': day});
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Text('Recap',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: onBg, letterSpacing: -0.5)),
              const SizedBox(height: 2),
              Text('Your progress at a glance',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: muted)),
              const SizedBox(height: 28),

              // ── Score ring + streak ──────────────────────────────
              Row(
                children: [
                  // Ring
                  SizedBox(
                    width: 110, height: 110,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: productivityScore / 100,
                          strokeWidth: 10,
                          backgroundColor: _accent.withOpacity(isDark ? 0.12 : 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(_accent),
                          strokeCap: StrokeCap.round,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('$productivityScore%',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: onBg)),
                            Text('SCORE',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                letterSpacing: 1.0, color: muted)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Quick stats column
                  Expanded(
                    child: Column(
                      children: [
                        _QuickStat(
                          label: 'Streak', value: '$streak days',
                          icon: Icons.local_fire_department_rounded,
                          color: const Color(0xFFF59E0B), isDark: isDark,
                          surface: surface, border: border, onBg: onBg, muted: muted,
                        ),
                        const SizedBox(height: 8),
                        _QuickStat(
                          label: 'Avg Score', value: '${avgProductivity.round()}%',
                          icon: Icons.speed_rounded,
                          color: _accent, isDark: isDark,
                          surface: surface, border: border, onBg: onBg, muted: muted,
                        ),
                        const SizedBox(height: 8),
                        _QuickStat(
                          label: 'Total Logs', value: '${logs.length}',
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFF22c55e), isDark: isDark,
                          surface: surface, border: border, onBg: onBg, muted: muted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Insights row ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('INSIGHTS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        letterSpacing: 1.3, color: muted)),
                    const SizedBox(height: 14),
                    topMood.isNotEmpty
                      ? Row(
                          children: [
                            Text('Top Mood', style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            MiniMoodMonster(mood: topMood, size: 20),
                            const SizedBox(width: 6),
                            Text('${topMood[0].toUpperCase()}${topMood.substring(1)}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: onBg)),
                          ],
                        )
                      : _InsightRow(
                          label: 'Top Mood', value: 'N/A',
                          color: muted, onBg: onBg, muted: muted,
                        ),
                    _divider(border),
                    _InsightRow(
                      label: 'Best Day',
                      // ignore: unnecessary_non_null_assertion
                      value: bestDay != null ? DateFormat('EEE, MMM d').format(bestDay!) : 'N/A',
                      color: const Color(0xFF22c55e),
                      onBg: onBg, muted: muted,
                    ),
                    _divider(border),
                    _InsightRow(
                      label: 'Goals Tracked',
                      value: '${goals.length}',
                      color: _accent,
                      onBg: onBg, muted: muted,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Weekly bar chart ──────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('WEEKLY ACTIVITY',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                        letterSpacing: 1.3, color: muted)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 135,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: chartData.map((d) {
                          final val  = d['val'] as double;
                          final date = d['date'] as DateTime;
                          final isToday = _isSameDay(date, today);
                          final heightFactor = maxBar > 0 ? (val / maxBar) : 0.0;
                          final barColor = isToday ? _accent : _accent.withOpacity(0.35);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (val > 0)
                                    Text('${val.round()}',
                                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                        color: isToday ? _accent : muted)),
                                  const SizedBox(height: 3),
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                    height: (heightFactor * 90).clamp(4, 90),
                                    decoration: BoxDecoration(
                                      color: barColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(d['day'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
                                      color: isToday ? _accent : muted,
                                    )),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Mood calendar heatmap ──────────────────────────────
              _buildMoodCalendar(context, logs, isDark, surface, border, onBg, muted),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _divider(Color border) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 10),
        child: Divider(height: 1, color: border));

  Widget _buildMoodCalendar(
    BuildContext context,
    List logs,
    bool isDark,
    Color surface,
    Color border,
    Color onBg,
    Color muted,
  ) {
    final now          = DateTime.now();
    final daysInMonth  = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday; // 1=Mon

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('MOOD CALENDAR',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                  letterSpacing: 1.3, color: muted)),
              const Spacer(),
              Text(DateFormat('MMMM yyyy').format(now),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted)),
            ],
          ),
          const SizedBox(height: 12),
          // Day labels (Mon–Sun)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['M','T','W','T','F','S','S'].map((d) {
              return SizedBox(
                width: 32,
                child: Text(d, textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted)),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Grid
          ...List.generate(_weekCount(firstWeekday, daysInMonth), (w) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (d) {
                  final dayNum = w * 7 + d - (firstWeekday - 2);
                  if (dayNum < 1 || dayNum > daysInMonth) {
                    return const SizedBox(width: 32, height: 32);
                  }
                  final date    = DateTime(now.year, now.month, dayNum);
                  final isToday = _isSameDay(date, now);
                  final isFuture = date.isAfter(now);

                  String mood = '';
                  for (final log in logs) {
                    final ld = DateTime.tryParse(log.date);
                    if (ld != null && _isSameDay(ld, date)) {
                      mood = log.mood;
                      break;
                    }
                  }

                  final hasMood  = mood.isNotEmpty && !isFuture;
                  final cellColor = isFuture
                      ? Colors.transparent
                      : hasMood
                          ? _moodColor(mood)
                          : (isDark ? const Color(0xFF1A2030) : const Color(0xFFEFF2F7));

                  return Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(7),
                      border: isToday
                          ? Border.all(color: _accent, width: 2)
                          : isFuture
                              ? Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0))
                              : null,
                    ),
                    child: Center(
                      child: Text('$dayNum',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                          color: hasMood
                              ? Colors.white
                              : isFuture
                                  ? (isDark ? const Color(0xFF2D3748) : const Color(0xFFCBD5E0))
                                  : muted,
                        )),
                    ),
                  );
                }),
              ),
            );
          }),
          const SizedBox(height: 12),
          // Legend
          Wrap(
            spacing: 10, runSpacing: 6,
            children: [
              _CalLegend('Happy', _green),
              _CalLegend('Good',  _blue),
              _CalLegend('Meh',   _yellow),
              _CalLegend('Bad',   _orange),
              _CalLegend('Awful', _red),
            ],
          ),
        ],
      ),
    );
  }

  int _weekCount(int firstWeekday, int daysInMonth) =>
      ((daysInMonth + firstWeekday - 1) / 7).ceil();
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, surface, border, onBg, muted;
  final bool isDark;

  const _QuickStat({
    required this.label, required this.value, required this.icon,
    required this.color, required this.isDark, required this.surface,
    required this.border, required this.onBg, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, color: color, size: 15),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: muted)),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: onBg)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label, value;
  final Color color, onBg, muted;

  const _InsightRow({
    required this.label, required this.value,
    required this.color, required this.onBg, required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: muted, fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: onBg)),
      ],
    );
  }
}

class _CalLegend extends StatelessWidget {
  final String label;
  final Color color;
  const _CalLegend(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9, height: 9,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
      ],
    );
  }
}
