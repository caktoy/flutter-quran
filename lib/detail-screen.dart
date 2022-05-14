import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';

import './models/Ayah.dart';
import './models/Surah.dart';

class DetailScreen extends StatefulWidget {
  final Surah surah;

  DetailScreen({Key? key, required this.surah}) : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _loading = false;
  List<Ayah> _listAyah = <Ayah>[];

  void mapAyah() {
    setState(() {
      _loading = true;
      _listAyah.clear();
    });

    List<Ayah> temp = [];
    for (var i = 0; i < widget.surah.totalAyah; i++) {
      var ayah = new Ayah(
        index: i + 1,
        arabic: widget.surah.ayah['${i + 1}'],
        indonesia: widget.surah.translation['${i + 1}'],
        tafsir: widget.surah.tafsir['${i + 1}'],
      );
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

  void _copyToClipboard(int index) {
    String text = _listAyah[index].arabic + '\n\n' + _listAyah[index].indonesia;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Ayat ${_listAyah[index].index} telah disalin'),
      duration: Duration(seconds: 1),
    ));
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
          crossAxisAlignment: kIsWeb
              ? CrossAxisAlignment.center
              : (Platform.isAndroid
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center),
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
          : ListView.builder(
              itemCount: widget.surah.totalAyah,
              itemBuilder: (BuildContext ctx, int index) {
                return GestureDetector(
                  onTap: () {
                    this.showTafsir(context, index);
                  },
                  child: Card(
                    elevation: 3.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}',
                                style:
                                    TextStyle(fontSize: 18, fontFamily: "LPMQ"),
                              ),
                              GestureDetector(
                                onTap: () {
                                  this.showTafsir(context, index);
                                },
                                child: Icon(Icons.info_outline_rounded,
                                    color: Colors.grey.shade600, size: 18),
                              ),
                              GestureDetector(
                                onTap: () {
                                  this._copyToClipboard(index);
                                },
                                child: Icon(Icons.copy_rounded,
                                    color: Colors.grey.shade600, size: 18),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: 12.0, right: 6.0, bottom: 6.0),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text(
                                      _listAyah[index].arabic,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                          fontSize: 24, fontFamily: "LPMQ"),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 12, bottom: 6.0),
                                  child: Text(
                                    _listAyah[index].indonesia,
                                    textAlign: TextAlign.start,
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                // return ListTile(
                //   leading: Text(
                //     '${index + 1}.',
                //     style: TextStyle(fontSize: 18),
                //   ),
                //   title: Directionality(
                //     textDirection: TextDirection.rtl,
                //     child: Text(
                //       _listAyah[index].arabic,
                //       style: TextStyle(fontSize: 24, fontFamily: "LPMQ"),
                //     ),
                //   ),
                //   subtitle: Padding(
                //       padding: EdgeInsets.only(top: 10),
                //       child: Text(_listAyah[index].indonesia)),
                //   onTap: () {
                //     this.showTafsir(context, index);
                //   },
                // );
              },
            ),
    );
  }
}
