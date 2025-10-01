// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/board_state.dart';
import '../game_internals/score.dart';
import '../style/confetti.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import 'board_widget.dart';

/// Écran principal du jeu de dominos martiniquais
class DominosPlaySessionScreen extends StatefulWidget {
  const DominosPlaySessionScreen({super.key});

  @override
  State<DominosPlaySessionScreen> createState() => _DominosPlaySessionScreenState();
}

class _DominosPlaySessionScreenState extends State<DominosPlaySessionScreen> {
  static final _log = Logger('DominosPlaySessionScreen');

  static const _celebrationDuration = Duration(milliseconds: 2000);
  static const _preCelebrationDuration = Duration(milliseconds: 500);

  bool _duringCelebration = false;
  late DateTime _startOfPlay;
  late final DominosBoardState _boardState;

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return MultiProvider(
      providers: [Provider.value(value: _boardState)],
      child: IgnorePointer(
        ignoring: _duringCelebration,
        child: Scaffold(
          backgroundColor: palette.backgroundPlaySession,
          body: Stack(
            children: [
              Column(
                children: [
                  // Barre de navigation
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Dominos Martiniquais',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          Row(
                            children: [
                              MyButton(
                                onPressed: () => GoRouter.of(context).go('/'),
                                child: const Text('Menu'),
                              ),
                              const SizedBox(width: 8),
                              InkResponse(
                                onTap: () => GoRouter.of(context).push('/settings'),
                                child: const Icon(Icons.settings),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Interface de jeu - utilise tout l'espace restant
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DominosBoardWidget(),
                    ),
                  ),
                ],
              ),

              // Animation de victoire
              SizedBox.expand(
                child: Visibility(
                  visible: _duringCelebration,
                  child: IgnorePointer(
                    child: Confetti(isStopped: !_duringCelebration),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _boardState.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _startOfPlay = DateTime.now();
    _boardState = DominosBoardState(
      onGameEnd: _gameEnded,
      onRoundEnd: _roundEnded,
    );
  }

  Future<void> _gameEnded() async {
    _log.info('Game ended');

    final winner = _boardState.game.winner;
    if (winner == null) return;

    // final score = Score(
    //   _boardState.game.gameNumber,
    //   _boardState.game.roundNumber,
    //   DateTime.now().difference(_startOfPlay),
    // );

    await Future<void>.delayed(_preCelebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = true;
    });

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    await Future<void>.delayed(_celebrationDuration);
    if (!mounted) return;

    setState(() {
      _duringCelebration = false;
    });
  }

  Future<void> _roundEnded() async {
    _log.info('Round ended');

    final audioController = context.read<AudioController>();
    audioController.playSfx(SfxType.congrats);

    // Afficher un message de fin de manche
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fin de manche !'),
          content: Text('Manche ${_boardState.game.roundNumber} terminée'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
    }
  }
}
