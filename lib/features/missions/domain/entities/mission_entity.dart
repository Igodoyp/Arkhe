import 'stat_type.dart';

class Mission {
  final String id;
  final String title;
  final String description;
  final StatType type;
  final int xpReward;
  final bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.type,
    this.isCompleted = false,
  });

  // Getter para compatibilidad con BonfirePage
  Map<String, int> get statsReward => { type.name: xpReward };

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    StatType? type,
    int? xpReward,
    bool? isCompleted,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}