import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  final ScrollController _scrollController = ScrollController();
  bool _needsScroll = false;
  List<String> _names = [];

  void _scrollToEnd() async {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut
    );
    _needsScroll = false;
  }

  void _addName() {
    _needsScroll = true;
    setState(() {
      _names.add(_generateName());
    });
  }

  void _replaceName() {
    if (_names.length == 0) {
      return;
    }

    _names.removeLast();
    _addName();
  }

  void _removeName() {
    if (_names.length == 0) {
      return;
    }

    setState(() {
      _names.removeLast();
    });
  }

  String _generateName() {
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

    return name;
  }

  @override
  Widget build(BuildContext context) {
    if (_needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _scrollToEnd()
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return Dismissible(
            background: Container(color: Colors.lightBlue),
            child: ListTile(
              title: Text(
                _names[index],
                style: TextStyle(
                  fontSize: 48.0,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
            ),
            key: Key(_names[index]),
            onDismissed: (direction) {
              if (direction == DismissDirection.startToEnd) {
                String name = _names[index];

                setState(() {
                  _names.removeAt(index);
                });
                ScaffoldMessenger
                  .of(context)
                  .showSnackBar(
                    SnackBar(
                      content: Text(
                        '${name} deleted.',
                        style: TextStyle(
                          color: Colors.red,
                          fontFamily: 'NotoSans',
                          fontSize: 24.0,
                        ),
                      )
                    )
                  );
              } else if (direction == DismissDirection.endToStart) {
                String name = _names[index];
                const String baseUrl = 'https://ptsv2.com/t/dkz4n-1618189548/post';
                var payload = { name: name };
                var response = http.post(baseUrl, body: payload);

                setState(() {
                  _names.removeAt(index);
                });
                ScaffoldMessenger
                  .of(context)
                  .showSnackBar(
                    SnackBar(
                      content: Text(
                        '${name} saved to server.',
                        style: TextStyle(
                          color: Colors.lightGreen,
                          fontFamily: 'NotoSans',
                          fontSize: 24.0,
                        ),
                      )
                    )
                  );
              }
            },
          );
        },
        itemCount: _names.length,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _removeName,
            tooltip: 'Forget Last Name',
            child: Icon(Icons.not_interested),
          ),
          FloatingActionButton(
            onPressed: _replaceName,
            tooltip: 'Replace Last Name',
            child: Icon(Icons.refresh_sharp),
          ),
          FloatingActionButton(
            onPressed: _addName,
            tooltip: 'Add New Name',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
