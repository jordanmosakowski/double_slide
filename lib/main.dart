import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:double_slide/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlutterLicense extends LicenseEntry {
  @override
  late final Iterable<String> packages;
  @override
  late final Iterable<LicenseParagraph> paragraphs;

  FlutterLicense(String name, String desc) {
    packages = <String>[name];
    paragraphs = <LicenseParagraph>[LicenseParagraph(desc,0)];
  }
}

Stream<LicenseEntry> licenses() async* {
  yield FlutterLicense('Cubing Icons','''https://github.com/cubing/icons
  
Copyright (c) 2015 Devin Corr-Robinett

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
''');
}
void main() {
  LicenseRegistry.addLicense(licenses);
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
