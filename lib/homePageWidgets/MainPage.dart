import 'package:flutter/material.dart';
import 'package:kruemelreiten/homePageWidgets/MainPageChildren/GroupLabels.dart';
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

          if(snap.data<3){
            return Center(child: Container(padding: EdgeInsets.all(30),child: Text("Füg doch unten links bitte mindestens 2 Gruppen hinzu")));

          }

          double height = snap.data*estGH+15;
          double screenH = MediaQuery.of(context).size.height;

          double sbW=160;

          sideBar sb = sideBar(height: height,estGH: estGH,width: sbW,);

          Widget _mainPage=Stack(
            children: <Widget>[
              ListView.builder(
                  padding: EdgeInsets.all(0),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    List<Widget> container=List.filled(snap.data, Container(
                      height: estGH,
                      width: 20,
                      padding: EdgeInsets.only(top:10),
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        color: Theme.of(context).backgroundColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                        ),
                      ),),);
                    switch (i){
                      case 0:
                        return Container(
                            color: Theme.of(context).cardColor,
                            width: sbW+60,
                            child: GrouplabelColumn(estGH: estGH,)
                        );
                        break;
                      case 1:
                        return Container(
                          width: 35,
                          color: Theme.of(context).cardColor,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              children: container,
                            ),
                          ),
                        );
                        break;
                    }
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
          );


          if (height<screenH-70){
            return Container(child: _mainPage);
          }
          return SingleChildScrollView(
            child: Container(
              height: height,
              child: _mainPage,
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

