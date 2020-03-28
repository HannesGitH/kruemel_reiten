import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/BetterListTile.dart';
import 'package:kruemelreiten/pages/DatabaseDevTestPage.dart';
import 'package:kruemelreiten/homePageWidgets/GroupAdd.dart';
import 'package:kruemelreiten/pages/Settings.dart';
import 'package:kruemelreiten/pages/randomDogsTest.dart';

class MainDrawer extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Center(child: Text('Sarah\'s App',style: TextStyle(fontSize:32, color:  Theme.of(context).backgroundColor),)),
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft,colors:[Theme.of(context).primaryColor,Colors.cyanAccent]),
              //color: Theme.of(context).primaryColor,
            ),
          ),
          BetterListTile(
            icon: Icons.group,
            text:'Gruppen eintragen',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => SetGroups()),);
            },
          ),
          BetterListTile(
            icon:Icons.settings,
            text: 'Einstellungen',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()),);
            },
          ),
          BetterListTile(
            icon:Icons.developer_board,
            text: 'DataBaseTests',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => DatabaseTestPage()),);
            },
          ),

          BetterListTile(
            icon:Icons.child_care,
            text: 'Unendlich Hunde',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => RandomDogsScrollView()),);
            },
          ),
        ],
      ),
    );
  }
}