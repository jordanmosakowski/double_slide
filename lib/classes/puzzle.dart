import 'package:flutter/cupertino.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:vector_math/vector_math_64.dart';

class Puzzle {
  final int size;
  late PuzzleFace _front;
  late PuzzleFace _back;

  final AnimationController _controller;
  late Animation<double> _rotate;
  

  Puzzle(this.size,this._controller){
    _front = PuzzleFace(size,PuzzleColor.front);
    _back = PuzzleFace(size,PuzzleColor.back);

    _rotate = Tween<double>(
      begin: -180.0,
      end: 0.0,
    ).animate(_controller);
  }

  void clearAnimations(){
    for(PuzzlePiece p in front.pieces) {
      p.rotateAnimation = null;
    }
    for(PuzzlePiece p in back.pieces) {
      p.rotateAnimation = null;
    }
  }

  PuzzleFace get front => _front;
  PuzzleFace get back => _back;

  void applyAnimation(Animation<double> a,Vector3 dir, List<PuzzlePiece> pieces){
    for(PuzzlePiece p in pieces) {
      p.rotateAnimation = a;
      p.direction = dir;
    }
  }

  void flipHorizontally(int row){
    late PuzzlePiece buffer;
    clearAnimations();
    for(int i=0; i<size; i++){
      buffer = front.pieces[row * size + i];
      front.pieces[row * size + i] = back.pieces[row * size + i];
      back.pieces[row * size + i] = buffer;
      applyAnimation(_rotate, Direction.y, [
        front.pieces[row * size + i],back.pieces[row * size + i]
      ]);
    }
  }

  void flipVertically(int col){
    late PuzzlePiece buffer;
    clearAnimations();
    for(int i=0; i<size; i++){
      buffer = front.pieces[i * size + col];
      front.pieces[i * size + col] = back.pieces[(size-i-1) * size + (size-col-1)];
      back.pieces[(size-i-1) * size + (size-col-1)] = buffer;
      applyAnimation(_rotate, Direction.x, [
        front.pieces[i * size + col],back.pieces[(size-i-1) * size + (size-col-1)]
      ]);
    }
  }
  void flipAll(){
    late PuzzlePiece buffer;
    clearAnimations();
    for(int row=0; row<size; row++){
      for(int i=0; i<size; i++){
        buffer = front.pieces[row * size + i];
        front.pieces[row * size + i] = back.pieces[row * size + i];
        back.pieces[row * size + i] = buffer;
        applyAnimation(_rotate, Direction.y, [
          front.pieces[row * size + i],back.pieces[row * size + i]
        ]);
      }
    }
  }

}