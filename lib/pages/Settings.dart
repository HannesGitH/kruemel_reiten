import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/Settings/GroupSettings.dart';
import 'package:kruemelreiten/Widgets/Settings/DateSettings.dart';
import 'package:kruemelreiten/Widgets/Settings/ThemeSettings.dart';

class Settings
    extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Einstellungen"),
      ),
      body: ListView(
        children: <Widget>[
          SizedBox(height: 30,),
          ThemeSettings(),
          SizedBox(height:15),
          Divider(),
          SizedBox(height: 15),
          DateSettings(),
          SizedBox(height:15),
          /*Divider(),
          SizedBox(height: 15),
          GroupSettings(),*/
        ],
      ),
    );
  }
}