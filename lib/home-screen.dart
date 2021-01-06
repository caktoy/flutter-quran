import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:simple_quran/detail-screen.dart';

import 'package:package_info/package_info.dart';

import './models/Surah.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key key, this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  List<Surah> _listSurah = [];
  List<Surah> _listTemp = [];
  int _totalSurah = 114;
  double _percentage = 0;
  TextEditingController _searchController = TextEditingController();

  void loadSurah() async {
    setState(() {
      _loading = true;
      _listSurah.clear();
      _listTemp.clear();
      _percentage = 0;
    });

    for (var i = 1; i <= _totalSurah; i++) {
      String raw =
          await rootBundle.loadString('assets/quran-json/surah/$i.json');
      var obj = json.decode(raw);
      var item = Surah.fromJson(obj['$i']);

      setState(() {
        _listTemp.add(item);
        _percentage = (_listTemp.length / _totalSurah) * 100;
      });
    }

    setState(() {
      _loading = false;
      _listSurah.addAll(_listTemp);
    });
  }

  Widget renderBody() {
    return Column(
      children: [
        Container(
          child: new Padding(
            padding: const EdgeInsets.all(3.0),
            child: new Card(
              child: new ListTile(
                title: new TextField(
                  autofocus: false,
                  autocorrect: false,
                  controller: _searchController,
                  decoration: new InputDecoration(
                      hintText: 'Cari', border: InputBorder.none),
                  onChanged: (value) {
                    setState(() {
                      _listTemp.clear();
                      _listTemp.addAll(value.isNotEmpty
                          ? _listSurah.where((surah) => surah.latin
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          : _listSurah);
                    });
                  },
                ),
                trailing: new Icon(Icons.search),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _listTemp.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext ctx, int index) {
              return ListTile(
                title: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        '${_listTemp[index].number}. ${_listTemp[index].latin}'),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Text(_listTemp[index].arabic,
                          style: TextStyle(fontFamily: "LPMQ")),
                    )
                  ],
                ),
                subtitle: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_listTemp[index].name),
                    Text('${_listTemp[index].totalAyah} Ayat')
                  ],
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext c) =>
                            DetailScreen(surah: _listTemp[index]),
                      ));
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> showAbout(context) async {
    var packageInfo = await PackageInfo.fromPlatform();

    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Quran ID'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Developed by: Thony Hermawan'),
                  Text('\n'),
                  Text(
                      'Application source available on Github: https://github.com/caktoy/flutter-quran'),
                  Text('\n'),
                  Text(
                      'Qur\'an source: https://github.com/rioastamal/quran-json'),
                  Text('\n'),
                  Text(
                    'Version: ${packageInfo.version}',
                    style: TextStyle(fontSize: 12.0),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Tutup'))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    this.loadSurah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          IconButton(
              icon: Icon(
                Icons.info,
                color: _loading ? Colors.transparent : Colors.white,
              ),
              onPressed: _loading
                  ? () {}
                  : () {
                      this.showAbout(context);
                    }),
        ],
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${_percentage.round()}%',
                    style: TextStyle(fontSize: 35),
                  ),
                  Text('Sedang menyusun konten'),
                  Text('Mohon tunggu sebentar...'),
                ],
              ),
            )
          : renderBody(),
    );
  }
}
