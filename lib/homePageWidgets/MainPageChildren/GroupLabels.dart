import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:kruemelreiten/other/Persistent.dart';

class GrouplabelColumn extends StatelessWidget{
  final DataHandler dataman = DataHandler();
  Future<List<Group>> allgroups() async {
    List<Group> groups=await dataman.getAllGroups_noBalance();
    List<int>order=await SmallDataHandler().getIndeces(groups.length);
    List<Group> orderedgroups=List.generate(groups.length, (int i){
      return groups[order[i]];
    });
    return orderedgroups;//return groups;
  }
  double estGH;
  GrouplabelColumn({@required this.estGH});

   @override
  Widget build(BuildContext context) {

     Widget kiddo(String name){
       return Container(
         padding: EdgeInsets.only(bottom:18,right: 10),
         child: Align(
           alignment: Alignment.centerRight,
           child: Text("$name : ",style: TextStyle(fontWeight: FontWeight.w600,fontSize: 16),),
         ),
       );
     }

     Widget group(Group group){
       return Transform.translate(
         offset: Offset(5,0),
         child: Container(
           padding: EdgeInsets.only(left:5,bottom:10),
           child: Card(
             margin: EdgeInsets.all(5),
             color: Theme.of(context).backgroundColor,
             elevation: 10,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
             ),
             child: Column(
               mainAxisSize: MainAxisSize.max,
               children: <Widget>[
                 Container(
                   padding: EdgeInsets.only(left:10,top:10),
                   child: Align(
                     alignment: Alignment.centerLeft,
                       child: Text(group.name),
                   ),
                 ),
                 Divider(),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   mainAxisSize: MainAxisSize.max,
                   children: <Widget>[
                     kiddo(group.kids[0].name),
                     kiddo(group.kids[1].name),
                     kiddo(group.kids[2].name),
                   ],
                 ),
               ],
             ),
           ),
         ),
       );
     }
    return Container(
      padding: EdgeInsets.only(left: 50),//wegen dem Offset schlonz
      child: FutureBuilder<List<Group>>(
          initialData: [],
          future: allgroups(),
          builder: (context,AsyncSnapshot<List<Group>> snap){
            List<Widget> groups = List.generate(snap.data.length, (i){
              return Container(
                //color: Colors.red,
                height: estGH,
                child: group(snap.data[i]),
              );
            });
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: groups,
            );
          }
      ),
    );
  }
}
