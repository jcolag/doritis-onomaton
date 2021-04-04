import 'dart:math';
import 'package:flutter/material.dart';

List<String> consonants = [
  'b',
  'c',
  'ch',
  'cl',
  'cr',
  'd',
  'f',
  'g',
  'gh',
  'gl',
  'gr',
  'h',
  'j',
  'k',
  'l',
  'm',
  'mn',
  'n',
  'p',
  'ph',
  'pl',
  'pr',
  'q',
  'qu',
  'r',
  's',
  'sc',
  'sch',
  'scr',
  'sh',
  'sl',
  'sp',
  'spl',
  'spr',
  'st',
  'str',
  't',
  'th',
  'thr',
  'tr',
  'v',
  'w',
  'x',
  'y',
  'z',
];
List<String> vowels = [
  'a',
  'e',
  'i',
  'o',
  'u'
];
var random = Random();

void main() {
  runApp(NameGiver());
}

class NameGiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doritís Onomáton',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: NameGiverHome(title: 'Doritís Onomáton Name List'),
    );
  }
}

class NameGiverHome extends StatefulWidget {
  NameGiverHome({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _NameGiverState createState() => _NameGiverState();
}

class _NameGiverState extends State<NameGiverHome> {
  List<Text> _names = [];

  void _incrementCounter() {
    setState(() {
      _names.add(_generateName());
    });
  }

  Text _generateName() {
    double done = 1;
    String name = '';

    while (random.nextDouble() < done || name.length < 3) {
      String onset = consonants[random.nextInt(consonants.length)];
      String nucleus = vowels[random.nextInt(vowels.length)];
      String coda = consonants[random.nextInt(consonants.length)];

      if (random.nextInt(2) == 0) {
        name += onset;
      }

      name += nucleus;
      if (random.nextInt(4) < 3) {
        name += coda;
      }

      done *= 0.67;
    }

    return Text(
      '${name[0].toUpperCase()}${name.substring(1)}',
      style: TextStyle(
        fontSize: 36.0,
        height: 1.6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _names,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
