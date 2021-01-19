import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home.dart';


void main() {
  runApp(MePlay());
}


class MePlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Me Play',
      theme: ThemeData(fontFamily: 'SF Pro Text'),
      home: HomeScreen(title: 'Me Play'),
    );
  }
}
