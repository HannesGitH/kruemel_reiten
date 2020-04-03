import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';

class SaturdayCol extends StatelessWidget{
  DateTime saturday;
  double width;
  double estGH;

  int groupCount;
  List<List<String>> kidnames;

  SaturdayCol(DateTime saturday, {this.width=400, this.estGH, this.groupCount=2,this.kidnames}){
    this.saturday=saturday;
  }

  List<String> months=["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom:5, left:20, top:20),
      width: width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          RotatedBox(
            quarterTurns: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  "${saturday.year.toString()}",
                  style: TextStyle(fontSize:10,fontWeight: FontWeight.w400),
                ),
                SizedBox(width: 40),
                Text(
                  "${saturday.day.toString()}.",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize:20),
                ),
                Text(
                  "${months[saturday.month-1]}",
                  style: TextStyle(fontSize:20,fontWeight: FontWeight.w200),
                ),
                SizedBox(width: 40),
              ],
            ),
          ),
          _saturdayAppointments(
            sat: saturday,
            estGH: estGH,
            groupCount: groupCount,
            width: width-60,
            kidnames: kidnames,
          ),
        ],
      ),
    );
  }
}


class _saturdayAppointments extends StatelessWidget{
  DateTime sat;

  double estGH;
  double width;
  int groupCount;
  List<List<String>> kidnames;

  _saturdayAppointments({@required this.sat,this.estGH=160,this.groupCount=2,this.width=200,this.kidnames});

  Future<List<Lesson>> _getLessons()async{return await DataHandler().getLessonsOnDay(sat);}

  Widget _design({@required List<Widget> children}){
    List<Widget> _list = List.generate(children.length, (i){
      return Container(
        padding: EdgeInsets.symmetric(vertical:5),
        height: estGH,
        child: Card(
          margin: EdgeInsets.all(5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: width,
              child: children[i]
            ),
          ),
        ),
      );
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: _list,
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return FutureBuilder<List<Lesson>>(
      future: _getLessons(),
      initialData: [],
      builder: (context, AsyncSnapshot<List<Lesson>> snap){
        if(kidnames == null){
          return  _design(
            children: List.filled(groupCount, Center(child: CircularProgressIndicator(backgroundColor: Colors.white,))),
          );
        }
        return  _design(
          children: List.filled(groupCount, Center(child: Container(color: Colors.red,))),
        );
    });
    
  }
}
