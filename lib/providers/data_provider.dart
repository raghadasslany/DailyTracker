import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/goal.dart';
import '../models/day_log.dart';

class DataProvider extends ChangeNotifier {
  List<Goal> _goals = [];
  List<DayLog> _logs = [];
  List<String> _selectedMoods = [];
  bool _isDarkMode = false;

  List<Goal> get goals => _goals;
  List<DayLog> get logs => _logs;
  List<String> get selectedMoods => _selectedMoods;
  bool get isDarkMode => _isDarkMode;

  /// Computed current streak from logs
  int get currentStreak {
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final hasLog = _logs.any((log) {
        final d = DateTime.tryParse(log.date);
        return d != null && d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day;
      });
      if (hasLog) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  DataProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final goalsData = prefs.getStringList('vybes-goals-storage');
    if (goalsData != null) {
      _goals = goalsData.map((e) => Goal.fromJson(e)).toList();
    }

    final logsData = prefs.getStringList('vybes-logs-storage');
    if (logsData != null) {
      _logs = logsData.map((e) => DayLog.fromJson(e)).toList();
    }

    final moodsData = prefs.getStringList('vybes-mood-storage');
    if (moodsData != null) {
      _selectedMoods = moodsData;
    }

    _isDarkMode = prefs.getBool('vybes-dark-mode') ?? false;

    notifyListeners();
  }

  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _goals.map((e) => e.toJson()).toList();
    await prefs.setStringList('vybes-goals-storage', data);
    _checkDailyLogUpdate();
    notifyListeners();
  }

  Future<void> _saveLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _logs.map((e) => e.toJson()).toList();
    await prefs.setStringList('vybes-logs-storage', data);
    notifyListeners();
  }

  Future<void> _saveMoods() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('vybes-mood-storage', _selectedMoods);
    _checkDailyLogUpdate();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vybes-dark-mode', _isDarkMode);
    notifyListeners();
  }

  // Mood Store Logic
  void toggleMood(String moodId) {
    if (_selectedMoods.contains(moodId)) {
      _selectedMoods.remove(moodId);
    } else {
      _selectedMoods.add(moodId);
    }
    _saveMoods();
  }

  void clearMoods() {
    _selectedMoods.clear();
    _saveMoods();
  }

  // Goal Store Logic
  void addGoal(String name, int target, String unit, String icon, String color) {
    final goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      target: target,
      unit: unit,
      icon: icon,
      color: color,
      progress: 0,
    );
    _goals.add(goal);
    _saveGoals();
  }

  void updateGoal(String id, {String? name, int? target, String? unit, String? icon, String? color}) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index >= 0) {
      _goals[index] = _goals[index].copyWith(
        name: name,
        target: target,
        unit: unit,
        icon: icon,
        color: color,
      );
      _saveGoals();
    }
  }

  void deleteGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    _saveGoals();
  }

  void updateGoalProgress(String id, int progress) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index >= 0) {
      _goals[index] = _goals[index].copyWith(progress: progress);
      _saveGoals();
    }
  }

  void clearGoals() {
    _goals.clear();
    _saveGoals();
  }

  // Log Store Logic
  void addLog(DayLog log) {
    final newLog = log.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString() + log.date);
    _logs.add(newLog);
    _saveLogs();
  }

  void updateLog(String id, {List<String>? moods, List<String>? goals, Map<String, int>? goalsProgress, int? productivity, String? note, String? mood}) {
    final index = _logs.indexWhere((l) => l.id == id);
    if (index >= 0) {
      _logs[index] = _logs[index].copyWith(
        moods: moods,
        goals: goals,
        goalsProgress: goalsProgress,
        productivity: productivity,
        note: note,
        mood: mood,
      );
      _saveLogs();
    }
  }

  void clearLogs() {
    _logs.clear();
    _saveLogs();
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  // Combined logic: saves ALL goals with any progress (not just completed ones)
  void _checkDailyLogUpdate() {
    final todayDate = DateTime.now();
    final existingLogIndex = _logs.indexWhere((l) => _isSameDay(DateTime.parse(l.date), todayDate));

    // Include ALL goals that have any progress (>0) or are already tracked
    final activeGoals = _goals.where((g) => g.progress > 0).toList();
    final completedGoals = _goals.where((g) => g.progress >= g.target).toList();

    // All goal IDs with any progress
    final activeGoalIds = activeGoals.map((g) => g.id).toList();

    // Build progress map: goalId -> progress
    final Map<String, int> goalsProgressMap = {
      for (var g in activeGoals) g.id: g.progress,
    };
    
    int productivity = 0;
    if (_goals.isNotEmpty) {
      productivity = ((completedGoals.length / _goals.length) * 100).round();
    }

    if (existingLogIndex >= 0) {
      // Update existing
      _logs[existingLogIndex] = _logs[existingLogIndex].copyWith(
        moods: _selectedMoods.isNotEmpty ? _selectedMoods : _logs[existingLogIndex].moods,
        mood: _selectedMoods.isNotEmpty ? _selectedMoods.first : _logs[existingLogIndex].mood,
        goals: activeGoalIds,
        goalsProgress: goalsProgressMap,
        productivity: productivity,
      );
    } else {
      // Add new if there is mood or any goal progress
      if (_selectedMoods.isNotEmpty || activeGoals.isNotEmpty) {
        final newLog = DayLog(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: todayDate.toIso8601String(),
          mood: _selectedMoods.isNotEmpty ? _selectedMoods.first : '',
          moods: List.from(_selectedMoods),
          goals: activeGoalIds,
          goalsProgress: goalsProgressMap,
          productivity: productivity,
          note: '',
        );
        _logs.add(newLog);
      }
    }
    _saveLogs();
  }
}
