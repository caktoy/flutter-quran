import 'package:flutter/material.dart';

import './models/Ayah.dart';
import './models/Surah.dart';

class DetailScreen extends StatefulWidget {
  final Surah surah;

  DetailScreen({Key key, this.surah}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _loading = false;
  List<Ayah> _listAyah = List();

  void mapAyah() {
    setState(() {
      _loading = true;
      _listAyah.clear();
    });

    List<Ayah> temp = List();
    for (var i = 0; i < widget.surah.totalAyah; i++) {
      var ayah = new Ayah();
      ayah.index = i + 1;
      ayah.arabic = widget.surah.ayah['${i + 1}'];
      ayah.indonesia = widget.surah.translation['${i + 1}'];
      ayah.tafsir = widget.surah.tafsir['${i + 1}'];
      temp.add(ayah);
    }

    setState(() {
      _loading = false;
      _listAyah = temp;
    });
  }

  Future<void> showTafsir(context, index) async {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('${widget.surah.latin} : ${index + 1}'),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  Text('${_listAyah[index].tafsir}'),
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

    this.mapAyah();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Flex(
          direction: Axis.vertical,
          children: [
            Text('${widget.surah.latin} (${widget.surah.arabic})'),
            Text(
              '${widget.surah.name} | ${widget.surah.totalAyah} Ayat',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: _loading
          ? Center(
              child: Text('Sedang memuat konten...'),
            )
          : ListView.separated(
              padding: EdgeInsets.only(top: 15),
              itemCount: widget.surah.totalAyah,
              separatorBuilder: (BuildContext context, int index) => Divider(),
              itemBuilder: (BuildContext ctx, int index) {
                return ListTile(
                  leading: Text(
                    '${index + 1}.',
                    style: TextStyle(fontSize: 18),
                  ),
                  title: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      _listAyah[index].arabic,
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  subtitle: Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(_listAyah[index].indonesia)),
                  onTap: () {
                    this.showTafsir(context, index);
                  },
                );
              },
            ),
    );
  }
}
