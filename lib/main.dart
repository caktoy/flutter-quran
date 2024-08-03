import 'package:flutter/material.dart';
import 'package:simple_quran/setting-screen.dart';
import './home-screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran ID',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(title: 'Quran ID'),
        '/setting': (context) => SettingScreen(),
        // '/detail': (context) => DetailScreen()
      },
    );
  }
}
