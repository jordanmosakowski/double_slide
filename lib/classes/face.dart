import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/piece.dart';

class PuzzleFace {
  final PuzzleColor _solvedColor;
  late List<PuzzlePiece> _pieces;
  final int _size;
  Animation<double>? animation;

  PuzzleFace(this._size,this._solvedColor) {
    _pieces = List.generate(
        _size*_size,
        (i) => i == _size*_size - 1
          ? PuzzlePiece(PuzzleColor.empty, 0)
          : PuzzlePiece(_solvedColor, i + 1),
        growable: false);
      // _pieces.shuffle();
  }

  void clearAnimations(){
    for (PuzzlePiece piece in _pieces) {
      piece.slideAnimation = null;
    }
  }

  PuzzleColor get solvedColor => _solvedColor;
  List<PuzzlePiece> get pieces => _pieces;
  
  int get size => _size;

  List<SlideMove> canMovePiece(PuzzlePiece p){
    if(p.color == PuzzleColor.empty){
      return List.empty();
    }
    int index = _pieces.indexOf(p);
    List<int> empty = _pieces.where((piece) => piece.color == PuzzleColor.empty).map((p) => _pieces.indexOf(p)).toList();
    List<SlideMove> moves = List.empty(growable: true);
    for(int e in empty){
      int difference = index - e;
      int direction = difference > 0 ? 1 : -1;
      if(difference.abs() % _size == 0){
        moves.add(direction == 1 ? SlideMove.up : SlideMove.down);
      }
      if((index/_size).floor() == (e/_size).floor()){
        moves.add(direction == 1 ? SlideMove.left : SlideMove.right);
      }
    }
    return moves.toSet().toList();
  }

  void movePiece(PuzzlePiece p,AnimationController? controller, SlideMove move){
    clearAnimations();
    if(canMovePiece(p).isEmpty){
      return;
    }
    int index = _pieces.indexOf(p);
    int emptyIndex = -1;
    int direction = (move == SlideMove.up || move == SlideMove.left) ? 1 : -1;
  
    //Move across the same row
    if(move == SlideMove.left || move == SlideMove.right){
      for(int i=index; (i/size).floor() == (index/size).floor(); i-=direction){
        if(_pieces[i].color == PuzzleColor.empty){
          emptyIndex = i;
          break;
        }
      }
      if(emptyIndex == -1){
        return;
      }
      PuzzlePiece empty = _pieces[emptyIndex];
      for(int i=emptyIndex; i!=index; i+=direction){
        _pieces[i] = _pieces[i+direction];
        _pieces[i].slideAnimation = controller != null ? Tween<Offset>(
            begin: Offset(direction.toDouble(), 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
          )) : null;
      }
      _pieces[index] = empty;
    }
    else{
      //Move across the same column
      for(int i=index; i>=0 && i<size*size; i-=size*direction){
        if(_pieces[i].color == PuzzleColor.empty){
          emptyIndex = i;
          break;
        }
      }
      if(emptyIndex == -1){
        return;
      }
      PuzzlePiece empty = _pieces[emptyIndex];
      for(int i=emptyIndex; i!=index; i+=_size*direction){
        _pieces[i] = _pieces[i+_size*direction];
        _pieces[i].slideAnimation = controller !=null ? Tween<Offset>(
            begin: Offset(0.0, direction.toDouble()),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: controller,
            curve: Curves.easeInOut,
          )) : null;
      }
      _pieces[index] = empty;
    }
  }
}
