import 'package:flutter/material.dart';
import 'package:puzzle_hack/home.dart';
import 'package:rive/rive.dart';

class Tutorial extends StatefulWidget {
  const Tutorial({ Key? key }) : super(key: key);

  @override
  State<Tutorial> createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> with TickerProviderStateMixin{

late final AnimationController squishController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 4),
  );

  late Animation<double> frontController = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: squishController, 
      curve: const SquishCurve(true)
    ));

  late Animation<double> backController = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: squishController, 
      curve: const SquishCurve(false)
    ));

  double frontValue = 1;
  double backValue = 0;

  int page = 0;

  @override
  void initState() {
    super.initState();
    frontController.addListener(() { setState(() { frontValue = frontController.value; }); });
    backController.addListener(() { setState(() { backValue = backController.value; }); });
    squishController.repeat();
  }

  @override
  void dispose() {
    squishController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
          ),
          child: ListView(
            children: [
              Center(child: Text("Welcome to Double Slide!", style: Theme.of(context).textTheme.headline3)),
              Center(child: Text("A double sided version of the classic slide puzzle", style: Theme.of(context).textTheme.subtitle1)),
              Container(height: 10),
              Center(child: Text("How to play", style: Theme.of(context).textTheme.headline5)),
              Container(height: 10),
              if(page == 0)
                const Center(child: Text("Like the original puzzle, you can slide tiles around using the empty square as a buffer\n")),
              if(page == 1)
                const Center(child: Text("You can also rotate a row or column to swap tiles between each side of the puzzle")),
              if(page == 1)
                const Center(child: Text("Because of this, it is possible to have two empty squares on one side of the puzzle, and none on the other side")),
              if(page == 2)
                const Center(child: Text("The goal is to place the numbers 1-15 in order on each side of the puzzle\n")),
              Container(height: 10),
              if(page == 0)
                const Center(
                  child: SizedBox(
                    width: 150,
                    height: 150,
                    child: RiveAnimation.asset("assets/anim_slide.riv")
                  ),
                ),
              if(page == 1)
                Center(
                  child: Wrap(
                    spacing: 50,
                    runSpacing: 50,
                    children: const [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: RiveAnimation.asset("assets/anim_row.riv")
                      ),
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: RiveAnimation.asset("assets/anim_col.riv")
                      ),
                    ],
                  ),
                ),
              if(page == 2)
                Center(
                  child: Stack(
                    children: [
                      Transform.scale(
                        scaleX: frontValue,
                        child: const SizedBox(
                          width: 150,
                          height: 150,
                          child: StaticPuzzle(Colors.blue)
                        ),
                      ),
                      Transform.scale(
                        scaleX: backValue,
                        child: const SizedBox(
                          width: 150,
                          height: 150,
                          child: StaticPuzzle(Colors.green)
                        ),
                      ),
                    ],
                  ),
                ),
              Container(height: 10),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(page!=0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: const Text("Back"),
                          onPressed: () {
                            setState(() {
                              page--;
                            });
                          },
                        ),
                      ), 
                    if(page!=2)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: const Text("Next"),
                          onPressed: () {
                            setState(() {
                              page++;
                            });
                          },
                        ),
                      ), 
                    if(page == 2)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          child: const Text("Play"),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Home()));
                          },
                        ),
                      ),
                  ],
                )
              )
            ],
          )
        ),
      )
    );
  }
}

class StaticPuzzle extends StatelessWidget {
  const StaticPuzzle(this.color, { Key? key }) : super(key: key);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      children: [
        for(int i=0; i<15; i++)
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: color,
              ),
              child: Center(
                child: Text(
                  "${i+1}",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }
}

class SquishCurve extends Curve {
  const SquishCurve(this.front);
  final bool front;
  @override
  double transformInternal(double t) {
    if(front){
      if(t<=0.125){
        return t*8;
      }
      if(t<=0.625){
        return 1;
      }
      if(t<=0.75){
        return 1 - (t-0.625)*8;
      }
      return 0;
    }
    if(t<=0.125){
      return 1;
    }
    if(t<=0.25){
      return 1 - (t-0.125)*8;
    }
    if(t<=0.5){
      return 0;
    }
    if(t<=0.625){
      return (t-0.5)*8;
    }
    return 1;
  }
}