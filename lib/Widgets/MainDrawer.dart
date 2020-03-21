import 'package:flutter/material.dart';
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
            child: Text('Sarahs App',style: TextStyle(fontSize:22, color:  Theme.of(context).backgroundColor),),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            title: Text('Namen eintragen'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SetGroups()),);
            },
          ),
          ListTile(
            title: Text('Item 2'),
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