import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:puzzle_hack/classes/puzzle.dart';
import 'package:puzzle_hack/move_button.dart';
import 'package:puzzle_hack/size_icons.dart';
import 'package:puzzle_hack/transformed_piece.dart';

class Home extends StatefulWidget {
  const Home({ Key? key }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin{
  late Puzzle puzzle;

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
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    puzzle = Puzzle(4,_flipController);
    puzzle.shuffle();
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

  List<IconData> sizeIcons = [SizeIcons.size3,SizeIcons.size4,
    SizeIcons.size5,SizeIcons.size6,SizeIcons.size7];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Flutter Puzzle Hack', style: Theme.of(context).textTheme.headline4,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for(int i=0; i<sizeIcons.length; i++)
                Opacity(
                  opacity: i+3 == puzzle.size ? 1.0 : 0.5,
                  child: IconButton(
                    tooltip: "${i+3}x${i+3} Puzzle",
                    iconSize: 50,
                    icon: Icon(sizeIcons[i]),
                    onPressed: (){
                      setState(() {
                        puzzle = Puzzle(i+3,_flipController);
                        puzzle.shuffle();
                      });
                    },
                  ),
                )
            ],
          ),
          Text(puzzle.isSolved() ? "Solved" : "Not solved"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: LayoutBuilder(
                  builder: (context,BoxConstraints constraints) {
                    int size = max(min(min(constraints.maxWidth.toInt(),
                     constraints.maxHeight.toInt()),700),150);
                    // int size = 500;
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
                            top: usableSize,
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
                                    iconSize: min(80,usableSize / puzzle.size * 0.5),
                                  ),
                              ]
                            ),
                          ),
                          Positioned(
                            left: usableSize,
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
                                    iconSize: min(80,usableSize / puzzle.size * 0.5),
                                  ),
                              ],
                            )
                          ),
                          Positioned(
                            left: usableSize,
                            top: usableSize,
                            child: MoveButton(
                                (){
                                  puzzle.flipAll();
                                  _flipController.forward(from: 0.0);
                                },
                                Icons.sync,
                                iconSize: min(80,usableSize / puzzle.size * 0.5),
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
              ),
            ),
          ),
        ],
      )
    );
  }
}