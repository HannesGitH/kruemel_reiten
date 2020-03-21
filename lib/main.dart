import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
        cardColor: Colors.blueGrey[200],
        primaryColor: Colors.blue,
      ),
      home: MyHomePage(title: 'Krümel Reiten'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      drawer: Drawer(
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
      ),
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class SetGroups extends StatefulWidget {
  SetGroups({Key key}) : super(key: key);

  @override
  SetGroupsState createState() => SetGroupsState();
}

class SetGroupsState extends State<SetGroups> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<int> _counter;
  Future<List<List<String>>> _groups;

  void update(newGroup){
    _addGroup(newGroup);
  }

  Future<void> _addGroup(newGroup) async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('groupAmount_t') ?? 0) + 1;
    List<List<String>> groupsi=[[]];
    var j=prefs.getInt('groupAmount_t') ?? 0;
    for (var i=j;i>0;i--){
      groupsi.add(prefs.getStringList('group'+i.toString()+'names_t') ?? new List<String>(3));
    }

    //var newGroup=["uebi", "bubi", "bebi"];

    setState(() {
      _counter = prefs.setInt("groupAmount_t", counter).then((bool success) {
        return counter;
      });
      _groups = prefs.setStringList('group'+(j+1).toString()+'names_t', newGroup).then((bool success) {
        groupsi.add(newGroup);
        return groupsi;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _counter = _prefs.then((SharedPreferences prefs) {
      return (prefs.getInt('groupAmount_t') ?? 0);
    });
    _groups  = _prefs.then((SharedPreferences prefs) {
      List<List<String>> groupsi=[[]];
      for (var i=prefs.getInt('groupAmount_t') ?? 0;i>0;i--){
          groupsi.add(prefs.getStringList('group'+i.toString()+'names_t') ?? new List<String>(3));
      }
      return groupsi;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Text("Gruppen verwalten"),
            FutureBuilder<int>(
              future: _counter,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Container(
                          padding: EdgeInsets.all(0),
                          child: Column(
                              children: <Widget>[
                                Text(" (${snapshot.data})"),
                                //ScrollView für gruppen
                              ]
                          )
                      );
                    }
                }
              }
            )
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: FutureBuilder<List<List<String>>>(
                future: _groups,
                builder: (BuildContext context, AsyncSnapshot<List<List<String>>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        List<Widget> list = new List<Widget>();

                        //Hier sind die Reihen für jede Gruppe
                        for(var i = 1; i < snapshot.data.length; i++){
                          list.add(
                              Container(
                                padding: EdgeInsets.all(15),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    color: Theme.of(context).cardColor,
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                            padding: EdgeInsets.all(10),
                                            child: Text("Gruppe $i :",style: TextStyle(fontSize: 20,color: Theme.of(context).backgroundColor,fontWeight: FontWeight.bold),)
                                        ),
                                        Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: snapshot.data[i].map((item) =>
                                              Container(
                                                  padding: EdgeInsets.all(5),
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(20),
                                                    child:RaisedButton(
                                                      highlightColor: Theme.of(context).cardColor.withAlpha(100),
                                                      splashColor: Theme.of(context).cardColor,
                                                      color: Theme.of(context).backgroundColor,
                                                      onPressed: (){},
                                                      child:  Container(
                                                        padding: EdgeInsets.all(15),
                                                        child: Text(
                                                          item.toUpperCase()??"no name ",
                                                          style: TextStyle(fontSize: 16,color: Theme.of(context).primaryColor, ),
                                                        ),
                                                      ),
                                                  ),
                                                ),
                                              )
                                        ).toList()),
                                      ],
                                    ),
                                  ),
                                ),
                              ));
                        }
                        return ListView(
                          children: list,);
                      }
                  }
                }
            ),
          ),
        ],
      ),
      floatingActionButton: AddGroupActionbutton(update: update,)
    );
  }
}


class AddGroupActionbutton extends StatefulWidget {

  Function(List<String>) update;

  AddGroupActionbutton({Key key, this.update}) : super(key: key);

  @override
  AddGroupActionbuttonState createState() => AddGroupActionbuttonState();
}

class AddGroupActionbuttonState extends State<AddGroupActionbutton> {

  bool isClicked=false;
  bool wasClicked=false;

  void popupGroup(){
    setState(() {
      isClicked=!isClicked;
    });
    Future.delayed(Duration(milliseconds: 400), (){setState(() {
      wasClicked=!wasClicked;
    });});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: popupGroup,
      child: AnimatedContainer(
        decoration: BoxDecoration(
          boxShadow: isClicked?
            [BoxShadow(color: Theme.of(context).backgroundColor, blurRadius: 25 ,spreadRadius: 10)]:
            [BoxShadow(color: Colors.black, blurRadius: 15, offset: Offset.fromDirection(1.3,7),spreadRadius: -4)],
          color: isClicked?Colors.blueGrey[500]:Theme.of(context).primaryColor,
          borderRadius: isClicked?BorderRadius.circular(20):BorderRadius.circular(30),
        ),
        curve: Curves.easeOutCubic,
        duration: Duration(milliseconds: 400),
        height: isClicked? 200: 60,
        width: isClicked? MediaQuery.of(context).size.width-30: 60,
          child: wasClicked&&isClicked?
            Container(
              child: GroupEditor(update: (group){widget.update(group);popupGroup();}),
            ):
            Icon(Icons.add,color: Theme.of(context).backgroundColor,),
      ),
    );
  }
}

class GroupEditor extends StatelessWidget{

  Function(List<String>) update;

  GroupEditor({this.update});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: CircleBorder(),
      onPressed: (){
        update(["uebsi"]);
        print("updated");},
      child: Icon(Icons.check_circle, color: Theme.of(context).primaryColor,),
    );
  }


}