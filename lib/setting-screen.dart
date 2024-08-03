import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info/package_info.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List<Map<String, dynamic>> _listSetting = [
    {
      'type': 'switch',
      'key': 'continous_reading',
      'title': 'Mode ayat menyambung',
      'value': false,
    },
    {
      'type': 'info',
      'key': 'app_version',
      'title': 'Versi aplikasi',
      'value': '1.0.0',
    },
    {
      'type': 'info',
      'key': 'developer',
      'title': 'Pengembang',
      'value': 'Thony Hermawan'
    },
    {
      'type': 'info',
      'key': 'code_repository',
      'title': 'Repository Kode Aplikasi',
      'value': 'https://github.com/caktoy/flutter-quran'
    },
    {
      'type': 'info',
      'key': 'content_repository',
      'title': 'Repository Konten Aplikasi',
      'value': 'https://github.com/rioastamal/quran-json'
    },
  ];

  // load from shared preference
  void _loadSetting() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _listSetting.forEach((element) {
          if (element['type'] == 'switch') {
            element['value'] = prefs.getBool(element['key']) ?? false;
          }
          if (element['key'] == 'app_version') {
            _getPackageInfo();
          }
        });
      });
    });
  }

  void _getPackageInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      setState(() {
        _listSetting.forEach((element) {
          if (element['key'] == 'app_version') {
            element['value'] = info.version;
          }
        });
      });
    } catch (e) {
      // show error as snackbar
      final snackBar = SnackBar(
        content: Text('Error: $e'),
        duration: Duration(seconds: 5),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  _onChangedSetting(String key, bool value) {
    setState(() {
      _listSetting.forEach((element) {
        if (element['key'] == key) {
          element['value'] = value;
        }
      });
    });
    // save to shared preference
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool(key, value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: ListView.builder(
        itemCount: _listSetting.length,
        itemBuilder: (BuildContext context, int index) {
          var setting = _listSetting[index];
          if (setting['type'] == 'switch') {
            return SwitchListTile(
              title: Text(setting['title']),
              value: setting['value'],
              onChanged: (bool value) {
                _onChangedSetting(setting['key'], value);
              },
            );
          } else {
            return ListTile(
              title: Text(setting['title']),
              subtitle: Text(setting['value']),
              onTap: () {
                if (setting['key'] == 'app_version') {
                  _getPackageInfo();
                }
              },
            );
          }
        },
      ),
    );
  }
}
