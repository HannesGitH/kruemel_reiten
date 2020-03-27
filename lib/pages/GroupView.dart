import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:url_launcher/url_launcher.dart';

class GroupPage extends StatelessWidget{
  final DataHandler dataman=DataHandler();
  final Group group;
  GroupPage({this.group});

  Future<Group>_getCurrentGroup() async{
    List<Kid> kids= await dataman.getGroupMembersByName_complete(group.name);
    print (kids);
    return Group(name: group.name, kids:kids);
  }

  ScrollController scrollie = ScrollController(initialScrollOffset:0.0);
  
  @override
  Widget build(BuildContext context) {

    Widget _editRow({@required IconData icon, @required Widget child, Function() editor}){
      return Container(
        padding: EdgeInsets.symmetric(horizontal:20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon,//---
                  color: Theme.of(context).textTheme.body1.color,
                ),
                Container(width:10),
                child,//---
              ],
            ),
            IconButton(
              icon: Icon(Icons.edit,color: Theme.of(context).cardColor,),
              onPressed: editor,//---
            ),
          ],
        ),
      );
    }

//A Single Kid Card
    Widget _kidView(Kid kid){

      _callTel(tel) async {
        var url = "tel://$tel";
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          throw 'Could not call $url';
        }
      }

      List<Widget> _editrows=[
        Divider(),
        GestureDetector(
          onTap: (){
            _callTel(kid.tel);
          },
          child: _editRow(
            icon: Icons.phone,
            child: Text(kid.tel??"keine Nummer..",
              style: TextStyle(
                decoration: TextDecoration.underline,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
        Divider(),
        _editRow(
          icon: Icons.euro_symbol,
          child: Text(((kid.balance??0)/100).toString()+" €",
            style: TextStyle(
              color: kid.balance<0 ? Colors.red[400]: (Theme.of(context).brightness==Brightness.light ? Colors.green[800] : Colors.greenAccent[400]),
            ),
          ),
        ),
      ];
    
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(width:20),//Theme.of(context).iconTheme.size),
                  Container(
                      padding: EdgeInsets.only(top:10,bottom: 10),
                      child: Text(kid.name??"Kind ohne Namen",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),)
                  ),
                  IconButton(
                    icon: Icon(Icons.edit,color: Theme.of(context).cardColor,),
                    onPressed: (){
                      //TODO: add change kids name
                    },
                  ),
                ],
              ),
              ...
              _editrows,
            ],
          ),
        )
    );
  }

    Widget _groupView(Group g){
      print(g.toString());
      List<Kid>kids=g.kids;
      
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
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name??"neue Gruppe"),
      ),
      body: FutureBuilder<Group>(
        initialData: group,
        future: _getCurrentGroup(),
        builder: (BuildContext context, AsyncSnapshot<Group> snapshot) {
          print(snapshot);
              return _groupView(snapshot.data);
            },
      ),//TODO make body
    );
  }
}