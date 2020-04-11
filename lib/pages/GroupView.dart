import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupPage extends StatefulWidget{
  Group group;
  GroupPage({this.group});

  @override
  _GroupPageState createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  final DataHandler dataman=DataHandler();

  Future<Group>_getCurrentGroup() async{
    List<Kid> kids= await dataman.getGroupMembersByName_complete(widget.group.name);
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(editingGroupName?Icons.cancel: Icons.edit, color: Theme.of(context).canvasColor,), onPressed: (){
            setState(() {
              editingGroupName ^=true;
            });
          }),
          IconButton(icon: Icon(isSec?Icons.looks_one: Icons.looks_two, color: Theme.of(context).canvasColor,), onPressed: (){
            setState(() {
              isSec ^=true;
              DataHandler().changeGroupsIsSec(groupName: widget.group.name, isSec: isSec);
            });
          })
        ],
        title: editingGroupName?
          TextField(
            style: TextStyle(color: Theme.of(context).backgroundColor, fontSize: Theme.of(context).textTheme.headline.fontSize),
            maxLength: 20,
            autofocus: true,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              border: InputBorder.none, //TODO no bottom space
              hintText: group.name??"neuer Gruppenname",
              hintStyle: TextStyle(
                color: Theme.of(context).backgroundColor,
                fontWeight: FontWeight.w300,
                fontSize: 19,
              ),
            ),
            onSubmitted: (x){
              setState(() {         
                editingGroupName=false;
                group.name=x;
              });
              //TODO: save to database
            },
          )        
         :Text(group.name??"neue Gruppe"),
      ),
      body: FutureBuilder<Group>(
        initialData: widget.group,
        future: _getCurrentGroup(),
        builder: (BuildContext context, AsyncSnapshot<Group> snapshot) {
          List<Kid>kids=snapshot.data.kids;
          if(snapshot.connectionState==ConnectionState.waiting){
              return ListView(
                reverse: true,
                children: <Widget>[
                  Container(height: 10,),
                  _kidView(kids[2]),
                  _kidView(kids[1]),
                  _kidView(kids[0]),
                  Container(height: MediaQuery.of(context).size.height/2,),
                ],
            
              );
          }
          return ListView(
            controller: scrollie,
            reverse: true,
            children: <Widget>[
              Container(height: 10,),
              _kidView(kids[2]),
              _kidView(kids[1]),
              _kidView(kids[0]),
              Container(height: MediaQuery.of(context).size.height/2,),
            ],
          );
        },
      ),
    );
  }
}

class _kidView extends StatelessWidget{

  Kid kid;

  _kidView(this.kid);

  
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
            color: Theme.of(context).primaryColor,
          ),
        );
      }

      Widget balance(String val){
        int bal = int.tryParse(val??'0')??0;
        double balInEur=bal/100;
        return new Text(balInEur.toString()+" €", //TODO: make all payments showable
          style: TextStyle(
            color: (bal??0)<0 ? Colors.red[400]: (Theme.of(context).brightness==Brightness.light ? Colors.green[800] : Colors.greenAccent[400]),
          ),
        );
      }

      List<Widget> _editrows(){return[
        Divider(),
        GestureDetector(
          onTap: (){
            _callTel(kid.tel);
          },
          child: _editRow(
            icon: Icons.phone,
            child: number(kid.tel),
            onValue: (val){
              DataHandler().changeKidsTel(name: kid.name, tel: val);
              return number(val);
            },
            keyboardType: TextInputType.phone,
          ),
        ),
        Divider(),
        _editRow(
          icon: Icons.euro_symbol,
          child: balance((kid.balance).toString()),
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
            int cBal=kid.balance??0;

            DataHandler dataman= DataHandler();
            if(add) {
              dataman.addPayment(Payment(
                kid:kid,
                cents:nVal,
                date:DateTime.now(),
                //TODO: add description
              ));
              return balance((cBal+nVal).toString());
            }
            if(substract) {
              dataman.addPayment(Payment(
                kid:kid,
                cents:-nVal,
                date:DateTime.now(),
                description: "geld ausgezahlt",//TODO: add description
              ));
              return balance((cBal-nVal).toString());
            }

            dataman.addPayment(Payment(
                kid:kid,
                cents:nVal-cBal,
                date:DateTime.now(),
                description: "fehler behoben",//TODO: add description
              ));
            return balance(nVal.toString());
            
          },
        ),
      ];}
    
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8.0,
        margin: EdgeInsets.all(15),
        child: Card(
          color: Theme.of(context).canvasColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0.0,
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              _KidNameTextField(kidsName: kid.name,),
              ...
              _editrows(),
            ],
          ),
        )
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