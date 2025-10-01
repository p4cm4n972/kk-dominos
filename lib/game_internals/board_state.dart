// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'dominoes_game.dart';

class DominosBoardState {
  final VoidCallback? onGameEnd;
  final VoidCallback? onRoundEnd;

  late final DominoesGame game;

  DominosBoardState({
    this.onGameEnd,
    this.onRoundEnd,
  }) {
    game = DominoesGame();
    game.addListener(_handleGameStateChange);
    game.startNewGame();
  }

  void dispose() {
    game.removeListener(_handleGameStateChange);
  }

  void _handleGameStateChange() {
    switch (game.phase) {
      case GamePhase.gameEnded:
        onGameEnd?.call();
        break;
      case GamePhase.roundEnded:
        onRoundEnd?.call();
        break;
      default:
        break;
    }
  }
}
