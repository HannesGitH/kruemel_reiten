import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DateSettings extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DateChanger>(
      create: (_)=>DateChanger(),
      child: _DateSettings()
    );
  }
}

class _DateSettings extends StatefulWidget{
  @override
  _DateSettingsState createState() => _DateSettingsState();
}

class _DateSettingsState extends State<_DateSettings> {
  final List<String> weekdays=<String>['Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag','Sonntag'];

  @override
  Widget build(BuildContext context) {
  final DateChanger dateMan = Provider.of<DateChanger>(context);
  bool isEverySecond=dateMan.isSecond()??true;
  int weekDay=dateMan.getDay()??5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal:20),
      child: Column(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Wochentag',style: TextStyle(fontSize:22),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text('nur jeden 2. ${weekdays[weekDay]}'),
                      Switch(
                        activeColor: Theme.of(context).accentColor,
                        value: isEverySecond, 
                        onChanged: (bool isActive){
                          setState(() {
                            dateMan.setIsSecond(isActive);
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              Text('(Änderungen hier benötigen ein Neuladen der Hauptseite)', style: TextStyle(fontSize:10),),
              SizedBox(height:15),
              ToggleButtons(
                fillColor: Theme.of(context).textTheme.body1.color.withAlpha(90),
                selectedColor: Theme.of(context).backgroundColor,
                renderBorder: false,
                children: List.generate(weekdays.length, (int wd){
                  return Text(weekdays[wd].substring(0,2));
                }),
                isSelected: List.generate(7, (int i){return i==weekDay;}),
                onPressed: (int i){setState(() {
                  dateMan.setDay(i);
                });},
              ),
            ],
          ),
        ],
      ),
    );
  }
}


class DateChanger with ChangeNotifier{
  //init stuff
  //factory DateChanger() => _instance;
  DateChanger(){
    _getPrefs().then((p){
      setDay(p.getInt('weekDay')??5);
      setIsSecond(p.getBool('isEverySecondWeekday')??true);
    });
  }
  //static final DateChanger _instance = DateChanger._();
  SharedPreferences _prefs;
  Future<SharedPreferences> _getPrefs()async{
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs;
  }

  int _day=5;
  int getDay()=>_day;
  void setDay(int day){
    _day=day;
    notifyListeners();
    _getPrefs().then((p){
      p.setInt('weekday', day);
    });
  }

  bool _second=true;
  bool isSecond()=>_second;
  void setIsSecond(bool isSec){
    _second=isSec;
    notifyListeners();
    _getPrefs().then((p){
      p.setBool('isEverySecondWeekday', isSec);
    });
  }

}
