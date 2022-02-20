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
    clearMoveOptions();

    _rotate = Tween<double>(
      begin: -180.0,
      end: 0.0,
    ).animate(_controller);
  }

  void shuffle(){
    List<PuzzlePiece> pieces = [...front.pieces,...back.pieces];
    pieces.shuffle();
    for(int i=0; i<pieces.length/2; i++){
      front.pieces[i] = pieces[i];
      back.pieces[i] = pieces[i+pieces.length~/2];
    }
  }

  void clearAnimations(){
    for(PuzzlePiece p in front.pieces) {
      p.rotateAnimation = null;
      p.slideAnimation = null;
    }
    for(PuzzlePiece p in back.pieces) {
      p.rotateAnimation = null;
      p.slideAnimation = null;
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
    clearMoveOptions();
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
    clearMoveOptions();
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
    clearMoveOptions();
  }

  List<SlideMove?> moveOptions = List.empty();
  
  PuzzlePiece? pieceToMove;

  void clearMoveOptions(){
    moveOptions = List.filled(size * size, null);
  }

  void pieceTap(PuzzleFace face, PuzzlePiece piece, int i, List<SlideMove> moves, AnimationController _slideController){
    if(pieceToMove !=null && moveOptions[i]!=null){
      clearAnimations();
      face.movePiece(pieceToMove!,_slideController, moveOptions[i]!);
      clearMoveOptions();
      _slideController.forward(from: 0.0);
      pieceToMove = null;
    }
    else if(pieceToMove == piece){
      clearMoveOptions();
      pieceToMove = null;
    }
    else if(moves.length == 1){
      clearMoveOptions();
      clearAnimations();
      pieceToMove = null;
      face.movePiece(piece, _slideController, moves.first);
      _slideController.forward(from: 0.0);
    }
    else{
      pieceToMove = piece;
      for(SlideMove m in moves){
        if(m == SlideMove.up){
          moveOptions[i-size] = SlideMove.up;
        }
        else if(m == SlideMove.down){
          moveOptions[i+size] = SlideMove.down;
        }
        else if(m == SlideMove.left){
          moveOptions[i-1] = SlideMove.left;
        }
        else if(m == SlideMove.right){
          moveOptions[i+1] = SlideMove.right;
        }
      }
    }
  }
}