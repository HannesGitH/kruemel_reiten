import 'package:flutter/material.dart';
import 'package:kruemelreiten/Widgets/Settings/DateSettings.dart';
import 'package:kruemelreiten/homePageWidgets/MainPageChildren/GroupLabels.dart';
import 'package:kruemelreiten/homePageWidgets/MainPageChildren/saturday.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:kruemelreiten/other/Persistent.dart';
import 'package:provider/provider.dart';

import 'MainPageChildren/MainSideBar.dart';

class MainPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DateChanger>(
      create: (_)=>DateChanger(),
      child: _MainPage(),
    );
  }
}

class _MainPage extends StatefulWidget{

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<_MainPage> {
  List<int> order;
@override
  void initState() {
    order=[0,1,2,3,4,5,6,7,8,9,10];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    final DateChanger dateMan = Provider.of<DateChanger>(context);
    bool isEverySecond=dateMan.isSecond()??true;
    int weekDay=dateMan.getDay()??5;

    double headHeight = 30;
    double estKH=40;
    double estWidth = 150;

    Future<int> _count()async{
      int count = await DataHandler().getGroupCount();
       order= await SmallDataHandler().getIndeces(count);
       return count;
    }

    Future<List<Group>> _allgroups = DataHandler().getAllGroups_noBalance();

        print('isEverySecond: $isEverySecond');
    return Scaffold(
      body: FutureBuilder<int>(
        initialData: 2,
        future: _count(),
        builder:(context,AsyncSnapshot<int> snap) {

          if(snap.data<2){
            return Center(child: Container(padding: EdgeInsets.all(30),child: Text("Füg doch unten links bitte mindestens 2 Gruppen hinzu")));
          }

          double avGH=headHeight+20+(estKH*3);

          double height = snap.data*avGH+15;
          double screenH = MediaQuery.of(context).size.height;

          double sbW=160;

          sideBar sb = sideBar(height: height,headHeight: headHeight,width: sbW,estKH:estKH);

          var startDay = DateTime.utc(2020,1,6+weekDay);//has to be a day corresponding to weekday
          var today = DateTime.now();
          var nthWeek = today.difference(startDay).inDays/7;

          double offset=estWidth*nthWeek+300;

          DateTime getNthSaturdaySinceStart(int n){
            var dt=startDay.add(Duration(days: 7*n));
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
                      switch (i){
                        case 0:
                          return Container(
                            color: Theme.of(context).cardColor,
                            width: sbW+60,
                            child: Align(
                              alignment: Alignment.bottomLeft,
                              child: GrouplabelColumn(headHeight: headHeight,estKH: estKH,)
                            ),
                          );
                          break;
                        case 1:
                          List<Widget> container=List.filled(snap.data, Container(
                          height: headHeight+estKH*3+20,
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
                          headHeight: headHeight,
                          estKH:estKH,
                          groupCount: snap.data,
                          groups: orderedgroups,
                          isEverySecond: isEverySecond,
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

