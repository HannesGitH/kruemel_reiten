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
       return Text("duzidei");
     }
    return Container(
      height: height,
      child: FutureBuilder(
          future: allgroups(),
          builder: (context,AsyncSnapshot<List<Group>> snap){
            List<Widget> groups = List.generate(snap.data.length, (i){
              return Container(
                color: Colors.red,
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
