import 'dart:math';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/stat_type.dart';
import '../models/tournament.dart';

class GameEngine {
  GameEngine({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _idCounter = 0;

  String _nextId() => 'p${_idCounter++}';

  static const List<String> _familyNames = [
    '佐藤', '鈴木', '高橋', '田中', '伊藤', '渡辺', '山本', '中村', '小林', '加藤',
  ];
  static const List<String> _givenNames = [
    '翔太', '健太', '大輝', '蓮', '悠斗', '陽向', '颯太', '海斗', '悠真', '湊',
  ];

  String _randomName() {
    return '${_familyNames[_random.nextInt(_familyNames.length)]}'
        '${_givenNames[_random.nextInt(_givenNames.length)]}';
  }

  PlayerRole _randomRole() => PlayerRole.values[_random.nextInt(4)];

  GameState newGame(String teamName) {
    _idCounter = 0;
    final roster = <Player>[];
    final roles = [
      PlayerRole.pitcher,
      PlayerRole.pitcher,
      PlayerRole.catcher,
      PlayerRole.infielder,
      PlayerRole.infielder,
      PlayerRole.infielder,
      PlayerRole.outfielder,
      PlayerRole.outfielder,
      PlayerRole.outfielder,
    ];
    for (var i = 0; i < 9; i++) {
      roster.add(Player.random(
        id: _nextId(),
        name: _randomName(),
        role: roles[i],
        grade: 2,
        random: _random,
      ));
    }
    return GameState(
      teamName: teamName,
      year: 1,
      week: 1,
      phase: SeasonPhase.spring,
      roster: roster,
      stage: TournamentStage.none,
      pendingAction: PendingAction.practice,
      message: '新入部員とともに、地区大会からの道のりが始まります。',
    );
  }

  /// 週1回の練習。focus を重点的に、他は少し伸びる。
  GameState applyPractice(GameState state, StatType focus) {
    final updated = <Player>[];
    for (final player in state.roster) {
      final stats = Map<StatType, int>.from(player.stats);
      for (final type in StatType.values) {
        var gain = 0;
        if (type == focus) {
          gain = 3 + _random.nextInt(4); // 3〜6
        } else {
          gain = _random.nextInt(2); // 0〜1
        }
        stats[type] = (stats[type]! + gain).clamp(0, 99);
      }
      updated.add(player.copyWith(stats: stats));
    }
    return _afterPractice(
      state.copyWith(
        roster: updated,
        practiceDoneThisWeek: true,
        message: '今週は「${focus.label}」を重点練習しました。',
        pendingAction: PendingAction.none,
      ),
    );
  }

  GameState _afterPractice(GameState state) {
    if (state.pendingAction == PendingAction.tournament ||
        state.pendingAction == PendingAction.scout) {
      return state;
    }
    return state.copyWith(pendingAction: PendingAction.none);
  }

  GameState advanceWeek(GameState state) {
    if (state.isChampion) {
      return state.copyWith(
        pendingAction: PendingAction.gameOver,
        message: '甲子園優勝おめでとうございます！',
      );
    }

    var week = state.week + 1;
    var year = state.year;
    var phase = state.phase;
    var pending = state.pendingAction;
    var scoutCandidates = state.scoutCandidates;
    var message = state.message;
    var practiceDone = false;

    if (week > 52) {
      week = 1;
      year += 1;
      // 卒業
      final roster = state.roster
          .map((p) => p.copyWith(grade: p.grade + 1))
          .where((p) => p.grade <= 3)
          .toList();
      return GameState(
        teamName: state.teamName,
        year: year,
        week: week,
        phase: SeasonPhase.spring,
        roster: roster,
        stage: state.stage,
        pendingAction: PendingAction.scout,
        scoutCandidates: _generateScoutCandidates(3),
        message: '新年度。スカウトで1年生を迎えましょう。',
        practiceDoneThisWeek: false,
      );
    }

    phase = _phaseForWeek(week);
    pending = PendingAction.none;

    // 毎週練習可能（idea: 週に一回）
    if (week % 1 == 0 && phase != SeasonPhase.winter) {
      pending = PendingAction.practice;
    }

    // スカウト: 年始 week 1 は上で処理、冬の第48週も
    if (week == 48 && phase == SeasonPhase.winter) {
      pending = PendingAction.scout;
      scoutCandidates = _generateScoutCandidates(3);
      message = 'スカウト会議です。加入する新入生を選んでください。';
    }

    // 公式戦: 夏
    if (week == 24 && state.stage.index < TournamentStage.champion.index) {
      pending = PendingAction.tournament;
      message = _tournamentMessage(state.stage.next ?? TournamentStage.district);
    } else if (week == 30 &&
        state.stage.index >= TournamentStage.district.index &&
        state.stage != TournamentStage.champion) {
      pending = PendingAction.tournament;
      message = _tournamentMessage(_nextPlayableStage(state));
    } else if (week == 36 &&
        state.stage.index >= TournamentStage.prefectural.index &&
        state.stage != TournamentStage.champion) {
      pending = PendingAction.tournament;
      message = _tournamentMessage(_nextPlayableStage(state));
    } else if (week == 42 &&
        state.stage.index >= TournamentStage.koshien.index &&
        state.stage != TournamentStage.champion) {
      pending = PendingAction.tournament;
      message = '甲子園決勝です。優勝を目指しましょう！';
    }

    return state.copyWith(
      week: week,
      year: year,
      phase: phase,
      pendingAction: pending,
      scoutCandidates: scoutCandidates,
      message: message,
      practiceDoneThisWeek: practiceDone,
      clearLastMatch: true,
    );
  }

  TournamentStage _nextPlayableStage(GameState state) {
    if (state.stage == TournamentStage.none) return TournamentStage.district;
    return state.stage.next ?? state.stage;
  }

  String _tournamentMessage(TournamentStage stage) =>
      '「${stage.label}」の試合です。試合結果を確認しましょう。';

  SeasonPhase _phaseForWeek(int week) {
    if (week <= 13) return SeasonPhase.spring;
    if (week <= 26) return SeasonPhase.summer;
    if (week <= 39) return SeasonPhase.autumn;
    return SeasonPhase.winter;
  }

  List<Player> _generateScoutCandidates(int count) {
    return List.generate(
      count,
      (_) => Player.random(
        id: _nextId(),
        name: _randomName(),
        role: _randomRole(),
        grade: 1,
        random: _random,
      ),
    );
  }

  /// 試合はシミュレーションせず、チーム戦力と乱数で結果のみ
  GameState playTournament(GameState state) {
    final playStage = _nextPlayableStage(state);
    final opponentPower = _opponentPower(playStage);
    final ourPower = state.teamPower;
    final diff = ourPower - opponentPower;

    // 勝率: diff に応じて 30%〜85%
    final winChance = (0.5 + diff * 0.012).clamp(0.25, 0.85);
    final won = _random.nextDouble() < winChance;

    final ourScore = _generateScore(ourPower, won);
    final theirScore = _generateScore(opponentPower, !won);

    final result = MatchResult(
      opponentName: _opponentName(playStage),
      won: won,
      ourScore: ourScore,
      theirScore: theirScore,
      stage: playStage,
    );

    if (won) {
      final newStage = playStage;
      final next = newStage.next;
      return state.copyWith(
        stage: newStage,
        lastMatch: result,
        pendingAction:
            newStage == TournamentStage.champion ? PendingAction.gameOver : PendingAction.none,
        message: newStage == TournamentStage.champion
            ? '甲子園優勝！伝説の監督になりました！'
            : '「${newStage.label}」突破！${next != null ? "次は${next.label}です。" : ""}',
      );
    }

    return state.copyWith(
      lastMatch: result,
      pendingAction: PendingAction.none,
      message: '「${playStage.label}」で敗退…来季に備えて練習を続けましょう。',
    );
  }

  int _opponentPower(TournamentStage stage) => switch (stage) {
        TournamentStage.district => 38,
        TournamentStage.prefectural => 48,
        TournamentStage.koshien => 58,
        TournamentStage.champion => 68,
        _ => 35,
      };

  String _opponentName(TournamentStage stage) {
    final schools = switch (stage) {
      TournamentStage.district => ['城北高校', '西陵高校', '南星高校'],
      TournamentStage.prefectural => ['明徳高校', '桜丘高校', '東雲高校'],
      TournamentStage.koshien => ['常勝学院', '白鷹高校', '海星高校'],
      TournamentStage.champion => ['全国王者・帝星高校'],
      _ => ['練習相手高校'],
    };
    return schools[_random.nextInt(schools.length)];
  }

  int _generateScore(int power, bool favor) {
    final base = 2 + power ~/ 25;
    final bonus = favor ? _random.nextInt(4) : _random.nextInt(2);
    return (base + bonus).clamp(0, 15);
  }

  GameState recruitPlayer(GameState state, Player player) {
    if (state.roster.length >= 18) {
      return state.copyWith(
        message: 'ロースター上限（18人）のため加入できません。',
        pendingAction: PendingAction.none,
        scoutCandidates: [],
      );
    }
    final roster = [...state.roster, player];
    return state.copyWith(
      roster: roster,
      scoutCandidates: [],
      pendingAction: PendingAction.practice,
      message: '${player.name}（${player.role.label}）が加入しました。',
    );
  }

  GameState skipScout(GameState state) {
    return state.copyWith(
      scoutCandidates: [],
      pendingAction: PendingAction.practice,
      message: '今回のスカウトは見送りました。',
    );
  }
}
