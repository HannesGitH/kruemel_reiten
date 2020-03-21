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
        backgroundColor: Theme.of(context).canvasColor,
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
                                          child: Text("Gruppe $i :",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
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
                                                    color: Theme.of(context).canvasColor,
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
      isClicked=true;
    });
    Future.delayed(Duration(milliseconds: 400), (){setState(() {
      wasClicked=true;
    });});
  }

  void cancel(){
    setState(() {
      wasClicked=false;
      isClicked=false;
    });
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
        curve: Curves.easeInOutCubic,
        duration: Duration(milliseconds: 400),
        height: isClicked? 250: 60,
        width: isClicked? MediaQuery.of(context).size.width-30: 60,
        child: wasClicked?
        Container(
          child: GroupEditor(update: (group){widget.update(group);cancel();},abort: cancel,),
        ):
        Icon(Icons.group_add,color: Theme.of(context).backgroundColor,),
      ),
    );
  }
}

class GroupEditor extends StatelessWidget {

  FocusNode name2 = FocusNode();
  FocusNode name3 = FocusNode();

  final name1C= TextEditingController();
  final name2C= TextEditingController();
  final name3C= TextEditingController();

  Function(List<String>) update;
  Function()abort;

  List<String> names=[];

  GroupEditor({this.update, this.abort});

  @override
  Widget build(BuildContext context) {

    Future<void> _fillNames() async {
      return showDialog<void>(
        context: context,
        //barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text('Da fehlt wohl jemand'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Es sind doch immer 3 in einer Gruppe'),
                  Text('Du hast wohl nicht genug eingegeben.'),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Oops',style: TextStyle(color: Theme.of(context).primaryColor),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    void set(){
      bool bedingung=name1C.text.length>0&&name2C.text.length>0&&name3C.text.length>0;
      if (bedingung) {
        names=[name1C.text,name2C.text,name3C.text];
        update(names);
      }else{
        _fillNames();
        print(names.length);
      }
    }

    Widget Input({onDone,fn,c}){
      return Container(
        padding: EdgeInsets.only(top: 10,left: 20,right:20),
        child: TextField(
          focusNode: fn,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: "Name",
          ),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
          onSubmitted: onDone,
          controller: c,
        ),
      );
    }

    return Column(
      children: <Widget>[
        Input(
          onDone: (name){
            FocusScope.of(context).requestFocus(name2);
          },
          c:name1C,
        ),
        Input(
          onDone: (name){
            FocusScope.of(context).requestFocus(name3);
          },
          fn: name2,
          c:name2C,
        ),
        Input(
          onDone: (name){
            set();
          },
          fn: name3,
          c:name3C,
        ),
        Container(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            RaisedButton(
              elevation: 8,
              padding: EdgeInsets.all(15),
              color: Theme.of(context).canvasColor,
              shape: CircleBorder(),
              onPressed: () {
                abort();
                print("aborted");
              },
              child: Icon(Icons.cancel, color: Theme
                  .of(context)
                  .primaryColor,),
            ),
            RaisedButton(
              elevation: 8,
              padding: EdgeInsets.all(15),
              color: Theme.of(context).canvasColor,
              shape: CircleBorder(),
              onPressed: () {
                set();
              },
              child: Icon(Icons.check_circle, color: Theme
                  .of(context)
                  .primaryColor,),
            ),
          ],
        ),
      ],
    );
  }


}