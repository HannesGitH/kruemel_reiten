import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';

import 'MainPageChildren/MainSideBar.dart';

class MainPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    double estGH = 175;

    Future<int> _count = DataHandler().getGroupCount();

    return Scaffold(
      body: FutureBuilder<int>(
        initialData: 0,
        future: _count,
        builder:(context,AsyncSnapshot<int> snap) {

          double height = snap.data*estGH;

          sideBar sb = sideBar(height: height,estGH: estGH,);

          return SingleChildScrollView(
            child: Container(
              height: height,
              child: Stack(
                children: <Widget>[
                  ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, i) {
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
          );
        },
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: (){
          sb.toggle();
        },
      ),*/
    );
  }
}

