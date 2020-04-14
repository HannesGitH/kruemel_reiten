import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/MainDrawer.dart';
import 'package:kruemelreiten/homePageWidgets/GroupAdd.dart';
import 'package:kruemelreiten/homePageWidgets/MainPage.dart';
import 'package:kruemelreiten/other/ThemeManager.dart';
import 'package:kruemelreiten/pages/Settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:provider/provider.dart';
// TODO: make every data available and passing by ID instead of Name


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_)=>ThemeChanger(),
      child: MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeChanger theme = Provider.of<ThemeChanger>(context);
    return MaterialApp(
      title: 'Krümel',
      theme: theme.getTheme_LIGHT(),
      darkTheme: theme.getTheme_DARK(),
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
//keine saubere aber immerhin eine lösung
  Stream<int> timedCounter(Duration interval, [int maxCount]) async* {
  while (true) {
    int i = groupPage.lc;
    await Future.delayed(interval);
    yield i;
    if (i == maxCount) break;
  }
}

  Widget _title(){
    switch(_selectedIndex) {
      case 0:
        return StreamBuilder<int>(
          initialData: 0,
            stream: timedCounter(Duration(milliseconds: 300)),//_title(),
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return Text("Gruppen verwalten (${snapshot.data})");
            }
        );
      case 1:
        return Text("Krümel Reiten");
      default:
        return Text("--in arbeit--");
    }
  }

  List<Widget> Pages() {return <Widget>[
    groupPage,
    MainPage(),
    Container(
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("hier werden später Zahlungsübersichten zu sehen sein"),
            Text("bis dahin befinden sich die Zahlungsbilanzen auf der Gruppen-Seite"),
          ],
        ),
      ),
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
        title:_title(),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), 
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Settings()));
            },
          )
        ],
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

