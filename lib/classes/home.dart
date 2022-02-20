import 'dart:math';

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

  @override
  void initState(){
    super.initState();
    puzzle.clearMoveOptions();
    _slideController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        puzzle.clearAnimations();
      }
    });
  }

  Widget buildPiece(bool isFront, int i, double faceSize){
    PuzzleFace face = isFront ? puzzle.front : puzzle.back;
    PuzzlePiece piece = face.pieces[i];
    List<SlideMove> moves = face.canMovePiece(piece);
    return TransformedPiece(
      face: face, 
      isFront: isFront, 
      index: i,
      puzzleSize: puzzle.size, 
      slideNone: _slideNone,
      faceSize: faceSize,
      move: puzzle.moveOptions[i],
      onTap: (((puzzle.pieceToMove==null || puzzle.pieceToMove == piece) && moves.isNotEmpty) 
      || puzzle.moveOptions[i] !=null) ?  (){
        setState(() {
          puzzle.pieceTap(face,piece,i,moves,_slideController);
        });
      } : null,
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
        child: LayoutBuilder(
          builder: (context,BoxConstraints constraints) {
            int size = max(min(min(constraints.maxWidth.toInt(),
              constraints.maxHeight.toInt()),700),150);
            double usableSize = size * 0.85;
            return SizedBox(
              width: size.toDouble(),
              height: size.toDouble(),
              child: Stack(
                children: [
                  Positioned(
                    top: 0, left: 0, width: usableSize, height: usableSize,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.all(Radius.circular(usableSize * 0.05)),
                      ),
                    )
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    width: usableSize,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for(int i=0; i<puzzle.size; i++)
                          MoveButton(
                            (){
                                puzzle.flipVertically(i);
                                _flipController.forward(from: 0.0);
                            },
                            Icons.south,
                            iconSize: usableSize / puzzle.size * 0.5,
                          ),
                      ]
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    height: usableSize,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for(int i=0; i<puzzle.size; i++)
                          MoveButton(
                            (){
                              puzzle.flipHorizontally(i);
                              _flipController.forward(from: 0.0);
                            },
                            Icons.east,
                            iconSize: usableSize / puzzle.size * 0.5,
                          ),
                      ],
                    )
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: MoveButton(
                        (){
                          puzzle.flipAll();
                          _flipController.forward(from: 0.0);
                        },
                        Icons.sync,
                        iconSize: usableSize / puzzle.size * 0.5,
                      ),
                  ),
                  for(int i=0; i<puzzle.size * puzzle.size; i++)
                    ...[
                      buildPiece(true,i,usableSize),
                      buildPiece(false,i,usableSize)
                    ],
                ]
              )
            );
          }
        )
      )
    );
  }
}