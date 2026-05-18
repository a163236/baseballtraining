import 'player.dart';
import 'stat_type.dart';
import 'tournament.dart';

enum SeasonPhase { spring, summer, autumn, winter }

extension SeasonPhaseLabel on SeasonPhase {
  String get label => switch (this) {
        SeasonPhase.spring => '春（練習期）',
        SeasonPhase.summer => '夏（公式戦）',
        SeasonPhase.autumn => '秋（強化試合）',
        SeasonPhase.winter => '冬（スカウト）',
      };
}

enum PendingAction { none, practice, tournament, scout, gameOver }

class MatchResult {
  MatchResult({
    required this.opponentName,
    required this.won,
    required this.ourScore,
    required this.theirScore,
    required this.stage,
    this.highlights = const [],
  });

  final String opponentName;
  final bool won;
  final int ourScore;
  final int theirScore;
  final TournamentStage stage;
  final List<String> highlights;

  String get summary =>
      won ? '$ourScore - $theirScore 勝利' : '$ourScore - $theirScore 敗北';
}

class GameState {
  GameState({
    required this.teamName,
    required this.year,
    required this.week,
    required this.phase,
    required this.roster,
    required this.stage,
    required this.pendingAction,
    this.lastMatch,
    this.message,
    this.scoutCandidates = const [],
    this.practiceDoneThisWeek = false,
  });

  final String teamName;
  final int year;
  final int week; // 1〜52
  final SeasonPhase phase;
  final List<Player> roster;
  final TournamentStage stage;
  final PendingAction pendingAction;
  final MatchResult? lastMatch;
  final String? message;
  final List<Player> scoutCandidates;
  final bool practiceDoneThisWeek;

  int get teamPower {
    if (roster.isEmpty) return 0;
    return (roster.map((p) => p.overall).reduce((a, b) => a + b) /
            roster.length)
        .round();
  }

  int get matchPower {
    if (roster.isEmpty) return 0;
    return (roster.map((p) => p.matchPower).reduce((a, b) => a + b) /
            roster.length)
        .round();
  }

  int get averageFatigue {
    if (roster.isEmpty) return 0;
    return (roster.map((p) => p.fatigue).reduce((a, b) => a + b) /
            roster.length)
        .round();
  }

  int get averageMorale {
    if (roster.isEmpty) return 0;
    return (roster.map((p) => p.morale).reduce((a, b) => a + b) / roster.length)
        .round();
  }

  bool get isChampion => stage == TournamentStage.champion;

  GameState copyWith({
    String? teamName,
    int? year,
    int? week,
    SeasonPhase? phase,
    List<Player>? roster,
    TournamentStage? stage,
    PendingAction? pendingAction,
    MatchResult? lastMatch,
    bool clearLastMatch = false,
    String? message,
    bool clearMessage = false,
    List<Player>? scoutCandidates,
    bool? practiceDoneThisWeek,
  }) {
    return GameState(
      teamName: teamName ?? this.teamName,
      year: year ?? this.year,
      week: week ?? this.week,
      phase: phase ?? this.phase,
      roster: roster ?? List.from(this.roster),
      stage: stage ?? this.stage,
      pendingAction: pendingAction ?? this.pendingAction,
      lastMatch: clearLastMatch ? null : (lastMatch ?? this.lastMatch),
      message: clearMessage ? null : (message ?? this.message),
      scoutCandidates: scoutCandidates ?? this.scoutCandidates,
      practiceDoneThisWeek: practiceDoneThisWeek ?? this.practiceDoneThisWeek,
    );
  }

  Map<String, dynamic> toJson() => {
        'teamName': teamName,
        'year': year,
        'week': week,
        'phase': phase.index,
        'roster': roster.map((p) => p.toJson()).toList(),
        'stage': stage.index,
        'pendingAction': pendingAction.index,
        'practiceDoneThisWeek': practiceDoneThisWeek,
        if (lastMatch != null) ...{
          'lastMatch': {
            'opponent': lastMatch!.opponentName,
            'won': lastMatch!.won,
            'our': lastMatch!.ourScore,
            'their': lastMatch!.theirScore,
            'stage': lastMatch!.stage.index,
            'highlights': lastMatch!.highlights,
          },
        },
        if (message != null) 'message': message,
      };

  factory GameState.fromJson(Map<String, dynamic> json) {
    MatchResult? lastMatch;
    final lm = json['lastMatch'];
    if (lm != null) {
      lastMatch = MatchResult(
        opponentName: lm['opponent'] as String,
        won: lm['won'] as bool,
        ourScore: lm['our'] as int,
        theirScore: lm['their'] as int,
        stage: TournamentStage.values[lm['stage'] as int],
        highlights: (lm['highlights'] as List? ?? const [])
            .map((e) => e as String)
            .toList(),
      );
    }
    return GameState(
      teamName: json['teamName'] as String,
      year: json['year'] as int,
      week: json['week'] as int,
      phase: SeasonPhase.values[json['phase'] as int],
      roster: (json['roster'] as List)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      stage: TournamentStage.values[json['stage'] as int],
      pendingAction: PendingAction.values[json['pendingAction'] as int],
      lastMatch: lastMatch,
      message: json['message'] as String?,
      practiceDoneThisWeek: json['practiceDoneThisWeek'] as bool? ?? false,
    );
  }
}

/// 練習で伸ばす対象の表示用
class PracticeInfo {
  const PracticeInfo({required this.focus, required this.description});
  final StatType focus;
  final String description;
}
