import 'dart:math';
import 'package:flutter/material.dart';
import 'package:double_slide/classes/enums.dart';
import 'package:double_slide/classes/piece.dart';

class PieceWidget extends StatelessWidget {
  const PieceWidget(
    this.piece,
    { 
      Key? key,
      required this.flipText,
      required this.move,
      required this.pieceSize
    }) : super(key: key);

  final PuzzlePiece piece;
  final bool flipText;
  final SlideMove? move;
  final double pieceSize;

  Color getColor(PuzzlePiece piece) {
    switch (piece.color) {
      case PuzzleColor.front:
        return Colors.blue;
      case PuzzleColor.back:
        return Colors.green;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(pieceSize * 0.2),
        color: getColor(piece),
      ),
      child: move != null ? Icon(
          move!.icon,
          size: pieceSize * 0.4,
          color: piece.color == PuzzleColor.empty ? Colors.white : Colors.black,
        ) : (piece.color != PuzzleColor.empty
      ? Center(
        child: Transform.rotate(
          angle: flipText ? (pi) : 0,
          alignment: FractionalOffset.center,
          child: Text(
            piece.value.toString(),
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: pieceSize * 0.5
            ),
          )
        ),
      ) : null),
    );
  }
}