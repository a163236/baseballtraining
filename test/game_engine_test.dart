import 'package:baseball_training/models/stat_type.dart';
import 'package:baseball_training/services/game_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new game has 9 players and practice pending', () {
    final engine = GameEngine();
    final state = engine.newGame('テスト高校');
    expect(state.roster.length, 9);
    expect(state.pendingAction.name, 'practice');
  });

  test('practice increases focused stat', () {
    final engine = GameEngine();
    var state = engine.newGame('テスト高校');
    final before = state.roster.first.stats[StatType.power]!;
    state = engine.applyPractice(state, StatType.power);
    final after = state.roster.first.stats[StatType.power]!;
    expect(after, greaterThan(before));
  });
}
