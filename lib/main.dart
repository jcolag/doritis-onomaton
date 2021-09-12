import 'dart:convert';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unorm_dart/unorm_dart.dart' as unorm;

import 'alphabets.dart' as alphabets;

const consonants = alphabets.consonants;
const vowels = alphabets.vowels;
const server = 'http://onomaton.club/';
var random = Random();

void main() async {
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
      home: NameGiverHome(title: 'Doritís Onomáton Namer'),
    );
  }
}

class NameGiverHome extends StatefulWidget {
  NameGiverHome({Key? key, required this.title}) : super(key: key);
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
  SharedPreferences? preferences;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete((){
      setState(() {});
    });
  }

  Future<void> initializePreference() async{
    this.preferences = await SharedPreferences.getInstance();
  }

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
    List<String> c = consonants[_chosenLanguage] ?? [];
    List<String> v = vowels[_chosenLanguage] ?? [];

    while (random.nextDouble() < done || name.length < 3) {
      String onset = c[random.nextInt(c.length)];
      String nucleus = v[random.nextInt(v.length)];
      String coda = c[random.nextInt(c.length)];

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
      WidgetsBinding.instance?.addPostFrameCallback((_) => _scrollToEnd());
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
              onChanged: (String? value) {
                setState(() {
                  _chosenLanguage = value ?? 'Latin';
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
                  onPressed: () async {
                    Navigator.pop(context);
                    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
                    var deviceData = <String, dynamic>{};
                    var android = <String, dynamic>{};
                    var ios = <String, dynamic>{};
                    var linux = <String, dynamic>{};
                    var mac = <String, dynamic>{};
                    var web = <String, dynamic>{};
                    var windows = <String, dynamic>{};
                    try {
                      android =
                          _readAndroidBuildData(await deviceInfo.androidInfo);
                    } catch (e) {}
                    try {
                      ios = _readIosDeviceInfo(await deviceInfo.iosInfo);
                    } catch (e) {}
                    try {
                      linux = _readLinuxDeviceInfo(await deviceInfo.linuxInfo);
                    } catch (e) {}
                    try {
                      mac = _readMacOsDeviceInfo(await deviceInfo.macOsInfo);
                    } catch (e) {}
                    try {
                      web =
                          _readWebBrowserInfo(await deviceInfo.webBrowserInfo);
                    } catch (e) {}
                    try {
                      windows =
                          _readWindowsDeviceInfo(await deviceInfo.windowsInfo);
                    } catch (e) {}

                    String device = json.encode({
                      'android': android,
                      'browser': web,
                      'ios': ios,
                      'linux': linux,
                      'mac': mac,
                      'windows': windows,
                    });

                    String baseUrl =
                        '${server}activations/new.json?device=${device}';
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
                        String key = this.preferences?.getString('apiKey') ?? '';
                        String name = nameSource[index];
                        Uri baseUrl = Uri.parse('${server}names.json?apiKey=$key');
                        var payload = {'name': name};

                        http.post(baseUrl, body: payload);
                        setState(() {
                          nameSource.removeAt(index);
                          _savedNames.add(name);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                          '🔒 Saving $name to server.',
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

    if (resp['result'] != 'ok') {
      setState(() {
        this.preferences?.setString('apiKey', resp['result']);
      });
      return;
    }

    showAboutDialog(
      context: context,
      applicationIcon: FlutterLogo(),
      applicationName: 'Activate ' + widget.title,
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
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: TextButton(
            child: Text('Refresh Status',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                )),
            onPressed: () {
              Navigator.pop(context);
              var baseUrl =
                  '${server}activations/verify.json?code=${resp["code"]}';
              var gotten = http.get(Uri.parse(baseUrl));

              gotten.then((r) => this.showValidationCode(r));
            },
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      'browserName': data.browserName.toString(),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'deviceMemory': data.deviceMemory,
      'language': data.language,
      'languages': data.languages,
      'platform': data.platform,
      'product': data.product,
      'productSub': data.productSub,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
      'vendorSub': data.vendorSub,
      'hardwareConcurrency': data.hardwareConcurrency,
      'maxTouchPoints': data.maxTouchPoints,
    };
  }

  Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
    };
  }

  Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    };
  }
}
