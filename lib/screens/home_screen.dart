import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/stat_type.dart';
import '../models/tournament.dart';
import '../services/game_engine.dart';
import '../services/save_service.dart';
import 'practice_screen.dart';
import 'roster_screen.dart';
import 'scout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.initialState});

  final GameState initialState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GameState _state;
  final _engine = GameEngine();
  final _save = SaveService();

  @override
  void initState() {
    super.initState();
    _state = widget.initialState;
  }

  Future<void> _persist() async {
    await _save.save(_state);
  }

  void _update(GameState next) {
    setState(() => _state = next);
    _persist();
  }

  Future<void> _openPractice() async {
    final focus = await Navigator.push<StatType>(
      context,
      MaterialPageRoute(builder: (_) => PracticeScreen(state: _state)),
    );
    if (focus != null && mounted) {
      _update(_engine.applyPractice(_state, focus));
    }
  }

  Future<void> _openScout() async {
    final player = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ScoutScreen(state: _state)),
    );
    if (!mounted) return;
    if (player == null) {
      _update(_engine.skipScout(_state));
    } else {
      _update(_engine.recruitPlayer(_state, player));
    }
  }

  void _playMatch() {
    _update(_engine.playTournament(_state));
  }

  void _advanceWeek() {
    _update(_engine.advanceWeek(_state));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = _state.pendingAction;

    return Scaffold(
      appBar: AppBar(
        title: Text(_state.teamName),
        actions: [
          IconButton(
            icon: const Icon(Icons.groups),
            tooltip: 'メンバー',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RosterScreen(roster: _state.roster)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StatusCard(state: _state),
          const SizedBox(height: 16),
          if (_state.message != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_state.message!, style: theme.textTheme.bodyLarge),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_state.lastMatch != null) ...[
            Card(
              color: _state.lastMatch!.won
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'vs ${_state.lastMatch!.opponentName}',
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          _state.lastMatch!.summary,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: _state.lastMatch!.won
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                    Text(_state.lastMatch!.stage.label),
                    if (_state.lastMatch!.highlights.isNotEmpty) ...[
                      const Divider(height: 20),
                      ..._state.lastMatch!.highlights.map(
                        (text) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('・$text'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _ActionSection(
            action: action,
            practiceDone: _state.practiceDoneThisWeek,
            onPractice: _openPractice,
            onMatch: _playMatch,
            onScout: _openScout,
            onAdvanceWeek: _advanceWeek,
            isChampion: _state.isChampion,
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${state.year}年目  第${state.week}週',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.phase.label),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('チーム戦力', style: Theme.of(context).textTheme.bodyMedium),
                Text('${state.teamPower}',
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: _Meter(
                        label: '士気',
                        value: state.averageMorale,
                        color: Colors.blue)),
                const SizedBox(width: 12),
                Expanded(
                    child: _Meter(
                        label: '疲労',
                        value: state.averageFatigue,
                        color: Colors.deepOrange)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('大会進捗'),
                Text(
                  state.stage == TournamentStage.none
                      ? '未出場'
                      : state.stage.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('部員 ${state.roster.length}人',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Meter extends StatelessWidget {
  const _Meter({required this.label, required this.value, required this.color});

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text('$value', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          color: color,
          backgroundColor: color.withValues(alpha: 0.16),
        ),
      ],
    );
  }
}

class _ActionSection extends StatelessWidget {
  const _ActionSection({
    required this.action,
    required this.practiceDone,
    required this.onPractice,
    required this.onMatch,
    required this.onScout,
    required this.onAdvanceWeek,
    required this.isChampion,
  });

  final PendingAction action;
  final bool practiceDone;
  final VoidCallback onPractice;
  final VoidCallback onMatch;
  final VoidCallback onScout;
  final VoidCallback onAdvanceWeek;
  final bool isChampion;

  @override
  Widget build(BuildContext context) {
    if (action == PendingAction.gameOver || isChampion) {
      return Column(
        children: [
          const Icon(Icons.emoji_events, size: 64, color: Colors.amber),
          const SizedBox(height: 8),
          Text(
            isChampion ? '甲子園優勝！' : 'ゲームクリア',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: onAdvanceWeek,
            child: const Text('翌週へ（プレイ続行）'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (action == PendingAction.practice && !practiceDone)
          FilledButton.icon(
            onPressed: onPractice,
            icon: const Icon(Icons.fitness_center),
            label: const Text('今週の練習を決める'),
          ),
        if (action == PendingAction.tournament) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onMatch,
            icon: const Icon(Icons.sports_baseball),
            label: const Text('試合結果を見る'),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.orange.shade800),
          ),
        ],
        if (action == PendingAction.scout) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: onScout,
            icon: const Icon(Icons.person_search),
            label: const Text('スカウト（新入生）'),
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAdvanceWeek,
          icon: const Icon(Icons.skip_next),
          label: Text(
            practiceDone || action != PendingAction.practice
                ? '翌週へ進む'
                : '練習せずに翌週へ',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '毎週1回、伸ばす能力を選んで練習できます。選ばなかった能力も少しずつ伸びます。',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
