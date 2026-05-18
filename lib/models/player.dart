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

class Player {
  Player({
    required this.id,
    required this.name,
    required this.role,
    required this.grade,
    required this.stats,
  });

  final String id;
  final String name;
  final PlayerRole role;
  int grade; // 1=1年生, 2=2年生, 3=3年生
  final Map<StatType, int> stats;

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

  Player copyWith({int? grade, Map<StatType, int>? stats}) {
    return Player(
      id: id,
      name: name,
      role: role,
      grade: grade ?? this.grade,
      stats: stats ?? Map.from(this.stats),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.index,
        'grade': grade,
        'stats': stats.map((k, v) => MapEntry(k.index.toString(), v)),
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
    return Player(id: id, name: name, role: role, grade: grade, stats: stats);
  }
}
