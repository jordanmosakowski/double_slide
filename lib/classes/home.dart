
import 'package:flutter/material.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:puzzle_hack/classes/puzzle.dart';
import 'package:puzzle_hack/move_button.dart';
import 'package:puzzle_hack/transformed_piece.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin{
  late Puzzle puzzle = Puzzle(4,_flipController);

  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  )..addListener(() {
    setState(() {});
  });

  late final Animation<Offset> _slideNone = Tween<Offset>(
    begin: Offset.zero,
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _slideController,
    curve: Curves.easeInOut,
  ));

  List<SlideMove?> moveOptions = List.empty();

  @override
  void initState(){
    super.initState();
    clearMoveOptions();
    _slideController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        puzzle.clearAnimations();
      }
    });
  }
  
  PuzzlePiece? pieceToMove;

  void clearMoveOptions(){
    moveOptions = List.filled(puzzle.size * puzzle.size, null);
  }

  void pieceTap(PuzzleFace face, PuzzlePiece piece, int i, List<SlideMove> moves){
    setState((){
      // print("Tapped ${piece.color} ${piece.value}");
      if(pieceToMove !=null && moveOptions[i]!=null){
        puzzle.clearAnimations();
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
        puzzle.clearAnimations();
        pieceToMove = null;
        face.movePiece(piece, _slideController, moves.first);
        _slideController.forward(from: 0.0);
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
  }

  Widget buildPiece(bool isFront, int i){
    PuzzleFace face = isFront ? puzzle.front : puzzle.back;
    PuzzlePiece piece = face.pieces[i];
    List<SlideMove> moves = face.canMovePiece(piece);
    return TransformedPiece(
      face: face, 
      isFront: isFront, 
      index: i,
      puzzleSize: puzzle.size, 
      slideNone: _slideNone,
      move: moveOptions[i],
      onTap: (((pieceToMove==null || pieceToMove == piece) && moves.isNotEmpty) || moveOptions[i] !=null) ? 
          (){pieceTap(face,piece,i,moves);} : null,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Puzzle Hack'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: (){
              setState(() {
                puzzle.shuffle();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 450,
          height: 450,
          child: Stack(
            children: [
              Positioned(
                top: 0, left: 0, width: 400, height: 400,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                )
              ),
              for(int i=0; i<puzzle.size; i++)
                MoveButton(
                  (){
                      puzzle.flipVertically(i);
                      clearMoveOptions();
                      _flipController.forward(from: 0.0);
                  },
                  Icons.south,
                  bottom: 0,
                  left: i * 400 / puzzle.size + 25,
                ),
              for(int i=0; i<puzzle.size; i++)
                MoveButton(
                  (){
                    puzzle.flipHorizontally(i);
                    clearMoveOptions();
                    _flipController.forward(from: 0.0);
                  },
                  Icons.east,
                  top: i * 400 / puzzle.size + 25,
                  right: 0,
                ),
              MoveButton(
                  (){
                    puzzle.flipAll();
                    clearMoveOptions();
                    _flipController.forward(from: 0.0);
                  },
                  Icons.sync,
                  bottom: 0,
                  right: 0,
                ),
                for(int i=0; i<puzzle.size * puzzle.size; i++)
                  ...[
                    buildPiece(true,i),
                    buildPiece(false,i)
                  ],
            ]
          )
        )
      )
    );
  }
}