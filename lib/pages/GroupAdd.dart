import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
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
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  elevation: 8.0,
                                  margin: new EdgeInsets.all(15),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.only(top:20,bottom: 10),
                                          child: Text("Gruppe $i :",style: TextStyle(fontSize: 20,color: Theme.of(context).backgroundColor,fontWeight: FontWeight.bold),)
                                      ),
                                      Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: snapshot.data[i].map((item) =>
                                              Container(
                                                padding: EdgeInsets.all(5),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(20),
                                                  child:FlatButton(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                    ),
                                                    highlightColor: Theme.of(context).cardColor.withAlpha(100),
                                                    splashColor: Theme.of(context).cardColor,
                                                    color: Theme.of(context).backgroundColor,
                                                    onPressed: (){},
                                                    child:  Text(
                                                      item.toUpperCase()??"no name ",
                                                      style: TextStyle(fontSize: 16,color: Theme.of(context).primaryColor, ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ).toList()),
                                    ],
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
        Icon(Icons.group_add,color: Theme.of(context).backgroundColor,),
      ),
    );
  }
}

class GroupEditor extends StatelessWidget {

  Function(List<String>) update;

  GroupEditor({this.update});

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      shape: CircleBorder(),
      onPressed: () {
        update(["uebsi"]);
        print("updated");
      },
      child: Icon(Icons.check_circle, color: Theme
          .of(context)
          .primaryColor,),
    );
  }


}