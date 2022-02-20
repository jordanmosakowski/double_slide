import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/piece.dart';

class PieceWidget extends StatelessWidget {
  const PieceWidget(
    this.piece,
    { 
      Key? key,
      required this.flipText,
      required this.move 
    }) : super(key: key);

  final PuzzlePiece piece;
  final bool flipText;
  final SlideMove? move;

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
        borderRadius: BorderRadius.circular(20),
        color: getColor(piece),
      ),
      child: move != null ? Icon(
          move!.icon,
          size: 45,
          color: piece.color == PuzzleColor.empty ? Colors.white : Colors.black,
        ) : (piece.color != PuzzleColor.empty
      ? Center(
        child: Transform.rotate(
          angle: flipText ? (pi) : 0,
          alignment: FractionalOffset.center,
          child: Text(
            piece.value.toString(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 55
            ),
          )
        ),
      ) : null),
    );
  }
}