// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_state.dart';
import '../game_internals/dominoes_game.dart';
import 'dominoes_table_widget.dart';
import 'player_hand_widget.dart';

/// This widget defines the dominoes game UI
class DominosBoardWidget extends StatefulWidget {
  const DominosBoardWidget({super.key});

  @override
  State<DominosBoardWidget> createState() => _DominosBoardWidgetState();
}

class _DominosBoardWidgetState extends State<DominosBoardWidget> {
  @override
  Widget build(BuildContext context) {
    final boardState = context.watch<DominosBoardState>();

    return ListenableBuilder(
      listenable: boardState.game,
      builder: (context, child) {
        return Row(
          children: [
            // Joueur gauche (Sophie - IA)
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PlayerHandWidget(
                    player: boardState.game.players[2],
                    isHuman: false,
                  ),
                ],
              ),
            ),

            // Zone centrale (table + statut)
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  // Joueur du haut (Marcel - IA) - taille fixe
                  SizedBox(
                    height: 80,
                    child: PlayerHandWidget(
                      player: boardState.game.players[1],
                      isHuman: false,
                    ),
                  ),

                  // Espace flexible pour centrer le contenu
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Statut du jeu
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            boardState.game.gameStatus,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Table de jeu
                        const DominoesTableWidget(),

                        const SizedBox(height: 12),

                        // Boutons d'action
                        if (boardState.game.phase == GamePhase.gameEnded)
                          ElevatedButton(
                            onPressed: () => boardState.game.startNextGame(),
                            child: const Text('Nouvelle partie'),
                          ),

                        if (boardState.game.phase == GamePhase.roundEnded)
                          ElevatedButton(
                            onPressed: () => boardState.game.startNextRound(),
                            child: const Text('Nouvelle manche'),
                          ),
                      ],
                    ),
                  ),

                  // Joueur du bas (Vous - Humain) - taille fixe
                  SizedBox(
                    height: 80,
                    child: PlayerHandWidget(
                      player: boardState.game.players[0],
                      isHuman: true,
                    ),
                  ),
                ],
              ),
            ),

            // Espace droit pour équilibrer
            const Expanded(
              flex: 2,
              child: SizedBox(),
            ),
          ],
        );
      },
    );
  }
}
