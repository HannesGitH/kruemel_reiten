
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/Database.dart';
import 'package:vibration/vibration.dart';

class SaturdayCol extends StatelessWidget{
  DateTime saturday;
  double width;
  double estGH;

  int groupCount;
  List<Group> groups;

  bool isEverySecond;

  SaturdayCol(DateTime saturday, {this.width=400, this.estGH, this.groupCount=2,this.groups,this.isEverySecond}){
    this.saturday=saturday;
  }

  List<String> months=["Januar","Februar","März","April","Mai","Juni","Juli","August","September","Oktober","November","Dezember"];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom:5, left:10, top:20),
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
            width: width-50,
            groups: groups,
            isEverySecond: isEverySecond,
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
  List<Group> groups;
  bool isEverySecond;

  _saturdayAppointments({@required this.sat,this.estGH=160,this.groupCount=2,this.width=200,this.groups,this.isEverySecond=true});

  Future<List<Lesson>> _getLessons()async{return await DataHandler().getLessonsOnDay(sat);}

  Lesson _getLessonFromKid({@required List<Lesson> lessons, @required String name}){
    for(int i=0; i<lessons.length; i++){
      if (lessons[i].kid.name==name){
        return lessons[i];
      }
    }
    return Lesson(
      kid: Kid(name: name),
      date:sat,
    );
  }

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

    return FutureBuilder<List<Lesson>>(
      future: _getLessons(),
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot<List<Lesson>> snap){
        if(groups == null){
          return  _design(
            children: List.filled(groupCount, Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            )),
          );
        }
        return  _design(
          children: List.generate(groupCount, (int i){
            if(isEverySecond&&(groups[i].isSec!=(sat.millisecondsSinceEpoch/1000/3600/24)%14<8)){//jeder 2ter samstag
              return Center(child: Stack(
                key: UniqueKey(),
                alignment: Alignment.bottomLeft,
                children: <Widget>[
                  _AppointmentIndicator(
                    lessons: List.generate(groups[i].kids.length,(j){
                      return _getLessonFromKid(lessons: snap.data, name: groups[i].kids[j].name);
                    }),
                  ),
                  Positioned.fill(
                    child: /*IgnorePointer*/Container(//Use ignorePointer to enable touches of underlaying widget
                      child: Container(
                        padding: EdgeInsets.all(20),
                        color: Theme.of(context).cardColor.withAlpha(200),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Text("kein unterricht",style: TextStyle(color: Colors.white),),
                        ),
                        ),
                    ),
                  ),
                ],
              ));
            }
            return Center(
              key: UniqueKey(),
              child:_AppointmentIndicator(
                lessons: List.generate(groups[i].kids.length,(j){
                  return _getLessonFromKid(lessons: snap.data, name: groups[i].kids[j].name);
                }),
              ),
            );
          }),
        );
    });
    
  }
}

class _AppointmentIndicator extends StatefulWidget{

  //has to be filled cause the kids names are coming from there
  List<Lesson> lessons;

  _AppointmentIndicator({@required this.lessons});

  @override
  State<StatefulWidget> createState() => _AppointmentIndicatorState();
}

class _AppointmentIndicatorState extends State<_AppointmentIndicator>{


  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          height: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Icon(Icons.hdr_weak,size: 15,color: Colors.white,),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(math.pi),child:Icon(Icons.hdr_strong, size:15,color: Colors.white),),
            ],
          ),
        ),
      ]+
        List.generate(widget.lessons.length, (i){
          return Expanded(
            child: Card(
              clipBehavior: Clip.antiAlias,
              color: Colors.grey,
              margin: EdgeInsets.all(5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: _kidGetter(lesson:widget.lessons[i]),
            ),
          );
        }),
    );
  }
}

class _kidGetter extends StatefulWidget{

  
  //has to be non-null cause the kids names are coming from there
  Lesson lesson;

  _kidGetter({@required this.lesson});

  @override
  State<StatefulWidget> createState() => _kidGetterState();
}

class _kidGetterState extends State<_kidGetter>{
  String r_name;
  Presence presence;
  bool gotReplace=false;

  Future click()async {
    if (await Vibration.hasVibrator()) {
        Vibration.vibrate(duration: 20);
    }
    return;
  }

  Future<void> _fillNames({onNameClicked(String name),onCancel()}) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            title: Text('Wen gabs denn als Ersatz?'),
            content: SingleChildScrollView(
              child: FutureBuilder(
                future: DataHandler().getAllGroups_onlyNames(),
                initialData: [['wait','wait','wait'],['wait','wait','wait'],['wait','wait','wait'],['wait','wait','wait']],
                builder: (BuildContext con, AsyncSnapshot<List<List<String>>> snap){
                  return Column(
                    children: snap.data.map((List<String> kids)=>
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: kids.map((String name)=>
                            FlatButton(
                              onPressed: (){
                                onNameClicked(name);
                                Navigator.of(context).pop();
                              },
                              child: Text(name),
                            ),
                          ).toList(),
                        ),
                      ),
                    ).toList(),
                  );
                },
              )
            ),
            actions: <Widget>[
              Container(
                width: 150,
                child: TextField(
                  maxLength: 15,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: "jemand anderes",
                  hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w300,
                    fontSize: Theme.of(context).textTheme.body1.fontSize-1,
                  ),
                ),
                style: TextStyle(
                  color: Theme.of(context).textTheme.body1.color,
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.body1.fontSize+2,
                ),
                textAlign: TextAlign.center,
                onSubmitted: (x){
                  onNameClicked(x);
                  Navigator.of(context).pop();
                },
              ),
              ),
              FlatButton(
                child: Text('Abbruch',style: TextStyle(color: Theme.of(context).primaryColor),),
                onPressed: () {
                  onCancel();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

  Lesson _changePresenceOfLesson(Lesson lesson,Presence presence){
    return Lesson(
      date: lesson.date,
      presence: presence,
      isPaid: lesson.isPaid,
      kid: lesson.kid,
      description: lesson.description,
      replacement: lesson.replacement,
    );
  }
  Lesson _changeReplacementOfLesson(Lesson lesson,String replacement){
    return Lesson(
      date: lesson.date,
      presence: lesson.presence,
      isPaid: lesson.isPaid,
      kid: lesson.kid,
      description: lesson.description,
      replacement: replacement,
    );
  }

  Presence nextPresence(Presence presence){
    switch (presence){
      case Presence.wasThere:
        return Presence.canceledNot;
      case Presence.canceledNot:
        return Presence.canceledJust;
      case Presence.canceledJust:
        if(gotReplace)return Presence.canceledInTime_withReplacement;
        return Presence.canceledInTime;
      default: 
        return Presence.wasThere;
    }
  }

  @override
  void initState() {
    r_name=widget.lesson.replacement??'Ersatz gef.';
    presence=widget.lesson.presence??Presence.future;
    gotReplace=presence==Presence.canceledInTime_withReplacement;
    super.initState();
  }

  Widget _container({Color color, String text}){
    return Container(
      color: color,
      child: Center(
        child: Text(text,style: TextStyle(color: Colors.white),),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget kidGetter({Presence presence, @required String name}){
      switch (presence){
      case Presence.wasThere:
        return _container(color: Colors.green, text: "war da");
      case Presence.canceledNot:
        return _container(color: Colors.red, text: "nicht Abg.");
      case Presence.canceledJust:
        return _container(color: Colors.orange, text: "knapp Abg.");
      case Presence.canceledInTime:
        return _container(color: Colors.teal, text: "Abgesagt");
      case Presence.canceledInTime_withReplacement:
        return _container(color: Colors.tealAccent[700], text: "E: $r_name");
      
      default: 
        return _container(color: Colors.grey, text: "no data");
    }
    };

    return InkWell(
      onTap: (){setState(() {
        presence= nextPresence(presence);
        DataHandler().setLesson(_changePresenceOfLesson(widget.lesson, presence));
      });},
      onLongPress: (){
        var pre = presence;
        click();
        if(presence==Presence.canceledInTime_withReplacement){
          setState(() {
            presence=Presence.canceledInTime;
            gotReplace=false;
          });
          DataHandler().setLesson(_changePresenceOfLesson(widget.lesson, presence));
          return;
        }
        _fillNames(onNameClicked:(String nname){
          setState(() {
            r_name=nname;
            presence=Presence.canceledInTime_withReplacement;
            gotReplace=true;
            DataHandler().setLesson(_changeReplacementOfLesson( _changePresenceOfLesson(widget.lesson, presence),nname));
            return;
          });
        },onCancel: (){
          setState(() {
            presence=pre;
            gotReplace=false;
          });
          DataHandler().setLesson(_changePresenceOfLesson(widget.lesson, presence));
          return;
        }
        );
      },
      child: kidGetter(
        name: widget.lesson.kid.name, 
        presence: presence,
      ),
    );
  }
}