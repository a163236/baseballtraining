import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../models/stat_type.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key, required this.state});

  final GameState state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('週間練習メニュー')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '今週重点的に伸ばす項目を1つ選んでください。\n'
            '選ばなかった項目も、全員わずかに成長します。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ...StatType.values.map((type) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(type.label[0])),
                title: Text(type.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_hint(type)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(context, type),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _hint(StatType type) => switch (type) {
        StatType.pitchSpeed => '投手の球威が上がります',
        StatType.breakingBall => '変化球のキレが上がります',
        StatType.meet => '打率・出塁が安定します',
        StatType.power => '長打力が伸びます',
        StatType.speed => '走塁・盗塁が強化されます',
        StatType.defense => '守備・送球が安定します',
      };
}
