import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';

class GroupPage extends StatelessWidget{
  final DataHandler dataman=DataHandler();
  final Group group;
  GroupPage({this.group});

  Future<Group>_getCurrentGroup() async{
    List<Kid> kids= await dataman.getGroupMembersByName_complete(group.name);
    print (kids);
    return Group(name: group.name, kids:kids);
  }

  Widget _kidView(Kid kid){
    //TODO make this beautiful
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 8.0,
        margin: EdgeInsets.all(15),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    padding: EdgeInsets.only(top:10,bottom: 10),
                    child: Text(kid.name??"Kind ohne Namen",style: TextStyle(fontSize: 20,color: Colors.white,fontWeight: FontWeight.bold,),)
                ),
              ],
            ),
          ],
        )
    );
  }

  Widget _groupView(Group g){
    print(g.toString());
    List<Kid>kids=g.kids;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        _kidView(kids[0]),
        _kidView(kids[1]),
        _kidView(kids[2]),
        Container(height: 10,),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
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