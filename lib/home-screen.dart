import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:simple_quran/detail-screen.dart';

import './models/Surah.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key key, this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = false;
  List<Surah> _listSurah = List();

  void loadSurah() async {
    setState(() {
      _loading = true;
      _listSurah.clear();
    });

    List<Surah> temp = List();
    for (var i = 1; i <= 114; i++) {
      String raw =
          await rootBundle.loadString('assets/quran-json/surah/$i.json');
      var obj = json.decode(raw);
      var item = Surah.fromJson(obj['$i']);

      temp.add(item);
    }

    setState(() {
      _loading = false;
      _listSurah.addAll(temp);
    });
  }

  Future<void> showAbout(context) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Quran Kita'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('Created by: Thony Hermawan'),
                  Text('\n'),
                  Text(
                      'Application source available on Github: https://github.com/caktoy/flutter-quran'),
                  Text('\n'),
                  Text(
                      'Qur\'an source: https://github.com/rioastamal/quran-json'),
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
                color: Colors.white,
              ),
              onPressed: () {
                this.showAbout(context);
              }),
        ],
      ),
      body: _loading
          ? Center(
              child: Text('Sedang memuat konten...'),
            )
          : ListView.separated(
              itemCount: _listSurah.length,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext ctx, int index) {
                return ListTile(
                  title: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${index + 1}. ${_listSurah[index].latin}'),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(_listSurah[index].arabic),
                      )
                    ],
                  ),
                  subtitle: Flex(
                    direction: Axis.horizontal,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_listSurah[index].name),
                      Text('${_listSurah[index].totalAyah} Ayat')
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext c) =>
                              DetailScreen(surah: _listSurah[index]),
                        ));
                  },
                );
              },
            ),
    );
  }
}
