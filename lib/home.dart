import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:puzzle_hack/classes/enums.dart';
import 'package:puzzle_hack/classes/face.dart';
import 'package:puzzle_hack/classes/piece.dart';
import 'package:puzzle_hack/classes/puzzle.dart';
import 'package:puzzle_hack/move_button.dart';
import 'package:puzzle_hack/size_icons.dart';
import 'package:puzzle_hack/transformed_piece.dart';
import 'package:puzzle_hack/welcome.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    puzzle = Puzzle(0,_flipController);
    puzzle.shuffle();
    puzzle.clearMoveOptions();
    loadWelcome();
    _slideController.addStatusListener((status) { 
      if (status == AnimationStatus.completed) {
        puzzle.clearAnimations();
      }
    });
  }

  bool showWelcome = false;

  loadWelcome() async{
    final prefs = await SharedPreferences.getInstance();
    // prefs.setBool('hasShownWelcome', false);
    bool hasShownWelcome = prefs.getBool('hasShownWelcome') ?? false;
    setState(() {
    if(!hasShownWelcome){
      prefs.setBool('hasShownWelcome', true);
      showWelcome = true;
    }
      puzzle = Puzzle.fromSave(prefs, _flipController);
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
    SharedPreferences? prefs = context.watch<SharedPreferences?>();
    if(prefs!=null && puzzle.isSolved()){
      int best = prefs.getInt('pb${puzzle.size}') ?? -1;
      if(puzzle.moves < best || best == -1){
        prefs.setInt('pb${puzzle.size}', puzzle.moves);
      }
    }
    if(prefs!=null && puzzle.prefs == null){
      puzzle.prefs = prefs;
    }
    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
          child: showWelcome ? WelcomePage((){setState(() {
            showWelcome = false;
          });}) : Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: AppBar(
                  backgroundColor: Colors.black,
                  centerTitle: true,
                  title: Text("Double Slide", style: Theme.of(context).textTheme.headline4?.copyWith(
                    color: Colors.white
                  )),
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset("assets/logo_transparent.png"),
                  ),
                  actions: [
                    IconButton(
                      onPressed: (){
                        setState(() {
                          showWelcome = true;
                        });
                      }, 
                      icon: const Icon(Icons.help_outline),
                      tooltip: "View Tutorial",
                    ),
                    IconButton(
                      onPressed: (){
                        showAboutDialog(
                          context: context,
                          applicationName: "Double Slide",
                          applicationVersion: "version 1.0.0",
                          applicationLegalese: "Developed for the 2022 Flutter Puzzle Hack competition",
                        );
                      }, 
                      icon: const Icon(Icons.info_outline),
                      tooltip: "App Information",
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              SizeIconsWidget(puzzle.size, (newSize){
                  setState(() {
                    SharedPreferences? prefs = context.read<SharedPreferences?>();
                    if(prefs==null){
                      puzzle = Puzzle(newSize,_flipController);
                      puzzle.shuffle();
                    }
                    else{
                      prefs.setInt("current_size",newSize);
                      puzzle = Puzzle.fromSaveSize(newSize,prefs, _flipController);
                    }
                  });
                },
              ),
              Text("Moves: ${puzzle.moves}", style: Theme.of(context).textTheme.headline5),
              ElevatedButton(
                onPressed: (){
                  setState(() {
                    puzzle.shuffle();
                  });
                }, 
                child: Text("Shuffle")
              ),
              Expanded(
                child: AbsorbPointer(
                  absorbing: puzzle.isSolved(),
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
                                          iconSize: min(40,usableSize / puzzle.size * 0.5),
                                          tooltip: "Flip Column ${i+1}",
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
                                          iconSize: min(40,usableSize / puzzle.size * 0.5),
                                          tooltip: "Flow Row ${i+1}",
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
                                      iconSize: min(40,usableSize / puzzle.size * 0.5),
                                      tooltip: "Flip Puzzle"
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
              ),
            ],
          ),
        ),
      )
    );
  }
}