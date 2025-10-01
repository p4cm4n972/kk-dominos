import 'dart:math';

class Domino {
  static final _random = Random();

  final int leftValue;
  final int rightValue;
  bool isFlipped;

  Domino(this.leftValue, this.rightValue, {this.isFlipped = false});

  factory Domino.fromJson(Map<String, dynamic> json) {
    return Domino(
      json['leftValue'] as int,
      json['rightValue'] as int,
      isFlipped: json['isFlipped'] as bool? ?? false,
    );
  }

  static List<Domino> createFullSet() {
    List<Domino> dominos = [];
    for (int i = 0; i <= 6; i++) {
      for (int j = i; j <= 6; j++) {
        dominos.add(Domino(i, j));
      }
    }
    return dominos;
  }

  bool get isDouble => leftValue == rightValue;

  int get totalValue => leftValue + rightValue;

  int get higherValue => leftValue > rightValue ? leftValue : rightValue;

  int get lowerValue => leftValue < rightValue ? leftValue : rightValue;

  bool canConnectTo(int value) {
    return leftValue == value || rightValue == value;
  }

  void flip() {
    isFlipped = !isFlipped;
  }

  int get displayLeftValue => isFlipped ? rightValue : leftValue;
  int get displayRightValue => isFlipped ? leftValue : rightValue;

  @override
  int get hashCode => Object.hash(leftValue, rightValue);

  @override
  bool operator ==(Object other) {
    return other is Domino &&
           ((other.leftValue == leftValue && other.rightValue == rightValue) ||
            (other.leftValue == rightValue && other.rightValue == leftValue));
  }

  Map<String, dynamic> toJson() => {
    'leftValue': leftValue,
    'rightValue': rightValue,
    'isFlipped': isFlipped,
  };

  @override
  String toString() {
    return '[$displayLeftValue|$displayRightValue]';
  }
}
