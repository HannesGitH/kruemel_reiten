import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';

class GroupPage extends StatelessWidget{
  final DataHandler dataman=DataHandler();
  final Group group;
  GroupPage({this.group});

  Future<Group>_getCurrentGroup()async{
    List<Kid> kids=await dataman.getGroupMembersByName_complete(group.name);
    return Group(name: group.name, kids:kids);
  }

  Widget _kidView(Kid kid){
    //TODO make this beautiful
    return Text(kid.toString());
  }

  Widget _groupView(Group g){
    List<Kid>kids=g.kids;
    return Column(
      children: <Widget>[
        _kidView(kids[0]),
        _kidView(kids[0]),
        _kidView(kids[0]),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(group.name??"neue Gruppe"),
      ),
      body: Column(
        children: <Widget>[
          Center(child: Text("hier wird später mehr info zur Grupe zu sehen sein")),
        ],
      ),//TODO make body
    );
  }
}