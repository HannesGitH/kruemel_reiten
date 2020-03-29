import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:kruemelreiten/pages/GroupView.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetGroups extends StatefulWidget {
  @override
  SetGroupsState createState() => SetGroupsState();

  int lc = 0;
}

class SetGroupsState extends State<SetGroups> {

  DataHandler dataMan=DataHandler();

  int _localCounter=0;
  static Future<int> counter;

  List<Group> _localGroups=[];
  Future<List<Group>> _groups;


  void update(Group newGroup){
    _addGroup(newGroup);
  }

  Future<void> _addGroup(newGroup) async {
    dataMan.addGroup(newGroup);
    setState(() {
      widget.lc = _localCounter+1;
      counter=Future((){return _localCounter+1;});
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
    counter = Future<int>(()async{return(await _groups).length;});
    counter.then((c){_localCounter=c; widget.lc=c;});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: Column(
          children: <Widget>[
            Expanded(
              child: Builder(
                builder: (BuildContext context) {
                  List<Widget> list = new List<Widget>();

                  //Hier sind die Reihen für jede Gruppe
                  for(var i = 0; i < _localGroups.length; i++){
                    list.add(
                      GroupCard(
                        group: _localGroups[i],
                      )
                    );
                  }
                  return ListView(
                    children: list,
                  );
                }
              ),
            ),
          ],
        ),
        floatingActionButton: AddGroupActionbutton(update: update,)
    );
  }
}

class GroupCard extends StatefulWidget{
  final Group group;
  final DataHandler dataMan=DataHandler();
  final Color deletedColor= Colors.red[400];

  GroupCard({@required this.group});
  _GroupCardS createState() => _GroupCardS();
}
class _GroupCardS extends State<GroupCard>{
  bool _isDeleted=false;
  void _delete(){
    widget.dataMan.deleteGroup(widget.group);
    setState(() {
      _isDeleted=true;
    });
  }
  void _restore(){
    widget.dataMan.addGroup(widget.group);
    setState(() {
      _isDeleted=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isDeleted? widget.deletedColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 8.0,
      margin: EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                highlightColor: Colors.transparent,
                tooltip: "mehr zeigen",
                icon: Icon(Icons.more, color: _isDeleted?widget.deletedColor:Theme.of(context).canvasColor,),
                onPressed: _isDeleted?null:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GroupPage(group:widget.group)));
                }

              ),
              Container(
                  padding: EdgeInsets.only(top:20,bottom: 10),
                  child: Text(widget.group.name??"Gruppe ohne Namen",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold,fontStyle: _isDeleted?FontStyle.italic:FontStyle.normal),)
              ),
              IconButton(
                highlightColor: Colors.transparent,
                tooltip: _isDeleted?"wiederherstellen":"Löschen",
                icon: Icon(_isDeleted?Icons.restore_from_trash:Icons.delete_forever, color: Theme.of(context).canvasColor,),
                onPressed: (){
                  _isDeleted? _restore():_delete();
                }
              ),
            ],
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: widget.group.kids.map((kid) =>
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
                        onPressed: (){
                          Navigator.push(context,  MaterialPageRoute(builder: (context) => GroupPage(group:widget.group)));
                          //TODO open kid overview instead of above line
                        },
                        child:  Text(
                          kid.name.toUpperCase()??"no name",
                          style: TextStyle(fontSize: 16,color: Theme.of(context).primaryColor, ),
                        ),
                      ),
                    ),
                  )
              ).toList()),
        ],
      ),
    );
  }
}

class AddGroupActionbutton extends StatefulWidget {

  final Function(Group) update;

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

  final FocusNode name2 = FocusNode();
  final FocusNode name3 = FocusNode();

  final name1C= TextEditingController();
  final name2C= TextEditingController();
  final name3C= TextEditingController();
  final gNameC= TextEditingController();

  final Function(Group) update;
  final Function()abort;

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
      bool hasName=gNameC.text.isNotEmpty;
      bool bedingung=name1C.text.length>0&&name2C.text.length>0&&name3C.text.length>0;
      if (bedingung) {
        names=[name1C.text,name2C.text,name3C.text];
        List<Kid> kids= List.generate(names.length, (i){
          return Kid(
            name: names[i],
          );
        });
        update(Group(kids: kids,name: hasName?gNameC.text:null));
      }else{
        _fillNames();
        print(names.length);
      }
    }


    Widget input({onDone,fn,c}){
      return Container(
        padding: EdgeInsets.only(top: 10,left: 20,right:20),
        child: TextField(
          maxLength: 10,
          focusNode: fn,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70,width: 1)),
            hintText: "Schüler Name",
            hintStyle: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w100,
              fontSize: 17,
            ),
          ),
          style: TextStyle(
            color: Colors.white,
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
        input(
          onDone: (name){
            FocusScope.of(context).requestFocus(name2);
          },
          c:name1C,
        ),
        input(
          onDone: (name){
            FocusScope.of(context).requestFocus(name3);
          },
          fn: name2,
          c:name2C,
        ),
        input(
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
            Container(
              width: 130,
              child: TextField(
                maxLength: 15,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white,width: 2),borderRadius: BorderRadius.circular(15)),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54,width: 1),borderRadius: BorderRadius.circular(15)),
                  hintText: "-Gruppename-",
                  hintStyle: TextStyle(
                    color: Colors.white60,
                    fontWeight: FontWeight.w300,
                    fontSize: 19,
                  ),
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
                onSubmitted: (x){set();},
                controller: gNameC,
              ),
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