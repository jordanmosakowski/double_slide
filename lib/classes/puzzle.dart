import 'package:flutter/cupertino.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:vector_math/vector_math_64.dart';

class Puzzle {
  final int size;
  late PuzzleFace _front;
  late PuzzleFace _back;
  

  Puzzle(this.size){
    _front = PuzzleFace(size,PuzzleColor.front);
    _back = PuzzleFace(size,PuzzleColor.back);
  }

  PuzzleFace get front => _front;
  PuzzleFace get back => _back;

}