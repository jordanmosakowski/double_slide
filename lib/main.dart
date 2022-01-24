import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:puzzle_hack/classes/puzzle.dart';
import 'package:vector_math/vector_math_64.dart' as vec;

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle Hack',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin{
  late Puzzle puzzle = Puzzle(4);



  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final Animation<Offset> _animationNone = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  ));

  List<SlideMove?> moveOptions = List.empty();

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
  void initState(){
    super.initState();
    clearMoveOptions();
    _animationController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        puzzle.front.clearAnimations();
      }
    });
  }
  
  PuzzlePiece? pieceToMove;

  void clearMoveOptions(){
    moveOptions = List.filled(puzzle.size * puzzle.size, null);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Puzzle Hack'),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: GridView.count(
            crossAxisCount: puzzle.size,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
            children: puzzle.front.pieces.asMap().keys.map((int i) {
              PuzzlePiece piece = puzzle.front.pieces[i];
              List<SlideMove> moves = puzzle.front.canMovePiece(piece);
              return SlideTransition(
                position: piece.slideAnimation ?? _animationNone,
                child: SizedBox(
                  width: 200 / puzzle.size,
                  height: 200 / puzzle.size,
                  child: InkWell(
                    onTap: (((pieceToMove==null || pieceToMove == piece) && moves.isNotEmpty) || moveOptions[i] !=null) ? (){
                      setState((){
                        print("Tapped ${piece.color} ${piece.value}");
                        if(pieceToMove !=null && moveOptions[i]!=null){
                          puzzle.front.movePiece(pieceToMove!,_animationController, moveOptions[i]!);
                          clearMoveOptions();
                          _animationController.forward(from: 0.0);
                          pieceToMove = null;
                          return;
                        }
                        if(pieceToMove == piece){
                          clearMoveOptions();
                          pieceToMove = null;
                          return;
                        }
                        if(moves.length == 1){
                          clearMoveOptions();
                          pieceToMove = null;
                          puzzle.front.movePiece(piece, _animationController, moves.first);
                          _animationController.forward(from: 0.0);
                        }
                        else{
                          pieceToMove = piece;
                          for(SlideMove m in moves){
                            if(m == SlideMove.up){
                              moveOptions[i-4] = SlideMove.up;
                            }
                            else if(m == SlideMove.down){
                              moveOptions[i+4] = SlideMove.down;
                            }
                            else if(m == SlideMove.left){
                              moveOptions[i-1] = SlideMove.left;
                            }
                            else if(m == SlideMove.right){
                              moveOptions[i+1] = SlideMove.right;
                            }
                          }
                        }
                      });
                    } : null,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: getColor(piece),
                      ),
                      child: moveOptions[i] != null ? Icon(
                                moveOptions[i]!.icon,
                                color: Colors.black,
                              ) : (piece.color != PuzzleColor.empty
                          ? Center(
                              child: Text(piece.value.toString()),
                          ) : null),
                    ),
                  ),
                ),
              );
            }).toList()
          )
        )
      )
    );
  }
}