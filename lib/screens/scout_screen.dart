import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../models/stat_type.dart';

class ScoutScreen extends StatelessWidget {
  const ScoutScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    final candidates = state.scoutCandidates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('スカウト'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('見送る'),
          ),
        ],
      ),
      body: candidates.isEmpty
          ? const Center(child: Text('候補がいません'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '加入する1年生を1人選ぶか、「見送る」でスキップできます。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                ...candidates.map((p) => _CandidateCard(player: p)),
              ],
            ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(player.name,
                    style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Text('総合 ${player.overall}',
                    style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            Text('${player.role.label} / 1年生 / ${player.trait.label}'),
            Text(
              player.trait.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                Chip(label: Text('士気${player.morale}')),
                Chip(label: Text('疲労${player.fatigue}')),
                ...StatType.values.map((s) {
                  return Chip(label: Text('${s.label}${player.stats[s]}'));
                }),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context, player),
              child: const Text('スカウトする'),
            ),
          ],
        ),
      ),
    );
  }
}
