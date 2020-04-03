import 'package:flutter/material.dart';

class SaturdayCol extends StatelessWidget{
  DateTime saturday;
  double width;
  double estGH;

  int groupCount;

  SaturdayCol(DateTime saturday, {this.width=400, this.estGH, this.groupCount=2}){
    this.saturday=saturday;
  }

  List<String> months=["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Container(
        padding: EdgeInsets.only(bottom:20, left:20, top:20),
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
                  
                ],
              ),
            ),
            _saturdayAppointments(
              sat: saturday,
              estGH: estGH,
              groupCount: groupCount,
            ),
          ],
        ),
      ),
    );
  }
}


class _saturdayAppointments extends StatelessWidget{
  DateTime sat;

  double estGH;
  int groupCount;

  _saturdayAppointments({@required this.sat,this.estGH=160,this.groupCount=2});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return FutureBuilder(

      builder: (context, snap){
        return Container(
              padding: EdgeInsets.all(20),
              height: 200,
              color: Colors.amberAccent,
              child: Text("numero ${sat.toString()}"),
            );
    });
    
  }
}