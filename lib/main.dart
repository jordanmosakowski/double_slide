import 'dart:math';

import 'package:flutter/material.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
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

class _HomeState extends State<Home> with TickerProviderStateMixin{
  late Puzzle puzzle = Puzzle(4,_flipController);



  late final AnimationController _slideController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );

  late final AnimationController _flipController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
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
    _slideController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        puzzle.front.clearAnimations();
      }
    });
  }
  
  PuzzlePiece? pieceToMove;

  void clearMoveOptions(){
    moveOptions = List.filled(puzzle.size * puzzle.size, null);
  }

  Matrix4 getPieceRotation(PuzzleFace face, int index){
    const double faceSize = 400;
    final double pieceSize = faceSize / puzzle.size;
    double pieceX = (index % puzzle.size) * pieceSize + pieceSize/2 - faceSize/2;
    double pieceY = (index/puzzle.size).floor() * pieceSize + pieceSize/2 - faceSize/2;

    PuzzlePiece piece = face.pieces[index];
    double pieceAnim = piece.rotateAnimation?.value.toDouble() ?? 0.0;

    Matrix4 translate1 = Matrix4.translation(vec.Vector3(pieceX, pieceY,0));
    Matrix4 translate2 = Matrix4.translation(vec.Vector3(150, 150, 0));
    Matrix4 rotateY = Matrix4.identity()..rotate(vec.Vector3(0,1,0), (face == puzzle.back ? 180: 0) * pi / 180);
    Matrix4 rotateFlip = Matrix4.identity()..rotate(piece.direction, pieceAnim * pi / 180);

    return translate2 * rotateFlip * rotateY * translate1;
  }


  bool visible(Matrix4 rotation){
    return rotation.forward.z>0;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Puzzle Hack'),
        actions: [
          IconButton(
            icon: Icon(Icons.rotate_90_degrees_ccw),
            onPressed: (){
              setState(() {
                puzzle.flipVertically(3);
                _flipController.forward(from: 0.0);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              setState(() {
                puzzle.flipHorizontally(3);
                _flipController.forward(from: 0.0);
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.flip),
            onPressed: (){
              setState(() {
                puzzle.flipAll();
                _flipController.forward(from: 0.0);
              });
            },
          )
        ],
      ),
      body: Center(
        child: Container(
          // color: Colors.blue[800],
          child: SizedBox(
            width: 400,
            height: 400,
            child: Stack(
              children: [...puzzle.front.pieces,...puzzle.back.pieces].asMap().keys.map((int index) {
                int i = index % (puzzle.size * puzzle.size);
                PuzzleFace face = (i==index ? puzzle.front : puzzle.back);
                PuzzlePiece piece = face.pieces[i];
                bool flipText = (piece.rotateAnimation?.value.toDouble() ?? 0.0) < -90 && piece.direction == Direction.x;
                List<SlideMove> moves = face.canMovePiece(piece);
                Matrix4 rotation = getPieceRotation(face,i);
                if(!visible(rotation)){
                  return Container();
                }
                return Transform(
                  transform: rotation,
                  alignment: FractionalOffset.center,
                  child: SlideTransition(
                    position: piece.slideAnimation ?? _slideNone,
                    child: SizedBox(
                      width: 400 / puzzle.size,
                      height: 400 / puzzle.size,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: InkWell(
                          onTap: (((pieceToMove==null || pieceToMove == piece) && moves.isNotEmpty) || moveOptions[i] !=null) ? (){
                            setState((){
                              // print("Tapped ${piece.color} ${piece.value}");
                              if(pieceToMove !=null && moveOptions[i]!=null){
                                face.movePiece(pieceToMove!,_slideController, moveOptions[i]!);
                                clearMoveOptions();
                                _slideController.forward(from: 0.0);
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
                                    child: Transform.rotate(
                                      angle: flipText ? (pi) : 0,
                                      alignment: FractionalOffset.center,
                                      child: Text(piece.value.toString())
                                    ),
                                ) : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList()
            )
          ),
        )
      )
    );
  }
}