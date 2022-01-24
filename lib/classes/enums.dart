import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

enum PuzzleColor { 
  front,
  back,
  empty
}

enum SlideMove{
  left,
  right,
  up,
  down
}

extension SlideMoveIcon on SlideMove{
  IconData get icon{
    switch(this){
      case SlideMove.left:
        return Icons.arrow_back;
      case SlideMove.right:
        return Icons.arrow_forward;
      case SlideMove.up:
        return Icons.arrow_upward;
      case SlideMove.down:
        return Icons.arrow_downward;
      default:
        return Icons.arrow_back;
    }
  }
}