import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:kruemelreiten/other/Persistent.dart';

class GrouplabelColumn extends StatelessWidget{
  final DataHandler dataman = DataHandler();
  Future<List<Group>> allgroups() async {
    List<Group> groups=await dataman.getAllGroups_noBalance();
    List<int>order=await SmallDataHandler().getIndeces(groups.length);
    List<Group> orderedgroups=List.generate(groups.length, (int i){
      return groups[order[i]??i];
    });
    return orderedgroups;//return groups;
  }
  double headHeight;
  double estKH;
  GrouplabelColumn({@required this.headHeight,this.estKH=35});

   @override
  Widget build(BuildContext context) {
    double kiddoOff=2;
    double groupOff=5;
    double groupMargin=5;
    double headlineOff=10;
    double headlineHeight=headHeight-headlineOff-2;
    double mainPadding=5;

     Widget kiddo(String name){
       return Container(
         height: estKH,
         padding: EdgeInsets.only(bottom:kiddoOff,right: 10),
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
           padding: EdgeInsets.only(left:5,bottom:groupOff),
           child: Card(
             margin: EdgeInsets.all(groupMargin),
             color: Theme.of(context).backgroundColor,
             elevation: 10,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
             ),
             child: Column(
               mainAxisSize: MainAxisSize.max,
               children: <Widget>[
                 Container(
                   padding: EdgeInsets.only(left:10,top:headlineOff),
                   child: Align(
                     alignment: Alignment.centerLeft,
                       child: Container(height: headlineHeight, child: Text(group.name)),
                   ),
                 ),
                 Divider(height: 2,),
                 Column(
                   mainAxisAlignment: MainAxisAlignment.spaceAround,
                   mainAxisSize: MainAxisSize.max,
                   children: group.kids.map((Kid kid){return kiddo(kid.name);}).toList(),
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
                padding: EdgeInsets.only(bottom:mainPadding),
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
