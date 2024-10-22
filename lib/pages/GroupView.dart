import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/Settings/DateSettings.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupPage extends StatelessWidget{
  Group group;
  GroupPage({this.group});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DateChanger>(
      create: (_)=>DateChanger(),
      child: _GroupPage(group: group,),
    );
  }
}

class _GroupPage extends StatefulWidget{
  Group group;
  _GroupPage({this.group});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<_GroupPage> {
  final DataHandler dataman=DataHandler();

  Future<Group>_getCurrentGroup() async{
    List<Kid> kids= await dataman.getGroupMembersByName_complete(widget.group.name);
    print('kidsFromDataBase $kids');
    return Group(name: widget.group.name, kids:kids);
  }

  ScrollController scrollie = ScrollController(initialScrollOffset:0.0);

  bool isSec;
  bool editingGroupName;
  Group group;
  @override
  void initState() {
    group= widget.group;
    editingGroupName=false;
    isSec=widget.group.isSec??false;
    super.initState();
  }

  bool isThereANewOne=false; //TODO: make an actually good working solution
  bool isDirty=false;

  @override
  Widget build(BuildContext context) {
  final DateChanger dateMan = Provider.of<DateChanger>(context);
  bool isEverySecond=dateMan.isSecond()??true;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(editingGroupName?Icons.cancel: Icons.edit, color: Theme.of(context).canvasColor,), onPressed: (){
            setState(() {
              editingGroupName ^=true;
            });
          }),
          isEverySecond ? IconButton(icon: Icon(isSec?Icons.looks_one: Icons.looks_two, color: Theme.of(context).canvasColor,), onPressed: (){
            setState(() {
              isSec ^=true;
              DataHandler().changeGroupsIsSec(groupName: widget.group.name, isSec: isSec);
            });
          }):SizedBox(width:1)
        ],
        title: editingGroupName?
          TextField(
            style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: Theme.of(context).textTheme.headline.fontSize),
            maxLength: 20,
            autofocus: true,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none, 
              hintText: group.name??"neuer Gruppenname",
              hintStyle: TextStyle(
                color: Theme.of(context).backgroundColor,
                fontWeight: FontWeight.w300,
                fontSize: 19,
              ),
            ),
            onSubmitted: (x){
              DataHandler().changeGroupName(oldname: group.name, newname: x);
              setState(() {         
                editingGroupName=false;
                group.name=x;
              });
            },
          )        
         :Text(group.name??"neue Gruppe"),
      ),
      body: isDirty?CircularProgressIndicator():FutureBuilder<Group>(
        initialData: widget.group,
        future: _getCurrentGroup(),
        builder: (BuildContext context, AsyncSnapshot<Group> snapshot) {
          List<Kid>kids=snapshot.data.kids;
          if(snapshot.connectionState==ConnectionState.waiting){
            print('widget.group: $kids');
              return ListView(
                reverse: true,
                children: <Widget>[
                  Container(height: 70,),
                  ...kids.map((Kid kid){return _kidView(kid);}).toList(),
                  if(isThereANewOne)_kidView(Kid(name: 'das neue Kind')),
                  Container(height: MediaQuery.of(context).size.height/2,),
                ],
            
              );
          }
          return ListView(
            cacheExtent: 1000,
            controller: scrollie,
            reverse: true,
            children: <Widget>[
              Container(height: 70,),
              ...kids.map((Kid kid){return _kidView(kid,onRemove: (Kid kid){
                setState(() {
                  List<Kid> kids = group.kids;
                  print(kids.length);
                  kids.removeWhere((kid2)=>kid2.name==kid.name);
                  print(kids.length);
                  group.kids=kids;
                  dataman.updateGroup(group:group);
                  /*isDirty=true;
                  Future.delayed(Duration(milliseconds: 200)).then((t){setState(() {
                    isDirty=false;
                  });}); */
                });
                return;
              },);}).toList(),
              if(isThereANewOne)_kidView(Kid(name: 'das neue Kind')),
              Container(height: MediaQuery.of(context).size.height/2,),
            ],
          );
        },
      ),
      floatingActionButton:group.kids.length<10? TextFieldButton(onSubmit: (String kidName){
        setState(() {
          List<Kid> kids = group.kids;
          kids.add(Kid(name: kidName));
          group.kids=kids;
          dataman.updateGroup(group:group);
          isDirty=true;
          Future.delayed(Duration(milliseconds: 200)).then((t){setState(() {
            isDirty=false;
          });}) ;
        });
        // 
      },):null,
    );
  }
}

class TextFieldButton extends StatefulWidget{
  void Function(String) onSubmit;

  TextFieldButton({@required this.onSubmit});

  @override
  _TextFieldButtonState createState() => _TextFieldButtonState();
}

class _TextFieldButtonState extends State<TextFieldButton> {
  bool isClicked=false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){setState(() {
        isClicked^=true;
      });},
      child: AnimatedContainer(
        decoration: BoxDecoration(
          boxShadow: isClicked?
          [BoxShadow(color: Theme.of(context).backgroundColor, blurRadius: 25 ,spreadRadius: 10)]:
          [BoxShadow(color: Colors.black, blurRadius: 15, offset: Offset.fromDirection(1.3,7),spreadRadius: -4)],
          color: isClicked?Theme.of(context).cardColor:Theme.of(context).accentColor,
          borderRadius: isClicked?BorderRadius.circular(20):BorderRadius.circular(30),
        ),
        curve: Curves.easeInOutCubic,
        duration: Duration(milliseconds: 400),
        height: isClicked? 70: 60,
        width: isClicked? MediaQuery.of(context).size.width-30: 60,
        child: isClicked?
        Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left:15),
                child: TextField(
                  autofocus: true,
                  maxLength: 15,
                  style: TextStyle(fontSize:22,fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none, 
                    hintText: 'neues Kind',
                    hintStyle: TextStyle(
                      color: Theme.of(context).backgroundColor,
                      fontWeight: FontWeight.w300,
                      fontSize: 19,
                    ),
                  ),
                  onSubmitted: (String text){
                    widget.onSubmit(text);
                    setState(() {
                      isClicked=false;
                    });
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: FloatingActionButton(
                child: Icon(Icons.cancel),
                onPressed: (){setState(() {
                  isClicked^=true;
                });},
              ),
            ),
          ],
        ):
        Icon(Icons.person_add,color: Theme.of(context).backgroundColor,),
      ),
    );
  }
}

class _kidView extends StatefulWidget{
  Function(Kid) onRemove;

  Kid kid;

  _kidView(this.kid,{this.onRemove});

  @override
  __kidViewState createState() => __kidViewState();
}

class __kidViewState extends State<_kidView> {
  bool isDeleted=false;

  @override
  Widget build(BuildContext context) {

  //A Single Kid Card

      //TODO add delete 

      _callTel(tel) async {
        var url = "tel://$tel";
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not call $url';
        }
      }

      Widget number(String tel){
        return Text(tel??"keine Nummer..",
          style: TextStyle(
            decoration: TextDecoration.underline,
            color: Colors.blue,
          ),
        );
      }

      Widget balance(String val){
        int bal = int.tryParse(val??'0')??0;
        double balInEur=bal/100;
        return Text(balInEur.toString()+" €", //TODO: make all payments showable
          style: TextStyle(
            color: (bal??0)<0 ? Colors.red[400]: (Theme.of(context).brightness==Brightness.light ? Colors.green[800] : Colors.greenAccent[400]),
          ),
        );
      }

      List<Widget> _editrows(){return[
        Divider(height: 2,),
        GestureDetector(
          key: UniqueKey(),
          onTap: (){
            _callTel(widget.kid.tel);
          },
          child: _editRow(
            icon: Icons.phone,
            child: number(widget.kid.tel),
            onValue: (val){
              DataHandler().changeKidsTel(name: widget.kid.name, tel: val);
              return number(val);
            },
            keyboardType: TextInputType.phone,
          ),
        ),
        Divider(height: 2,),
        _editRow(
          icon: Icons.euro_symbol,
          child: balance((widget.kid.balance).toString()),
          onValue: (val){
            bool add=false;
            bool substract=false;
            switch(val[0]){
              case '+':
                add=true;
                val=val.substring(1);
                break;
              case '-':
                substract=true;
                val=val.substring(1);
                break;
              default:
                break;
            }
            double newVal = double.parse(val)??0;
            newVal *=100;//Euro to cents
            int nVal = newVal.floor();
            int cBal=widget.kid.balance??0;

            DataHandler dataman= DataHandler();
            if(add) {
              dataman.addPayment(Payment(
                kid:widget.kid,
                cents:nVal,
                date:DateTime.now(),
                //TODO: add description
              ));
              return balance((cBal+nVal).toString());
            }
            if(substract) {
              dataman.addPayment(Payment(
                kid:widget.kid,
                cents:-nVal,
                date:DateTime.now(),
                description: "geld ausgezahlt",//TODO: add description
              ));
              return balance((cBal-nVal).toString());
            }

            dataman.addPayment(Payment(
                kid:widget.kid,
                cents:nVal-cBal,
                date:DateTime.now(),
                description: "fehler behoben",//TODO: add description
              ));
            return balance(nVal.toString());
            
          },
        ),
      ];}
    
    return Stack(
      alignment: Alignment.topRight,
      children: <Widget>[
        Card(
          color: isDeleted?Colors.redAccent:Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8.0,
          margin: EdgeInsets.all(10),
          child: Card(
            color: Theme.of(context).canvasColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0.0,
            margin: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                _KidNameTextField(kidsName: widget.kid.name,),
                if(!isDeleted)..._editrows(),
              ],
            ),
          ),
        ),
        if(!isDeleted)Container(
          padding: EdgeInsets.only(right:10,top:10),
          child: ClipRRect(
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),topRight: Radius.circular(20)),
            child: Container(
              color: Theme.of(context).cardColor,
              width:50,
              height: 50,
              child: IconButton(
                icon: Icon(Icons.delete), 
                onPressed: (){
                  setState(() {
                    isDeleted=true;
                  });
                  if(widget.onRemove!=null)widget.onRemove(widget.kid);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _KidNameTextField extends StatefulWidget{
  String kidsName;
  _KidNameTextField({@required this.kidsName});

  @override
  State<StatefulWidget> createState() => _KidNameTextFieldState();
}

class _KidNameTextFieldState extends State<_KidNameTextField>{
  bool isInEditState=false;
  String name;

  @override
  void initState() {
    super.initState();
    name  = widget.kidsName;
  }

  @override
  Widget build(BuildContext context) {

    Widget editButton=
      IconButton(
        icon: Icon(Icons.edit,color: Theme.of(context).cardColor,),
        onPressed: (){
          setState(() {
            isInEditState=true;
          });
        },
      );

    Widget cancelButton=
      IconButton(
        icon: Icon(Icons.cancel,color: Theme.of(context).cardColor,),
        onPressed: (){
          setState(() {
            isInEditState=false;
          });
        },
      );

    TextEditingController c = TextEditingController();
    Widget editableKidName=
      Container(
        width: MediaQuery.of(context).size.width/2,
        child: TextField(
          maxLength: 15,
          autofocus: true,
          controller: c,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: name??"neuer Name",
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.body1.color,
              fontWeight: FontWeight.w300,
              fontSize: 19,
            ),
          ),
          onSubmitted: (x){
            setState(() {         
              DataHandler().changeKidsName(oldname: name, newname: x);
              name=x;
              isInEditState=false;
            });
          },
        )
      );

      //TODO on click go to childView in table or smthn
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(width:20),//Theme.of(context).iconTheme.size),
        Container(
            padding: EdgeInsets.only(top:10,bottom: 10),
            child: isInEditState? editableKidName : Text(name??"Kind ohne Namen",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),)
        ),
        isInEditState?cancelButton:editButton,
      ],
    );
  }
}
//MARK- editrow
class _editRow extends StatefulWidget{

  IconData icon;
  Widget child;
  Widget Function(String) onValue;
  TextInputType keyboardType;

  _editRow({@required this.icon, @required this.child, this.onValue, this.keyboardType});

  @override
  State<StatefulWidget> createState() => _editRowState();
}

class _editRowState extends State<_editRow>{
  bool isInEditState=false;

  Widget child;

  @override
  void initState() {
    super.initState();
    child=widget.child;
  }

  @override
  Widget build(BuildContext context) {

    Widget editButton=
    IconButton(
      icon: Icon(Icons.edit,color: Theme.of(context).cardColor,),
      onPressed: (){
        setState(() {
          isInEditState=true;
        });
      },
    );

    Widget cancelButton=
    IconButton(
      icon: Icon(Icons.cancel,color: Theme.of(context).cardColor,),
      onPressed: (){
        setState(() {
          isInEditState=false;
        });
      },
    );

    Widget editor=
    Container(
        width: MediaQuery.of(context).size.width/2,
        child: TextField(
          maxLength: 15,
          keyboardType: widget.keyboardType??TextInputType.text,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.body1.color,
              fontWeight: FontWeight.w300,
              fontSize: 19,
            ),
          ),
          onSubmitted: (x){
            setState(() {
              child=widget.onValue(x);
              isInEditState=false;
            });
          },
        )
    );

    return Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(widget.icon,//---
                  color: Theme.of(context).textTheme.body1.color,
                ),
                Container(width:10),
                isInEditState?editor:child,//---
              ],
            ),
            isInEditState?cancelButton:editButton,
          ],
        ),
      );
  }
}