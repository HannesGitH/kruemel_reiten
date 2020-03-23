import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SetGroups extends StatefulWidget {
  SetGroups({Key key}) : super(key: key);

  @override
  SetGroupsState createState() => SetGroupsState();
}

class SetGroupsState extends State<SetGroups> {


  DataHandler dataMan=DataHandler();

  //Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int _localCounter=0;
  Future<int> _counter;

  List<Group> _localGroups=[];
  Future<List<Group>> _groups;


  void update(Group newGroup){
    _addGroup(newGroup);
  }

  Future<void> _addGroup(newGroup) async {
    dataMan.addGroup(newGroup[0], newGroup[1], newGroup[2]); //optional add groupname TODo later
    setState(() {
      _counter=Future((){return _localCounter+1;});
      _localGroups.add(newGroup);
    });
    return;
  }
  Future<void> createLocalCopy(groups)async{
    _localGroups= await groups;
    setState(() {
      _localGroups=_localGroups;
    });
  }

  @override
  void initState() {
    super.initState();
    _groups  = dataMan.getAllGroups_noBalance();
    createLocalCopy(_groups);
    _counter = Future<int>(()async{return(await _groups).length;});
    _counter.then((c){_localCounter=c;});
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
              child: Builder(
                builder: (BuildContext context) {
                  List<Widget> list = new List<Widget>();

                  //Hier sind die Reihen für jede Gruppe
                  for(var i = 1; i < _localGroups.length; i++){
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
                                  child: Text(_localGroups[i].name,style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold),)
                              ),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: _localGroups[i].kids.map((kid) =>
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
                                              kid.name.toUpperCase()??"no name ",
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
              ),
            ),
          ],
        ),
        floatingActionButton: AddGroupActionbutton(update: update,)
    );
  }
}


class AddGroupActionbutton extends StatefulWidget {

  Function(Group) update;

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

  Function(Group) update;
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
        List<Kid> kids= List.generate(names.length, (i){
          return Kid(
            name: names[i],
          );
        });
        update(Group(kids: kids));
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