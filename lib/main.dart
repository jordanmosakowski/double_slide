import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:puzzle_hack/classes/home.dart';
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
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        textTheme: GoogleFonts.oxygenTextTheme(
          Theme.of(context).textTheme.copyWith(
            headline4: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
          ),
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.oxygenTextTheme(
          Theme.of(context).textTheme.copyWith(
            headline4: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )
          ),
        ),
      ),
      home: const Home(),
    );
  }
}
