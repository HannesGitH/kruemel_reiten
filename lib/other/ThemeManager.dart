import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier{
  ThemeData _themeData=ThemeData(
        brightness: Brightness.dark,
        backgroundColor: Colors.black,
        cardColor: Colors.blueGrey[700],
        primaryColor: Colors.tealAccent,
        hintColor: Colors.white70,
        //highlightColor: Colors.amberAccent,
  );
  static final ThemeChanger _instance = ThemeChanger._();
  ThemeChanger._(){

  }
  factory ThemeChanger() => _instance;

  getTheme() => _themeData;

  setTheme(ThemeData theme){
    _themeData = theme;
    notifyListeners();
  }

}

class _ThemeDataHandler{
  factory _ThemeDataHandler() => _instance;
  SharedPreferences _prefs;
  Future<SharedPreferences> getPrefs()async{
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs;
  }
  _ThemeDataHandler._(){
    print("init ThemeDataHandler");
  }
  static final _ThemeDataHandler _instance = _ThemeDataHandler._();

  //TODO: implement storing theme

}
