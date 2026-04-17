import 'dart:convert';

class DayLog {
  final String id;
  final String date;
  final String mood;
  final List<String> moods;
  final List<String> goals;
  final Map<String, int> goalsProgress; // goalId -> progress value
  final int productivity;
  final String note;

  DayLog({
    required this.id,
    required this.date,
    required this.mood,
    this.moods = const [],
    this.goals = const [],
    this.goalsProgress = const {},
    required this.productivity,
    required this.note,
  });

  DayLog copyWith({
    String? id,
    String? date,
    String? mood,
    List<String>? moods,
    List<String>? goals,
    Map<String, int>? goalsProgress,
    int? productivity,
    String? note,
  }) {
    return DayLog(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      moods: moods ?? this.moods,
      goals: goals ?? this.goals,
      goalsProgress: goalsProgress ?? this.goalsProgress,
      productivity: productivity ?? this.productivity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'moods': moods,
      'goals': goals,
      'goalsProgress': goalsProgress,
      'productivity': productivity,
      'note': note,
    };
  }

  factory DayLog.fromMap(Map<String, dynamic> map) {
    // Parse goalsProgress: handle both old (missing) and new (present) format
    Map<String, int> parsedGoalsProgress = {};
    if (map['goalsProgress'] != null) {
      final raw = map['goalsProgress'];
      if (raw is Map) {
        raw.forEach((k, v) {
          parsedGoalsProgress[k.toString()] = (v as num).toInt();
        });
      }
    }

    return DayLog(
      id: map['id'] ?? '',
      date: map['date'] ?? '',
      mood: map['mood'] ?? '',
      moods: List<String>.from(map['moods'] ?? []),
      goals: List<String>.from(map['goals'] ?? []),
      goalsProgress: parsedGoalsProgress,
      productivity: map['productivity']?.toInt() ?? 0,
      note: map['note'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory DayLog.fromJson(String source) => DayLog.fromMap(json.decode(source));
}
