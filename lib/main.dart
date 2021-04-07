import 'dart:math';
import 'package:flutter/material.dart';
import "package:unorm_dart/unorm_dart.dart" as unorm;

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
        fontFamily: 'NotoSans',
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

  void _addName() {
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

    double diacritical = 0.67;

    name = '${name[0].toUpperCase()}${name.substring(1)}';
    while (random.nextDouble() < diacritical) {
      var index = 1 + random.nextInt(name.length - 1);
      var est = random.nextInt(97);
      var mark = est < 70
        ? 0x0300 + random.nextInt(0x0070)
        : 0x1DC0 + random.nextInt(0x0027);

      name = unorm.nfc(
        unorm.nfd(name)
          .replaceRange(
            index, index, unorm.nfd(
              String.fromCharCode(mark)
            )
          )
        );
      diacritical *= 0.67;
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
        onPressed: _addName,
        tooltip: 'Add New Name',
        child: Icon(Icons.add),
      ),
    );
  }
}
