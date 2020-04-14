import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier{
  //init stuff
  factory ThemeChanger() => _instance;
  ThemeChanger._(){
    _themeDataHandler.getCurrentThemeID().then((int id){
      setTheme(id??0);
    });
  }
  static final _ThemeDataHandler _themeDataHandler = _ThemeDataHandler(); 
  static final ThemeChanger _instance = ThemeChanger._();
  
  static const int themeCount=2;//this has to be the length of both of the following lists

  static final List<ThemeData> themeData_DARK = <ThemeData>[
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.blueGrey[700],
      primaryColor: Colors.red,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.blueGrey[700],
      primaryColor: Colors.blue[200],
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.blueGrey[700],
      primaryColor: Colors.tealAccent,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
  ];
  static final List<ThemeData> themeData_LIGHT = <ThemeData>[
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Colors.grey[400],
      primaryColor: Colors.red,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Colors.blueGrey[400],
      primaryColor: Colors.blue,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Colors.blueGrey[400],
      primaryColor: Colors.teal,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
  ];
  
  static int currentTheme=0;

  ThemeData getTheme_DARK() => themeData_DARK[currentTheme];
  ThemeData getTheme_LIGHT() => themeData_LIGHT[currentTheme];

  Future<void> setTheme(int themeID)async{
    currentTheme = themeID;
    notifyListeners();
    await _themeDataHandler.setCurrentThemeID(themeID);
    return;
  }

}

class _ThemeDataHandler{
  factory _ThemeDataHandler() => _instance;
  _ThemeDataHandler._(){
    print('init ThemeDataHandler');
  }
  SharedPreferences _prefs;
  Future<SharedPreferences> _getPrefs()async{
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs;
  }
  
  static final _ThemeDataHandler _instance = _ThemeDataHandler._();

  Future<int> getCurrentThemeID()async{
    final SharedPreferences p = await _getPrefs();
    return p.getInt('themeID');
  }
  Future<bool> setCurrentThemeID(int id)async{
    final SharedPreferences p = await _getPrefs();
    return await p.setInt('themeID',id);
  }

}
