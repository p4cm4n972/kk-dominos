import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_state.dart';
import '../game_internals/dominoes_table.dart';
import '../style/palette.dart';
import 'domino_widget.dart';

class DominoesTableWidget extends StatelessWidget {
  const DominoesTableWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final boardState = context.watch<DominosBoardState>();
    final palette = context.watch<Palette>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: palette.backgroundPlaySession,
        border: Border.all(color: palette.ink),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListenableBuilder(
        listenable: boardState.game.table,
        builder: (context, child) {
          if (boardState.game.table.isEmpty) {
            return SizedBox(
              height: 80,
              child: Center(
                child: Text(
                  'Placez le premier domino ici',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.ink.withOpacity(0.6),
                  ),
                ),
              ),
            );
          }

          return SizedBox(
            height: 80,
            child: Scrollbar(
              thumbVisibility: boardState.game.table.dominosOnTable.length > 3,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicWidth(
                  child: Row(
                    children: [
                      // Zone de dépôt à gauche
                      _buildDropZone(
                        context,
                        DominoPosition.left,
                        palette,
                        boardState.game.table.leftConnection,
                      ),
                      const SizedBox(width: 6),

                      // Dominos sur la table
                      ...boardState.game.table.dominosOnTable.map(
                        (domino) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1),
                          child: DominoWidget(domino),
                        ),
                      ),

                      const SizedBox(width: 6),
                      // Zone de dépôt à droite
                      _buildDropZone(
                        context,
                        DominoPosition.right,
                        palette,
                        boardState.game.table.rightConnection,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropZone(
    BuildContext context,
    DominoPosition position,
    Palette palette,
    int? connection,
  ) {
    final boardState = context.watch<DominosBoardState>();

    return DragTarget<DominoDragData>(
      onAccept: (data) {
        // TODO: Implémenter la logique de placement
        boardState.game.playDomino(data.domino, position);
      },
      onWillAccept: (data) {
        if (data == null) return false;
        return boardState.game.table.canPlaceDomino(data.domino);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;

        return Container(
          width: DominoWidget.getAdaptiveWidth(context) * 0.8,
          height: DominoWidget.getAdaptiveHeight(context),
          decoration: BoxDecoration(
            color: isHighlighted
                ? palette.ink.withOpacity(0.1)
                : Colors.transparent,
            border: Border.all(
              color: palette.ink.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  position == DominoPosition.left
                      ? Icons.arrow_back
                      : Icons.arrow_forward,
                  color: palette.ink.withOpacity(0.5),
                  size: 16,
                ),
                if (connection != null)
                  Text(
                    connection.toString(),
                    style: TextStyle(
                      color: palette.ink.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}