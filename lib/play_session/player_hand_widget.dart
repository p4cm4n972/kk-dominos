import 'package:flutter/material.dart';

import '../game_internals/player.dart';
import 'domino_widget.dart';

class PlayerHandWidget extends StatelessWidget {
  final DominoPlayer player;
  final bool isHuman;

  const PlayerHandWidget({
    required this.player,
    this.isHuman = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${player.name} (${player.partiesWon}p, ${player.cochons}c)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: isHuman ? FontWeight.bold : FontWeight.normal,
              color: isHuman ? Colors.blue : null,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: ListenableBuilder(
              listenable: player,
              builder: (context, child) {
                if (isHuman) {
                  // Afficher les dominos du joueur humain
                  return Scrollbar(
                    thumbVisibility: player.hand.length > 5,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: IntrinsicWidth(
                        child: Row(
                          children: [
                            ...player.hand.map(
                              (domino) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: DominoWidget(
                                  domino,
                                  player: player,
                                  isSelectable: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Afficher seulement le nombre de dominos pour les adversaires
                  return _buildOpponentHand();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentHand() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${player.hand.length} dominos',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        // Afficher des dos de dominos pour représenter la main
        Scrollbar(
          thumbVisibility: player.hand.length > 8,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: IntrinsicWidth(
              child: Row(
                children: List.generate(
                  player.hand.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: _buildDominoBack(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDominoBack() {
    return Builder(
      builder: (context) {
        return Container(
          width: DominoWidget.getAdaptiveWidth(context) * 0.5,
          height: DominoWidget.getAdaptiveHeight(context) * 0.5,
          decoration: BoxDecoration(
            color: Colors.brown[600],
            border: Border.all(color: Colors.brown[800]!, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.brown[400],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        );
      },
    );
  }
}
