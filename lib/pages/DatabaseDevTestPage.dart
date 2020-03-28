import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';


////This Page is just for dev test purposes TODO remove file



class DatabaseTestPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1.5;

    sideBar sb =sideBar(height: height);
    return Scaffold(
      appBar: AppBar(
        title: Text("Nur Für Hannes"),
        ),
        body: SingleChildScrollView(
          child: Container(
            height: height,
            child: Stack(
              children: <Widget>[
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,i){
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        height: 200,
                        color: Colors.amberAccent,
                        child: Text("numero $i  ;"),
                      ),
                    );
                  }
                ),
                sb,
              ],
            ),
          ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          sb.out();
        },
      ),
    );
  }
}

class sideBar extends StatefulWidget{
  AnimationController _c;
  double width;
  double height=200;

  out(){_c.forward();}
  rin(){_c.reverse();}

  sideBar({@required this.height, this.width=200});

  @override
  State<StatefulWidget> createState() => _sideBarState();
}

class _sideBarState extends State<sideBar>  with SingleTickerProviderStateMixin{
  Animation<double> animation;
  AnimationController controller;
  double xOff=0;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(seconds: 2), vsync: this);
    widget._c=controller;
    animation = Tween<double>(begin: -widget.width , end: 0).animate(CurvedAnimation(parent: controller,curve: Curves.elasticOut))
      ..addListener(() {
        setState(() {
        });
      });
    //controller.forward();
  }
  @override
  Widget build(BuildContext context) {
    xOff=animation.value;
    return Transform.translate(
      offset: Offset(xOff,0),
      child: Container(
        color: Colors.red,
        width: widget.width,
        height: widget.height,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}