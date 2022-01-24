import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:vector_math/vector_math_64.dart';

class PuzzlePiece {
  final int _value;
  final PuzzleColor _color;
  Animation<Offset>? slideAnimation;
  Animation<double>? rotateAnimation;
  Vector3 direction = Direction.x;
  PuzzlePiece(this._color,this._value);

  int get value => _value;
  PuzzleColor get color => _color;
}
