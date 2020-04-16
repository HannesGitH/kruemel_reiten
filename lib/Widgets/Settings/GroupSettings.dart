import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupSettings extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GroupChanger>(
      create: (_)=>GroupChanger(),
      child: _GroupSettings()
    );
  }
}

class _GroupSettings extends StatefulWidget{
  @override
  _GroupSettingsState createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<_GroupSettings> {

  @override
  Widget build(BuildContext context) {
  final GroupChanger groupMan = Provider.of<GroupChanger>(context);
  int kidCount=groupMan.getKidCount()??5;

    return Container(
      padding: EdgeInsets.symmetric(horizontal:20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Gruppen' ,style: TextStyle(fontSize:22),),
              Text('(Änderungen hier benötigen ein Neuladen der App)', style: TextStyle(fontSize:10),),
              SizedBox(height:15),
              Text('Anzahl Schüler pro Gruppe ($kidCount)'),
              Slider(
                activeColor: Theme.of(context).accentColor,
                min: 1,
                max: 20,
                divisions: 20,
                value: kidCount.toDouble(), 
                label: kidCount.toString(),
                onChanged: (double d){setState(() {
                  groupMan.setKidCount(d.toInt());
                });}
              ),
              
            ],
          ),
        ],
      ),
    );
  }
}


class GroupChanger with ChangeNotifier{
  //init stuff
  GroupChanger(){
    _getPrefs().then((p){
      setKidCount(p.getInt('kidCount_perGroup')??3);
    });
  }
  SharedPreferences _prefs;
  Future<SharedPreferences> _getPrefs()async{
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs;
  }

  int _kidCount=5;
  int getKidCount()=>_kidCount;
  void setKidCount(int kidCount){
    _kidCount=kidCount;
    notifyListeners();
    _getPrefs().then((p){
      p.setInt('kidCount_perGroup', kidCount);
    });
  }
}
