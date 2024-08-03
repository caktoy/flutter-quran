import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_quran/detail-screen.dart';

import './models/Surah.dart';

class HomeScreen extends StatefulWidget {
  final String title;

  HomeScreen({Key? key, required this.title}) : super(key: key);

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
  String _lastSavedSurah = '';
  int _lastSavedAyah = 0;

  // load last saved surah and ayah from shared preference
  void _loadLastRead() {
    try {
      SharedPreferences.getInstance().then((prefs) {
        setState(() {
          _lastSavedSurah = prefs.getString('last_surah') ?? '';
          _lastSavedAyah = prefs.getInt('last_ayah') ?? 0;
        });
      });
    } catch (e) {
      // show error as snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memuat data terakhir dibaca'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  void _loadSurah() async {
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

    // load last saved surah and ayah from shared preference, if any put it on top of the list without removing the original list
    if (_lastSavedSurah.isNotEmpty) {
      var lastSurah = _listTemp.firstWhere(
          (element) => element.latin == _lastSavedSurah,
          orElse: () => Surah(
              number: 0,
              name: '',
              latin: '',
              arabic: '',
              totalAyah: 0,
              translation: {},
              tafsir: {},
              ayah: {}));
      if (lastSurah.number > 0) {
        lastSurah.latin =
            "${lastSurah.latin} (Terakhir dibaca pada ayat ke-$_lastSavedAyah)";
        // _listTemp.removeWhere((element) => element.latin == _lastSavedSurah);
        _listTemp.insert(0, lastSurah);
      }
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
                      )).then((value) {
                    this._loadLastRead();
                    this._loadSurah();
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    this._loadLastRead();

    this._loadSurah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          // icon button for navigate to setting screen
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/setting');
            },
          ),
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
