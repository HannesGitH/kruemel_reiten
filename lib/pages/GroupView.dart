import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';

class GroupPage extends StatelessWidget{
  final Group group;
  GroupPage({this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name??"neue Gruppe"),
      ),
      body: Center(child: Text("hier wird später mehr info zur Grupe zu sehen sein")),//TODO make body
    );
  }
}