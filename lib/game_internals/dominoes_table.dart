import 'package:flutter/foundation.dart';
import 'domino.dart';

enum DominoPosition { left, right }

class DominoesTable extends ChangeNotifier {
  final List<Domino> _dominosOnTable = [];

  List<Domino> get dominosOnTable => List.unmodifiable(_dominosOnTable);

  bool get isEmpty => _dominosOnTable.isEmpty;

  int? get leftConnection => isEmpty ? null : _dominosOnTable.first.displayLeftValue;
  int? get rightConnection => isEmpty ? null : _dominosOnTable.last.displayRightValue;

  List<int> get availableConnections {
    if (isEmpty) return [];
    return [leftConnection!, rightConnection!].toSet().toList();
  }

  bool canPlaceDomino(Domino domino) {
    if (isEmpty) return true;
    return domino.canConnectTo(leftConnection!) ||
           domino.canConnectTo(rightConnection!);
  }

  bool placeDomino(Domino domino, DominoPosition position) {
    if (!canPlaceDomino(domino)) return false;

    if (isEmpty) {
      _dominosOnTable.add(domino);
      notifyListeners();
      return true;
    }

    if (position == DominoPosition.left) {
      if (domino.displayRightValue == leftConnection) {
        _dominosOnTable.insert(0, domino);
      } else if (domino.displayLeftValue == leftConnection) {
        domino.flip();
        _dominosOnTable.insert(0, domino);
      } else {
        return false;
      }
    } else {
      if (domino.displayLeftValue == rightConnection) {
        _dominosOnTable.add(domino);
      } else if (domino.displayRightValue == rightConnection) {
        domino.flip();
        _dominosOnTable.add(domino);
      } else {
        return false;
      }
    }

    notifyListeners();
    return true;
  }

  void clear() {
    _dominosOnTable.clear();
    notifyListeners();
  }

  @override
  String toString() {
    if (isEmpty) return 'Table vide';
    return _dominosOnTable.map((d) => d.toString()).join(' - ');
  }
}