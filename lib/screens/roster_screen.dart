import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/stat_type.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key, required this.roster});

  final List<Player> roster;

  @override
  Widget build(BuildContext context) {
    final sorted = [...roster]..sort((a, b) => b.overall.compareTo(a.overall));

    return Scaffold(
      appBar: AppBar(title: const Text('部員一覧')),
      body: ListView.builder(
        itemCount: sorted.length,
        itemBuilder: (context, index) {
          final p = sorted[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('${p.overall}')),
              title: Text(p.name),
              subtitle: Text(
                '${p.grade}年 / ${p.role.label} / ${p.trait.label} / ${p.conditionLabel}',
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(p.trait.description),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            label: Text('士気 ${p.morale}'),
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text('疲労 ${p.fatigue}'),
                            visualDensity: VisualDensity.compact,
                          ),
                          ...StatType.values.map((s) {
                            return Chip(
                              label: Text('${s.label} ${p.stats[s]}'),
                              visualDensity: VisualDensity.compact,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
