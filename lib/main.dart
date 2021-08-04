import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:unorm_dart/unorm_dart.dart' as unorm;

import 'alphabets.dart' as alphabets;

const consonants = alphabets.consonants;
const vowels = alphabets.vowels;
const server = 'http://localhost:3000/';
var random = Random();

void main() async {
  await GetStorage.init();
  runApp(NameGiver());
}

class Preferences extends GetxController {
  final storage = GetStorage();
  String get apiKey => storage.read('apiKey') ?? '';
  void newApiKey(String val) => storage.write('apiKey', val);
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
      home: NameGiverHome(title: 'Doritís Onomáton Namer'),
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
  bool _useDiacriticals = true;
  bool _showSaved = false;
  String _chosenLanguage = 'Latin';
  List<String> _names = [];
  List<String> _savedNames = [];
  final prefController = Get.put(Preferences());

  void _scrollToEnd() async {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200), curve: Curves.easeInOut);
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
      String onset = consonants[_chosenLanguage]
          [random.nextInt(consonants[_chosenLanguage].length)];
      String nucleus = vowels[_chosenLanguage]
          [random.nextInt(vowels[_chosenLanguage].length)];
      String coda = consonants[_chosenLanguage]
          [random.nextInt(consonants[_chosenLanguage].length)];

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
    if (_useDiacriticals) {
      while (random.nextDouble() < diacritical) {
        var index = 1 + random.nextInt(name.length - 1);
        var est = random.nextInt(97);
        var mark = est < 70
            ? 0x0300 + random.nextInt(0x0070)
            : 0x1DC0 + random.nextInt(0x0027);

        name = unorm.nfc(unorm
            .nfd(name)
            .replaceRange(index, index, unorm.nfd(String.fromCharCode(mark))));
        diacritical *= 0.67;
      }
    }

    return name;
  }

  @override
  Widget build(BuildContext context) {
    List<String> nameSource;

    if (_needsScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }

    nameSource = _showSaved ? _savedNames : _names;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Container(
            child: DropdownButton<String>(
              value: _chosenLanguage,
              items: vowels.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String value) {
                setState(() {
                  _chosenLanguage = value;
                });
              },
            ),
            margin: EdgeInsets.only(right: 30.0),
          ),
          PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _useDiacriticals = !_useDiacriticals;
                    });
                    Navigator.pop(context);
                  },
                  title: Text('Use diacritical marks'),
                  value: _useDiacriticals,
                ),
              ),
              PopupMenuItem(
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (value) {
                    setState(() {
                      _showSaved = !_showSaved;
                    });
                    Navigator.pop(context);
                  },
                  title: Text('Show Saved Names'),
                  value: _showSaved,
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  child: Text('Activate This Device',
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                    const String baseUrl = '${server}activations/new.json';
                    var gotten = http.get(Uri.parse(baseUrl));

                    gotten.then((r) => this.showValidationCode(r));
                  },
                ),
              ),
              PopupMenuItem(
                child: TextButton(
                  child: Text('About ${widget.title}',
                      style: TextStyle(
                        color: Colors.black,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationIcon: FlutterLogo(),
                      applicationName: widget.title,
                      applicationVersion: '1.0.0',
                      applicationLegalese: '©2021 Colagioia Industries',
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Text('The Giver of (Mediocre) Names'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child:
                              Text('Source code available under the GPLv3 at'),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Text(
                              'https://github.com/jcolag/doritis-onomaton'),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemBuilder: (context, index) {
          return _showSaved
              ? InkWell(
                  child: ListTile(
                      title: Text(
                    '🔒 ${nameSource[index]}',
                    style: TextStyle(
                      color: Colors.green[900],
                      fontSize: 48.0,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  )),
                  onTap: () {
                    Clipboard.setData(
                        new ClipboardData(text: nameSource[index]));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      '${nameSource[index]} copied to clipboard.',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontFamily: 'NotoSans',
                        fontSize: 24.0,
                      ),
                    )));
                  },
                )
              : InkWell(
                  child: Dismissible(
                    background: Container(color: Colors.lightBlue),
                    child: ListTile(
                        title: Text(
                      nameSource[index],
                      style: TextStyle(
                        fontSize: 48.0,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    )),
                    key: Key(nameSource[index]),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        String name = nameSource[index];

                        setState(() {
                          nameSource.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          '$name deleted.',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: 'NotoSans',
                            fontSize: 24.0,
                          ),
                        )));
                      } else if (direction == DismissDirection.startToEnd) {
                        String key = this.prefController.apiKey;
                        String name = nameSource[index];
                        String baseUrl = '${server}names.json?apiKey=$key';
                        var payload = {'name': name};

                        http.post(baseUrl, body: payload);
                        setState(() {
                          nameSource.removeAt(index);
                          _savedNames.add(name);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          '🔒 $name saved to server.',
                          style: TextStyle(
                            color: Colors.lightGreen,
                            fontFamily: 'NotoSans',
                            fontSize: 24.0,
                          ),
                        )));
                      }
                    },
                  ),
                  onTap: () {
                    Clipboard.setData(
                        new ClipboardData(text: nameSource[index]));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                      '${nameSource[index]} copied to clipboard.',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        fontFamily: 'NotoSans',
                        fontSize: 24.0,
                      ),
                    )));
                  },
                );
        },
        itemCount: nameSource.length,
      ),
      floatingActionButton: _showSaved
          ? Row()
          : Row(
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

  void showValidationCode(httpResponse) {
    var resp = json.decode(httpResponse.body);

    showAboutDialog(
      context: context,
      applicationIcon: FlutterLogo(),
      applicationName: 'Activate ' + widget.title,
      // applicationVersion: '1.0.0',
      // applicationLegalese: '',
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            resp['code'],
            style: TextStyle(
              fontSize: 48.0,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('Visit ${server}activate'),
        ),
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('and enter the code now.'),
        ),
      ],
    );
  }
}
