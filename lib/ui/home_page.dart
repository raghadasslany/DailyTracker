// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../models/goal.dart';
import 'add_goal_page.dart';
import 'widgets/mood_monster.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> moodsData = [
    {"id": "awful",  "label": "Awful",  "color": const Color(0xFFef4444)},
    {"id": "bad",    "label": "Bad",    "color": const Color(0xFFf97316)},
    {"id": "meh",    "label": "Meh",    "color": const Color(0xFFeab308)},
    {"id": "good",   "label": "Good",   "color": const Color(0xFF3b82f6)},
    {"id": "happy",  "label": "Happy",  "color": const Color(0xFF22c55e)},
  ];

  final List<String> quotes = [
    "What gets measured gets managed.",
    "Track it. Fix it. Repeat.",
    "Data beats opinions every time.",
    "Consistency is compounding.",
    "The system is the goal.",
    "Ship daily. Reflect weekly.",
  ];
  late String _quote;

  @override
  void initState() {
    super.initState();
    quotes.shuffle();
    _quote = quotes.first;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
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
      default:          return Icons.star_border_rounded;
    }
  }

  void _showProgressEditor(BuildContext context, Goal goal, Color goalColor, DataProvider provider) {
    int tempProgress = goal.progress;
    final ctrl = TextEditingController(text: goal.progress.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final isDark = provider.isDarkMode;
          final sheetBg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
          final textPrimary = isDark ? Colors.white : const Color(0xFF0F172A);
          final subText = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: goalColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIconData(goal.icon), color: goalColor, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(goal.name,
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Target: ${goal.target} ${goal.unit}',
                    style: TextStyle(fontSize: 13, color: subText)),
                  const SizedBox(height: 20),

                  // Slider
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: goalColor,
                      inactiveTrackColor: goalColor.withOpacity(0.15),
                      thumbColor: goalColor,
                      overlayColor: goalColor.withOpacity(0.15),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      min: 0,
                      max: goal.target.toDouble(),
                      value: tempProgress.clamp(0, goal.target).toDouble(),
                      onChanged: (v) {
                        final rounded = v.round();
                        setModal(() { tempProgress = rounded; });
                        ctrl.text = rounded.toString();
                      },
                    ),
                  ),

                  // Quick increment row
                  Row(
                    children: [
                      Text('Progress:', style: TextStyle(fontSize: 13, color: subText)),
                      const Spacer(),
                      // Manual text input
                      Container(
                        width: 72,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: goalColor.withOpacity(0.4)),
                        ),
                        child: TextField(
                          controller: ctrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: 2), // Adjust up slightly
                          ),
                          onChanged: (v) {
                            final parsed = int.tryParse(v);
                            if (parsed != null) {
                              setModal(() { tempProgress = parsed.clamp(0, goal.target); });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('/ ${goal.target}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subText)),
                    ],
                  ),

                  // Quick +5 / +10 / +25 chips
                  if (goal.target > 10) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _quickIncrements(goal.target).map((inc) {
                        return ActionChip(
                          label: Text('+$inc',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: goalColor)),
                          backgroundColor: goalColor.withOpacity(0.1),
                          side: BorderSide(color: goalColor.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          onPressed: () {
                            final next = (tempProgress + inc).clamp(0, goal.target);
                            setModal(() { tempProgress = next; });
                            ctrl.text = next.toString();
                          },
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Confirm
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateGoalProgress(goal.id, tempProgress);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goalColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('Set Progress  •  $tempProgress / ${goal.target}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<int> _quickIncrements(int target) {
    if (target >= 1000) return [50, 100, 250];
    if (target >= 100) return [5, 10, 25];
    if (target >= 20) return [2, 5, 10];
    return [1, 2, 5];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEE, MMM d').format(DateTime.now());
    final provider = context.watch<DataProvider>();
    final isDark = provider.isDarkMode;

    // Design tokens
    final bg       = isDark ? const Color(0xFF0B0F14) : const Color(0xFFF7F9FC);
    final surface  = isDark ? const Color(0xFF141920) : Colors.white;
    final border   = isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0);
    final accent   = const Color(0xFF6366F1); // indigo
    final onBg     = isDark ? Colors.white : const Color(0xFF0F172A);
    final muted    = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Tracker',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: onBg, letterSpacing: -0.5)),
                        const SizedBox(height: 2),
                        Text(today,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: muted)),
                      ],
                    ),
                    const Spacer(),
                    // Streak badge
                    if (provider.currentStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text('${provider.currentStreak}d',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B))),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Mood Selector ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HOW\'S TODAY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.2)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: moodsData.map((mood) {
                          final isSelected = provider.selectedMoods.contains(mood['id']);
                          return MoodMonster(
                            mood: mood['id'],
                            size: 48,
                            isSelected: isSelected,
                            showLabel: true,
                            onTap: () => provider.toggleMood(mood['id']),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Quote strip ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(isDark ? 0.08 : 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: accent.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.format_quote_rounded, color: accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_quote,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white70 : const Color(0xFF334155),
                            fontStyle: FontStyle.italic)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Goals header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('GOALS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: muted, letterSpacing: 1.2)),
                    const Spacer(),
                    // Mini summary e.g. "2/5 done"
                    if (provider.goals.isNotEmpty)
                      Text(
                        '${provider.goals.where((g) => g.progress >= g.target).length}/${provider.goals.length} done',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: muted),
                      ),
                  ],
                ),
              ),
            ),

            // ── Goal list ────────────────────────────────────────────
            if (provider.goals.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.grid_view_rounded, size: 36, color: muted),
                        const SizedBox(height: 12),
                        Text('No goals yet',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: onBg)),
                        const SizedBox(height: 4),
                        Text('Tap + New Goal below to add one',
                          style: TextStyle(fontSize: 13, color: muted)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final goal = provider.goals[i];
                    final pct = (goal.progress / goal.target).clamp(0.0, 1.0);
                    final isDone = goal.progress >= goal.target;

                    Color goalColor = const Color(0xFF6366F1);
                    try {
                      goalColor = Color(int.parse(goal.color.replaceFirst('#', '0xFF')));
                    } catch (_) {}

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDone ? goalColor.withOpacity(0.4) : border,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Top row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 8, 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38, height: 38,
                                    decoration: BoxDecoration(
                                      color: goalColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Icon(_getIconData(goal.icon), color: goalColor, size: 19),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(goal.name,
                                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: onBg)),
                                        const SizedBox(height: 2),
                                        Text('${goal.progress} / ${goal.target} ${goal.unit}',
                                          style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  if (isDone)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: goalColor.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text('DONE',
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                                          color: goalColor, letterSpacing: 0.8)),
                                    ),
                                  IconButton(
                                    icon: Icon(Icons.tune_rounded, color: muted, size: 19),
                                    onPressed: () => Navigator.push(context,
                                      MaterialPageRoute(builder: (_) => AddGoalPage(goal: goal))),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                            // Progress bar
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 5,
                                  backgroundColor: goalColor.withOpacity(isDark ? 0.12 : 0.1),
                                  valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                                ),
                              ),
                            ),
                            // Controls row
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${(pct * 100).round()}%',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: goalColor)),
                                  Row(
                                    children: [
                                      // Decrement
                                      _CtrlBtn(
                                        icon: Icons.remove,
                                        color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0),
                                        iconColor: goal.progress > 0 ? onBg : muted,
                                        onTap: goal.progress > 0
                                            ? () => provider.updateGoalProgress(goal.id, goal.progress - 1)
                                            : null,
                                      ),
                                      const SizedBox(width: 6),
                                      // Tap to open full editor
                                      GestureDetector(
                                        onTap: () => _showProgressEditor(context, goal, goalColor, provider),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          decoration: BoxDecoration(
                                            color: goalColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: goalColor.withOpacity(0.3)),
                                          ),
                                          child: Text('Edit',
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: goalColor)),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // Increment
                                      _CtrlBtn(
                                        icon: Icons.add,
                                        color: goalColor,
                                        iconColor: Colors.white,
                                        onTap: goal.progress < goal.target
                                            ? () => provider.updateGoalProgress(goal.id, goal.progress + 1)
                                            : null,
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
                  },
                  childCount: provider.goals.length,
                ),
              ),

            // ── Add Goal button ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGoalPage()));
                  },
                  icon: Icon(Icons.add, size: 18, color: accent),
                  label: Text('New Goal',
                    style: TextStyle(fontWeight: FontWeight.w700, color: accent)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: accent.withOpacity(0.4)),
                    backgroundColor: accent.withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size(double.infinity, 0),
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

// ── Small control button ────────────────────────────────────────────────────
class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CtrlBtn({
    required this.icon,
    required this.color,
    required this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.35 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 16),
        ),
      ),
    );
  }
}
