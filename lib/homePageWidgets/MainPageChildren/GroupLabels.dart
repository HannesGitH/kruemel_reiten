import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';

class GrouplabelColumn extends StatelessWidget{
  final DataHandler dataman = DataHandler();
  Future<List<Group>> allgroups() async {
    return await dataman.getAllGroups_noBalance();
  }
  double height;
  GrouplabelColumn({@required this.height});

   @override
  Widget build(BuildContext context) {

     Widget group(Group group){
       return Transform.translate(
         offset: Offset(5,0),
         child: Container(
           padding: EdgeInsets.only(left:10,top:10),
           child: Card(
             margin: EdgeInsets.all(5),
             color: Theme.of(context).canvasColor,
             elevation: 10,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
             ),
             child: Container(
               padding: EdgeInsets.all(10),
               child: Column(
                 children: <Widget>[
                   Align(
                     alignment: Alignment.centerLeft,
                       child: Text(group.name),
                   ),
                 ],
               ),
             ),
           ),
         ),
       );
     }
    return Container(
      padding: EdgeInsets.only(left: 50),//wegen dem Offset schlonz
      height: height,
      child: FutureBuilder(
          future: allgroups(),
          builder: (context,AsyncSnapshot<List<Group>> snap){
            List<Widget> groups = List.generate(snap.data.length, (i){
              return Container(
                //color: Colors.red,
                //height: height/snap.data.length,
                child: group(snap.data[i]),
              );
            });
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: groups,
            );
          }
      ),
    );
  }
}
