import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/domino.dart';
import '../game_internals/player.dart';
import '../style/palette.dart';

class DominoWidget extends StatelessWidget {
  // Dimensions d'un domino martiniquais
  static const double width = 80.0;
  static const double height = 40.0;

  // Dimensions adaptatives selon la largeur d'écran
  static double getAdaptiveWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return width * 0.85; // Réduction de 15% sur petits écrans
    }
    return width;
  }

  static double getAdaptiveHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return height * 0.85; // Réduction de 15% sur petits écrans
    }
    return height;
  }

  final Domino domino;
  final DominoPlayer? player;
  final bool isSelectable;

  const DominoWidget(
    this.domino, {
    this.player,
    this.isSelectable = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    final adaptiveWidth = getAdaptiveWidth(context);
    final adaptiveHeight = getAdaptiveHeight(context);

    final dominoWidget = Container(
      width: adaptiveWidth,
      height: adaptiveHeight,
      decoration: BoxDecoration(
        color: palette.trueWhite,
        border: Border.all(color: palette.ink, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildDominoHalf(domino.displayLeftValue, palette, context),
          Container(
            width: 2,
            height: adaptiveHeight,
            color: palette.ink,
          ),
          _buildDominoHalf(domino.displayRightValue, palette, context),
        ],
      ),
    );

    // Les dominos dans la main du joueur sont sélectionnables
    if (player == null || !isSelectable) return dominoWidget;

    return Draggable<DominoDragData>(
      data: DominoDragData(domino, player!),
      feedback: Transform.rotate(
        angle: 0.05,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: dominoWidget,
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: dominoWidget,
      ),
      onDragStarted: () {
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.huhsh);
      },
      onDragEnd: (details) {
        final audioController = context.read<AudioController>();
        audioController.playSfx(SfxType.wssh);
      },
      child: dominoWidget,
    );
  }

  Widget _buildDominoHalf(int value, Palette palette, BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: Center(
          child: _buildDots(value, palette),
        ),
      ),
    );
  }

  Widget _buildDots(int value, Palette palette) {
    if (value == 0) {
      return Container(); // Vide pour 0
    }

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(9, (index) {
        return Container(
          margin: const EdgeInsets.all(1),
          child: _shouldShowDot(value, index)
              ? Container(
                  decoration: BoxDecoration(
                    color: palette.ink,
                    shape: BoxShape.circle,
                  ),
                )
              : Container(),
        );
      }),
    );
  }

  bool _shouldShowDot(int value, int position) {
    // Positions des points selon la valeur (0-8 dans une grille 3x3)
    switch (value) {
      case 1:
        return position == 4; // Centre
      case 2:
        return position == 0 || position == 8; // Coins opposés
      case 3:
        return position == 0 || position == 4 || position == 8; // Diagonale
      case 4:
        return position == 0 || position == 2 || position == 6 || position == 8; // 4 coins
      case 5:
        return position == 0 || position == 2 || position == 4 || position == 6 || position == 8; // 4 coins + centre
      case 6:
        return position == 0 || position == 2 || position == 3 || position == 5 || position == 6 || position == 8; // 2 colonnes
      default:
        return false;
    }
  }
}

@immutable
class DominoDragData {
  final Domino domino;
  final DominoPlayer holder;

  const DominoDragData(this.domino, this.holder);
}
