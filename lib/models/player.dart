import 'dart:math';

import 'stat_type.dart';

enum PlayerRole { pitcher, catcher, infielder, outfielder }

extension PlayerRoleLabel on PlayerRole {
  String get label => switch (this) {
        PlayerRole.pitcher => '投手',
        PlayerRole.catcher => '捕手',
        PlayerRole.infielder => '内野手',
        PlayerRole.outfielder => '外野手',
      };
}

enum PlayerTrait { hardWorker, genius, moodMaker, fragile, clutch }

extension PlayerTraitLabel on PlayerTrait {
  String get label => switch (this) {
        PlayerTrait.hardWorker => '努力家',
        PlayerTrait.genius => '天才肌',
        PlayerTrait.moodMaker => 'ムードメーカー',
        PlayerTrait.fragile => 'ケガしやすい',
        PlayerTrait.clutch => '勝負強い',
      };

  String get description => switch (this) {
        PlayerTrait.hardWorker => '練習で安定して伸びる',
        PlayerTrait.genius => '大きく伸びる週がある',
        PlayerTrait.moodMaker => 'チームの士気を支える',
        PlayerTrait.fragile => '疲労がたまりやすい',
        PlayerTrait.clutch => '公式戦で力を出しやすい',
      };
}

class Player {
  Player({
    required this.id,
    required this.name,
    required this.role,
    required this.grade,
    required this.stats,
    required this.trait,
    this.fatigue = 10,
    this.morale = 55,
  });

  final String id;
  final String name;
  final PlayerRole role;
  int grade; // 1=1年生, 2=2年生, 3=3年生
  final Map<StatType, int> stats;
  final PlayerTrait trait;
  final int fatigue; // 0〜100、高いほど不調・ケガリスク
  final int morale; // 0〜100、高いほど試合で力を出す

  int get overall {
    final weights = switch (role) {
      PlayerRole.pitcher => {
          StatType.pitchSpeed: 0.35,
          StatType.breakingBall: 0.30,
          StatType.defense: 0.10,
          StatType.meet: 0.05,
          StatType.power: 0.05,
          StatType.speed: 0.15,
        },
      PlayerRole.catcher => {
          StatType.defense: 0.30,
          StatType.meet: 0.25,
          StatType.power: 0.20,
          StatType.pitchSpeed: 0.05,
          StatType.breakingBall: 0.05,
          StatType.speed: 0.15,
        },
      _ => {
          StatType.meet: 0.25,
          StatType.power: 0.25,
          StatType.speed: 0.20,
          StatType.defense: 0.20,
          StatType.pitchSpeed: 0.05,
          StatType.breakingBall: 0.05,
        },
    };
    var sum = 0.0;
    for (final e in weights.entries) {
      sum += stats[e.key]! * e.value;
    }
    return sum.round();
  }

  int get matchPower {
    final traitBonus = trait == PlayerTrait.clutch ? 4 : 0;
    final condition = ((morale - 50) * 0.08 - fatigue * 0.06).round();
    return (overall + traitBonus + condition).clamp(1, 120);
  }

  String get conditionLabel {
    if (fatigue >= 75) return '疲労大';
    if (morale >= 75) return '好調';
    if (morale <= 35) return '不調';
    return '普通';
  }

  Player copyWith({
    int? grade,
    Map<StatType, int>? stats,
    PlayerTrait? trait,
    int? fatigue,
    int? morale,
  }) {
    return Player(
      id: id,
      name: name,
      role: role,
      grade: grade ?? this.grade,
      stats: stats ?? Map.from(this.stats),
      trait: trait ?? this.trait,
      fatigue: fatigue ?? this.fatigue,
      morale: morale ?? this.morale,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.index,
        'grade': grade,
        'stats': stats.map((k, v) => MapEntry(k.index.toString(), v)),
        'trait': trait.index,
        'fatigue': fatigue,
        'morale': morale,
      };

  factory Player.fromJson(Map<String, dynamic> json) {
    final statMap = <StatType, int>{};
    (json['stats'] as Map<String, dynamic>).forEach((k, v) {
      statMap[StatType.values[int.parse(k)]] = v as int;
    });
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      role: PlayerRole.values[json['role'] as int],
      grade: json['grade'] as int,
      stats: statMap,
      trait: PlayerTrait.values[json['trait'] as int? ?? 0],
      fatigue: json['fatigue'] as int? ?? 10,
      morale: json['morale'] as int? ?? 55,
    );
  }

  static Player random({
    required String id,
    required String name,
    required PlayerRole role,
    required int grade,
    Random? random,
  }) {
    final rng = random ?? Random();
    final stats = <StatType, int>{};
    for (final type in StatType.values) {
      stats[type] = 25 + rng.nextInt(26); // 25〜50
    }
    return Player(
      id: id,
      name: name,
      role: role,
      grade: grade,
      stats: stats,
      trait: PlayerTrait.values[rng.nextInt(PlayerTrait.values.length)],
      fatigue: 5 + rng.nextInt(16),
      morale: 45 + rng.nextInt(21),
    );
  }
}
