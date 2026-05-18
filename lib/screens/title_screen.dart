import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../services/game_engine.dart';
import '../services/save_service.dart';
import 'home_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final _save = SaveService();
  final _teamController = TextEditingController(text: '桜丘高校');
  GameState? _saved;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final saved = await _save.load();
    if (mounted) {
      setState(() {
        _saved = saved;
        _loading = false;
        if (saved != null) _teamController.text = saved.teamName;
      });
    }
  }

  void _start(GameState state) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(initialState: state)),
    );
  }

  Future<void> _newGame() async {
    final name = _teamController.text.trim();
    if (name.isEmpty) return;
    await _save.clear();
    _start(GameEngine().newGame(name));
  }

  void _continueGame() {
    if (_saved != null) _start(_saved!);
  }

  @override
  void dispose() {
    _teamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade800, Colors.green.shade900],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const Icon(Icons.sports_baseball, size: 72, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      '野球部監督',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '地区大会から甲子園優勝へ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      controller: _teamController,
                      decoration: InputDecoration(
                        labelText: '高校名',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _newGame,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade900,
                        ),
                        child: const Text('新しく始める', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    if (_saved != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _continueGame,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                          ),
                          child: Text('続きから（${_saved!.year}年目 第${_saved!.week}週）'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
