import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:puzzle_hack/piece.dart';

import 'package:vector_math/vector_math_64.dart' as vec;

class TransformedPiece extends StatelessWidget {
  const TransformedPiece({
    required this.face, 
    required this.isFront, 
    required this.index, 
    required this.puzzleSize,
    required this.slideNone,
    required this.move,
    required this.onTap,
    Key? key }) : super(key: key);
  final PuzzleFace face;
  final bool isFront;
  final int index;
  final int puzzleSize;
  final Animation<Offset> slideNone;
  final VoidCallback? onTap;
  final SlideMove? move;

  Matrix4 getPieceRotation(PuzzleFace face, int index){
    const double faceSize = 400;
    final double pieceSize = faceSize / puzzleSize;
    double pieceX = (index % puzzleSize) * pieceSize + pieceSize/2 - faceSize/2;
    double pieceY = (index/puzzleSize).floor() * pieceSize + pieceSize/2 - faceSize/2;

    PuzzlePiece piece = face.pieces[index];
    double pieceAnim = piece.rotateAnimation?.value.toDouble() ?? 0.0;

    Matrix4 translate1 = Matrix4.translation(vec.Vector3(pieceX, pieceY,0));
    Matrix4 translate2 = Matrix4.translation(vec.Vector3(150, 150, 0));
    Matrix4 rotateY = Matrix4.identity()..rotate(vec.Vector3(0,1,0), (isFront ? 0 : 180) * pi / 180);
    Matrix4 rotateFlip = Matrix4.identity()..rotate(piece.direction, pieceAnim * pi / 180);

    return translate2 * rotateFlip * rotateY * translate1;
  }


  bool visible(Matrix4 rotation){
    return rotation.forward.z>0;
  }

  @override
  Widget build(BuildContext context) {
    Matrix4 rotation = getPieceRotation(face,index);
    if(!visible(rotation)){
      return Container();
    }
    PuzzlePiece piece = face.pieces[index];
    bool flipText = (piece.rotateAnimation?.value.toDouble() ?? 0.0) < -90 && piece.direction == Direction.x;
    return Transform(
      transform: rotation,
      alignment: FractionalOffset.center,
      child: SlideTransition(
        position: piece.slideAnimation ?? slideNone,
        child: SizedBox(
          width: 400 / puzzleSize,
          height: 400 / puzzleSize,
          child: Padding(
            padding: const EdgeInsets.all(7.0),
            child: InkWell(
              onTap: onTap,
              child: PieceWidget(
                piece,
                flipText: flipText,
                move: move,
              )
            ),
          ),
        ),
      ),
    );
  }
}