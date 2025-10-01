import 'dart:math';

import 'package:flutter/foundation.dart';

import 'domino.dart';
import 'dominoes_table.dart';
import 'player.dart';

enum GamePhase { distribution, playing, gameEnded, roundEnded }
enum GameEndReason { allDominosPlayed, blocked, lowestScore }

class DominoesGame extends ChangeNotifier {
  static const int playersCount = 3;
  static const int dominosPerPlayer = 7;

  final List<DominoPlayer> players = [];
  final DominoesTable table = DominoesTable();
  final Random _random = Random();

  int currentPlayerIndex = 0;
  GamePhase phase = GamePhase.distribution;
  DominoPlayer? winner;
  GameEndReason? endReason;

  DominoPlayer? firstPlayerNextGame;
  int roundNumber = 1;
  int gameNumber = 1;

  DominoesGame() {
    _initializePlayers();
  }

  void _initializePlayers() {
    players.clear();
    players.addAll([
      DominoPlayer(id: '1', name: 'Vous', type: PlayerType.human),
      DominoPlayer(id: '2', name: 'Marcel', type: PlayerType.ai),
      DominoPlayer(id: '3', name: 'Sophie', type: PlayerType.ai),
    ]);
  }

  DominoPlayer get currentPlayer => players[currentPlayerIndex];

  void startNewGame() {
    _clearGameState();
    _distributeTraditional();
    _determineStartingPlayer();
    phase = GamePhase.playing;
    notifyListeners();
  }

  void _clearGameState() {
    for (final player in players) {
      player.clearHand();
    }
    table.clear();
    winner = null;
    endReason = null;
    phase = GamePhase.distribution;
  }

  void _distributeTraditional() {
    final allDominos = Domino.createFullSet();
    allDominos.shuffle(_random);

    for (int i = 0; i < dominosPerPlayer; i++) {
      for (final player in players) {
        player.addDomino(allDominos.removeAt(0));
      }
    }
  }

  void _determineStartingPlayer() {
    if (firstPlayerNextGame != null) {
      currentPlayerIndex = players.indexOf(firstPlayerNextGame!);
      firstPlayerNextGame = null;
      return;
    }

    DominoPlayer? playerWithHighestDouble;
    Domino? highestDouble;

    for (final player in players) {
      final playerHighestDouble = player.highestDouble;
      if (playerHighestDouble != null) {
        if (highestDouble == null ||
            playerHighestDouble.higherValue > highestDouble.higherValue) {
          highestDouble = playerHighestDouble;
          playerWithHighestDouble = player;
        }
      }
    }

    if (playerWithHighestDouble != null) {
      currentPlayerIndex = players.indexOf(playerWithHighestDouble);
    }
  }

  bool playDomino(Domino domino, DominoPosition position) {
    if (phase != GamePhase.playing) return false;
    if (!currentPlayer.hand.contains(domino)) return false;
    if (!table.canPlaceDomino(domino)) return false;

    if (table.placeDomino(domino, position)) {
      currentPlayer.removeDomino(domino);

      if (_checkGameEnd()) {
        _endGame();
      } else {
        _nextPlayer();
      }

      notifyListeners();
      return true;
    }

    return false;
  }

  bool _checkGameEnd() {
    if (currentPlayer.hasEmptyHand) {
      winner = currentPlayer;
      endReason = GameEndReason.allDominosPlayed;
      return true;
    }

    if (_isGameBlocked()) {
      _determineWinnerByScore();
      endReason = GameEndReason.blocked;
      return true;
    }

    return false;
  }

  bool _isGameBlocked() {
    for (final player in players) {
      final playableDominos = player.getPlayableDominos(table.availableConnections);
      if (playableDominos.isNotEmpty) return false;
    }
    return true;
  }

  void _determineWinnerByScore() {
    int lowestScore = players.first.handValue;
    winner = players.first;

    for (final player in players.skip(1)) {
      if (player.handValue < lowestScore) {
        lowestScore = player.handValue;
        winner = player;
      }
    }
    endReason = GameEndReason.lowestScore;
  }

  void _endGame() {
    phase = GamePhase.gameEnded;
    winner?.winGame();
    firstPlayerNextGame = winner;

    _checkRoundEnd();
  }

  void _checkRoundEnd() {
    final playersWithWins = players.where((p) => p.partiesWon > 0).length;
    final maxWins = players.map((p) => p.partiesWon).reduce((a, b) => a > b ? a : b);

    if (maxWins >= 3) {
      if (playersWithWins == 3) {
        _handleChamboul();
      } else {
        _endRound();
      }
    }
  }

  void _handleChamboul() {
    for (final player in players) {
      player.resetPartiesWon();
    }
    roundNumber++;
    gameNumber = 1;
  }

  void _endRound() {
    phase = GamePhase.roundEnded;

    final loser = players.where((p) => p.partiesWon == 0).first;
    loser.addCochon();

    for (final player in players) {
      player.resetPartiesWon();
    }

    roundNumber++;
    gameNumber = 1;
  }

  void _nextPlayer() {
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
  }

  void startNextGame() {
    if (phase == GamePhase.gameEnded) {
      gameNumber++;
      startNewGame();
    }
  }

  void startNextRound() {
    if (phase == GamePhase.roundEnded) {
      startNewGame();
    }
  }

  String get gameStatus {
    switch (phase) {
      case GamePhase.distribution:
        return 'Distribution des dominos...';
      case GamePhase.playing:
        return 'Tour de ${currentPlayer.name}';
      case GamePhase.gameEnded:
        return '${winner!.name} a gagné la partie ${gameNumber}!';
      case GamePhase.roundEnded:
        return 'Fin de la manche ${roundNumber}!';
    }
  }
}