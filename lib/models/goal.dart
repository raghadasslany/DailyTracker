import 'dart:convert';

class Goal {
  final String id;
  final String name;
  final int target;
  final String unit;
  final String icon;
  final String color;
  final int progress;

  Goal({
    required this.id,
    required this.name,
    required this.target,
    required this.unit,
    required this.icon,
    required this.color,
    required this.progress,
  });

  Goal copyWith({
    String? id,
    String? name,
    int? target,
    String? unit,
    String? icon,
    String? color,
    int? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      name: name ?? this.name,
      target: target ?? this.target,
      unit: unit ?? this.unit,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target': target,
      'unit': unit,
      'icon': icon,
      'color': color,
      'progress': progress,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      target: map['target']?.toInt() ?? 0,
      unit: map['unit'] ?? '',
      icon: map['icon'] ?? '',
      color: map['color'] ?? '',
      progress: map['progress']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) => Goal.fromMap(json.decode(source));
}
