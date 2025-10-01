import 'package:flutter/foundation.dart';

import 'domino.dart';

enum PlayerType { human, ai }

class DominoPlayer extends ChangeNotifier {
  static const maxDominos = 7;

  final String id;
  final String name;
  final PlayerType type;
  final List<Domino> hand = [];
  int partiesWon = 0;
  int cochons = 0;

  DominoPlayer({
    required this.id,
    required this.name,
    this.type = PlayerType.human,
  });

  void addDomino(Domino domino) {
    hand.add(domino);
    notifyListeners();
  }

  void removeDomino(Domino domino) {
    hand.remove(domino);
    notifyListeners();
  }

  void clearHand() {
    hand.clear();
    notifyListeners();
  }

  int get handValue {
    return hand.fold(0, (sum, domino) => sum + domino.totalValue);
  }

  bool get hasEmptyHand => hand.isEmpty;

  Domino? get highestDouble {
    final doubles = hand.where((domino) => domino.isDouble).toList();
    if (doubles.isEmpty) return null;

    doubles.sort((a, b) => b.higherValue.compareTo(a.higherValue));
    return doubles.first;
  }

  List<Domino> getPlayableDominos(List<int> availableConnections) {
    if (availableConnections.isEmpty) return hand;

    return hand.where((domino) {
      return availableConnections.any((connection) => domino.canConnectTo(connection));
    }).toList();
  }

  void winGame() {
    partiesWon++;
    notifyListeners();
  }

  void addCochon() {
    cochons++;
    notifyListeners();
  }

  void resetPartiesWon() {
    partiesWon = 0;
    notifyListeners();
  }

  @override
  String toString() {
    return '$name ($partiesWon parties, $cochons cochons)';
  }
}
