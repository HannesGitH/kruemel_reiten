import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/MainDrawer.dart';
import 'package:kruemelreiten/homePageWidgets/GroupAdd.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Krümel',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        //primarySwatch: Colors.blue,
        //accentColor: Colors.white,
        backgroundColor: Colors.white,
        cardColor: Colors.blueGrey[400],
        primaryColor: Colors.blue,
        hintColor: Colors.white70,
        //highlightColor: Colors.amberAccent,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        cardColor: Colors.blueGrey[700],
        primaryColor: Colors.tealAccent,
        hintColor: Colors.white70,

        //highlightColor: Colors.amberAccent,
      ),
      home: MyHomePage(title: 'Krümel Reiten'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final List<BottomNavigationBarItem> bottomNavigationBarItems =[
    BottomNavigationBarItem(
      icon: Icon(Icons.group),
      title: Text('Gruppen'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      title: Text('Home'),
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.group_work),
      title: Text('NYI'),
    ),
  ];

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;

  SetGroups groupPage = SetGroups();

  Future<String> _title()async{
    switch(_selectedIndex) {
      case 0:
        return "Gruppen verwalten (${await groupPage.lc})";
      case 1:
        return "Krümel Reiten";
      default:
        return "--in arbeit--";
    }
  }

  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }


  List<Widget> Pages() {return <Widget>[
    groupPage,
    Text(
      'Index 1: Business',
    ),
    Text(
      'Index 2: School',
    ),
  ];}

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      drawer: MainDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title:FutureBuilder<String>(
            future: _title(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              return Text(snapshot.data);
            }
        )
      ),
      body: Pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          items: widget.bottomNavigationBarItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

