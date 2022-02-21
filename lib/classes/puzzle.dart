import 'package:flutter/cupertino.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math_64.dart';

class Puzzle {
  final int size;
  late PuzzleFace _front;
  late PuzzleFace _back;

  final AnimationController _controller;
  late Animation<double> _rotate;

  SharedPreferences? prefs;

  int _moves = 0;

  int get moves => _moves;
  
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
    _moves = 0;
    saveState();
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
    _moves++;
    saveState();
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
    _moves++;
    saveState();
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
      pieceToMove = null;
  }

  void pieceTap(PuzzleFace face, PuzzlePiece piece, int i, List<SlideMove> moves, AnimationController _slideController){
    if(pieceToMove !=null && moveOptions[i]!=null){
      clearAnimations();
      face.movePiece(pieceToMove!,_slideController, moveOptions[i]!);
      _moves++;
      saveState();
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
      _moves++;
      saveState();
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

  bool isSolved(){
    for(int i=0; i<size * size; i++){
      if(i==size*size-1){
        if(front.pieces[i].color != PuzzleColor.empty || back.pieces[i].color != PuzzleColor.empty){
          return false;
        }
        continue;
      }
      if(front.pieces[i].value != i+1 || front.pieces[i].color != front.pieces.first.color){
        return false;
      }
      if(back.pieces[i].value != i+1 || back.pieces[i].color != back.pieces.first.color){
        return false;
      }
    }
    return true;
  }

  void saveState(){
    if(prefs==null){
      return;
    }
    prefs!.setInt("current_size",size);
    prefs!.setBool("save_$size",true);
    prefs!.setInt("save_moves_$size",_moves);
    List<String> frontState = front.pieces.map((PuzzlePiece p){
      if(p.color == PuzzleColor.empty){
        return "e";
      }
      return (p.color == PuzzleColor.front ? "f" : "b")+p.value.toString();
    }).toList();
    prefs!.setStringList("save_front_$size",frontState);
    List<String> backState = back.pieces.map((PuzzlePiece p){
      if(p.color == PuzzleColor.empty){
        return "e";
      }
      return (p.color == PuzzleColor.front ? "f" : "b")+p.value.toString();
    }).toList();
    prefs!.setStringList("save_back_$size",backState);
  }

  factory Puzzle.fromSave(SharedPreferences prefs, AnimationController controller){
    int? size = prefs.getInt("current_size");
    if(size == null){
      return Puzzle.standard(4,prefs,controller);
    }
    return Puzzle.fromSaveSize(size, prefs, controller);
  }

  factory Puzzle.fromSaveSize(int size, SharedPreferences prefs, AnimationController controller){
    if(prefs.getBool("save_$size") == null){
      return Puzzle.standard(size,prefs,controller);
    }
    int moves = prefs.getInt("save_moves_$size") ?? 0;
    List<String> frontState = prefs.getStringList("save_front_$size") ?? List.filled(size*size,"e");
    List<String> backState = prefs.getStringList("save_back_$size") ?? List.filled(size*size,"e");
    if(frontState.length != size*size || backState.length != size*size){
      return Puzzle.standard(size,prefs,controller);
    }
    Puzzle puzzle = Puzzle(size,controller);
    puzzle.prefs = prefs;
    puzzle._moves = moves;
    for(int i=0; i<size*size; i++){
      PuzzlePiece frontPiece = PuzzlePiece.fromString(frontState[i]);
      PuzzlePiece backPiece = PuzzlePiece.fromString(backState[i]);
      puzzle.front.pieces[i] = frontPiece;
      puzzle.back.pieces[i] = backPiece;
    }
    return puzzle;
  }

  void destroySave(){
    if(prefs==null){
      return;
    }
    prefs!.remove("save_size_$size");
    prefs!.remove("save_moves_$size");
    prefs!.remove("save_front_$size");
    prefs!.remove("save_back_$size");
  }

  factory Puzzle.standard(int size, SharedPreferences prefs,AnimationController controller){
    Puzzle p = Puzzle(size,controller);
      p.prefs = prefs;
      p.shuffle();
      return p;
  }
}