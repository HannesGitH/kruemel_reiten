import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/BetterListTile.dart';
import 'package:kruemelreiten/pages/GroupAdd.dart';

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
              Navigator.push(context, MaterialPageRoute(builder: (context) => SetGroups()),);
            },
          ),
          BetterListTile(
            text: 'Item 2',
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
        ],
      ),
    );
  }
}