import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:double_slide/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Double Slide',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.oxygenTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme
        ),
      ),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        textTheme: GoogleFonts.oxygenTextTheme(
          ThemeData(brightness: Brightness.light).textTheme
        ),
      ),
      home: FutureProvider<SharedPreferences?>(
        create: (_) => SharedPreferences.getInstance(),
        initialData: null,
        child: const Home()
      ),
    );
  }
}
