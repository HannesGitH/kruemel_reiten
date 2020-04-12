import 'package:flutter/material.dart';
import 'package:kruemelreiten/homePageWidgets/MainPageChildren/GroupLabels.dart';
import 'package:kruemelreiten/homePageWidgets/MainPageChildren/saturday.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:kruemelreiten/other/Persistent.dart';

import 'MainPageChildren/MainSideBar.dart';

class MainPage extends StatefulWidget{

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<int> order;
@override
  void initState() {
    order=[0,1,2,3,4,5,6,7,8,9,10];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    double estGH = 175;
    double estWidth = 150;

    Future<int> _count()async{
      int count = await DataHandler().getGroupCount();
       order= await SmallDataHandler().getIndeces(count);
       return count;
    }

    Future<List<Group>> _allgroups = DataHandler().getAllGroups_noBalance();

    return Scaffold(
      body: FutureBuilder<int>(
        initialData: 2,
        future: _count(),
        builder:(context,AsyncSnapshot<int> snap) {

          if(snap.data<2){
            return Center(child: Container(padding: EdgeInsets.all(30),child: Text("Füg doch unten links bitte mindestens 2 Gruppen hinzu")));
          }

          double height = snap.data*estGH+15;
          double screenH = MediaQuery.of(context).size.height;

          double sbW=160;

          sideBar sb = sideBar(height: height,estGH: estGH,width: sbW,);

          var startDay = DateTime.utc(2020,1,4);//has to be a saturday
          var today = DateTime.now();
          var nthWeek = today.difference(startDay).inDays/7;

          double offset=estWidth*nthWeek+300;

          DateTime getNthSaturdaySinceStart(int n){
            var dt=startDay.add(Duration(days: 7*n));
            print(n);
            print(dt.toString());
            return dt;
          }

          ScrollController horizontalScrollController = ScrollController(initialScrollOffset: offset);

          Widget _mainPage=Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              FutureBuilder(
                future: _allgroups,
                builder: (cantext, AsyncSnapshot<List<Group>> snapSchot){
                  return ListView.builder(
                    cacheExtent: 10,
                    controller: horizontalScrollController,
                    padding: EdgeInsets.all(0),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, i) {
                      List<Widget> container=List.filled(snap.data, Container(
                        height: estGH,
                        width: 20,
                        padding: EdgeInsets.only(bottom:10),
                        child: Card(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 0),
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
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: GrouplabelColumn(estGH: estGH,)
                            ),
                          );
                          break;
                        case 1:
                          return Container(
                            width: 35,
                            color: Theme.of(context).cardColor,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: container,
                              ),
                            ),
                          );
                          break;
                      }
                      List<Group> orderedgroups;
                      if(snapSchot.hasData){
                        orderedgroups=List.generate(snap.data, (int i){
                          return snapSchot.data[order[i]];
                        });
                      }
                      return Align(
                        alignment: Alignment.bottomLeft,
                        child: SaturdayCol(getNthSaturdaySinceStart(i-2),//da ja 2 cols schon auf die ersten draufgehen
                          width: estWidth,
                          estGH: estGH,
                          groupCount: snap.data,
                          groups: orderedgroups,
                        ),
                      );
                    }
                );
              }),
              sb,
            ],
          );


          if (height<screenH-100){
            return Container(child: _mainPage);
          }
          return SingleChildScrollView(
            child: Container(
              height: height+10,
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

