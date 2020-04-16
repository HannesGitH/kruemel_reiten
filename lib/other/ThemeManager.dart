import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeChanger with ChangeNotifier{
  //init stuff
  factory ThemeChanger() => _instance;
  ThemeChanger._(){
    _themeDataHandler.getCurrentThemeID().then((int id){
      setTheme(id??0);
    });
    _themeDataHandler.getDarkness().then((int dn){
      setDarkness(dn??0);
    });
  }
  static final _ThemeDataHandler _themeDataHandler = _ThemeDataHandler(); 
  static final ThemeChanger _instance = ThemeChanger._();
  
  static const int themeCount=5;//this has to be the length of both of the following lists

  static final List<ThemeData> themeData_DARK = <ThemeData>[

    //red theme
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Color.fromARGB(255, 105, 90, 90),
      primaryColor: Colors.red,
      hintColor: Colors.white70,
      iconTheme: IconThemeData(size:30,color: Colors.red),
      accentColor: Colors.redAccent,
      //highlightColor: Colors.amberAccent,
    ),

    //bordeux theme
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Color.fromARGB(255, 135, 90, 120),
      primaryColor: Color.fromARGB(255, 235, 100, 120),
      hintColor: Colors.white70,
      iconTheme: IconThemeData(size:30,color: Colors.red),
      accentColor: Color.fromARGB(255, 255, 100, 120),
      //highlightColor: Colors.amberAccent,
    ),

    //blue theme
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.blueGrey[700],
      primaryColor: Colors.blue[200],
      hintColor: Colors.white70,
      accentColor: Colors.blueAccent[100],
      //highlightColor: Colors.amberAccent,
    ),

    //teal theme
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.black,
      cardColor: Colors.blueGrey[700],
      primaryColor: Colors.tealAccent,
      accentColor: Colors.teal,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),

    //black theme
    ThemeData(
      brightness: Brightness.dark,
      backgroundColor: Colors.grey[800],
      canvasColor: Colors.black,
      cardColor: Colors.grey[700],
      primaryColor: Colors.black,
      accentColor: Colors.white,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
  ];
  static final List<ThemeData> themeData_LIGHT = <ThemeData>[

    //red Theme
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Color.fromARGB(255, 105, 90, 90),
      primaryColor: Colors.red,
      hintColor: Colors.white70,
      highlightColor: Colors.amberAccent,
      iconTheme: IconThemeData(size:30,color: Colors.red),
      accentColor: Colors.redAccent
    ),

    //bordeux theme
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Color.fromARGB(255, 135, 90, 120),
      primaryColor: Color.fromARGB(255, 235, 100, 120),
      hintColor: Colors.white70,
      iconTheme: IconThemeData(size:30,color: Colors.red),
      accentColor: Color.fromARGB(255, 255, 100, 120),
      //highlightColor: Colors.amberAccent,
    ),

    //blue Theme
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Colors.blueGrey[400],
      primaryColor: Colors.blue,
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),

    //teal Theme
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      cardColor: Colors.blueGrey[400],
      primaryColor: Colors.teal,
      hintColor: Colors.white70,
      accentColor: Colors.tealAccent[700],
      //highlightColor: Colors.amberAccent,
    ),

    //white Theme
    ThemeData(
      brightness: Brightness.light,
      backgroundColor: Colors.white,
      canvasColor: Colors.white,
      cardColor: Colors.grey[300],
      primaryColor: Colors.grey[300],
      accentColor: Colors.grey[700],
      hintColor: Colors.white70,
      //highlightColor: Colors.amberAccent,
    ),
  ];
  
  static int currentTheme=0;
  int _isDark=0;//-1=LIGHT; 0=SYSTEM; 1=DARK

  int getDarkness()=>_isDark;
  void setDarkness(int dn){
    _themeDataHandler.setDarkness(dn);
    _isDark=dn;
    notifyListeners();
  }

  ThemeData getTheme_LIGHT() => _isDark==1?themeData_DARK[currentTheme]:themeData_LIGHT[currentTheme];
  ThemeData getTheme_DARK() => _isDark==-1?themeData_LIGHT[currentTheme]:themeData_DARK[currentTheme];

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
  Future<int> getDarkness()async{
    final SharedPreferences p = await _getPrefs();
    return p.getInt('darkness')??0;
  }
  Future<bool> setDarkness(int darkness)async{
    final SharedPreferences p = await _getPrefs();
    return await p.setInt('darkness',darkness);
  }

}
