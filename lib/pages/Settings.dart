import 'package:flutter/material.dart';

class Settings
    extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text("noch gibt es keine Einstellungen.."),
        ),
      ),//TODO: add DarkThemeSettings
    );
  }
}