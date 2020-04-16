import 'package:flutter/material.dart';
import 'package:kruemelreiten/other/ThemeManager.dart';

class ThemeSettings extends StatefulWidget{

  @override
  _ThemeSettingsState createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings> {
  int _currentTheme;
  ThemeChanger themeManager=ThemeChanger();
  static int themeCount=ThemeChanger.themeCount;
  int isDark=0;


  Widget headline(){return Container(
    padding: const EdgeInsets.symmetric(horizontal:20, vertical: 0),
    alignment: Alignment.bottomLeft,
    child: 
      Text('Thema ${_currentTheme+1}',
        style: TextStyle(fontSize:22),
      ),
  );}


  Widget themeChooser(int ct){
    List<Widget> chosers = List.generate(themeCount, (int i){
      return Container(
        padding: EdgeInsets.all(10),
        child: _themeChooseButton(
          theme: ThemeChanger.themeData_LIGHT[i],
          darkTheme: ThemeChanger.themeData_DARK[i],
          onChosen: (){
            setState(() {
              _currentTheme=i;
              themeManager.setTheme(i);
            });
          },
          isChosen: _currentTheme==i,
          isDark: isDark,
        ),
      );
    });
    
    return SingleChildScrollView(child:Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: chosers,
  ),);}

  @override
  Widget build(BuildContext context) {
    
  Widget darkModeToggle(){return Container(
    padding: const EdgeInsets.symmetric(horizontal:20, vertical: 0),
    alignment: Alignment.bottomLeft,
    child: 
      Row(
        children: <Widget>[
          IconButton(icon: Icon(Icons.wb_sunny,color: isDark==-1?Theme.of(context).accentColor:Colors.grey), onPressed: (){
            setState(() {
               isDark=-1;
               themeManager.setDarkness(isDark);
            });
          }),
          IconButton(icon: Icon(Icons.brightness_3,color: isDark==1?Theme.of(context).accentColor:Colors.grey), onPressed: (){
            setState(() {
               isDark=1;
               themeManager.setDarkness(isDark);
            });
          }),
          IconButton(icon: Icon(Icons.settings,color: isDark==0?Theme.of(context).accentColor:Colors.grey), onPressed: (){
            setState(() {
               isDark=0;
               themeManager.setDarkness(isDark);
            });
          }),
        ],
      ),
  );}

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            headline(),
            darkModeToggle(),
          ],
        ),
        const SizedBox(height:10,),
        themeChooser(_currentTheme),
      ]
    );
  }

  @override
  void initState() {
    print('themeCount : $themeCount');
    _currentTheme = ThemeChanger.currentTheme;
    isDark=themeManager.getDarkness();
    super.initState();
  }
}

class _themeChooseButton extends StatefulWidget{
  _themeChooseButton({@required this.theme,@required this.darkTheme, this.isDark=0, this.isChosen=false, @required this.onChosen});
  ThemeData theme;
  ThemeData darkTheme;
  int isDark=0;
  bool isChosen=false;
  Function onChosen=(){};

  @override
  __themeChooseButtonState createState() => __themeChooseButtonState();
}

class __themeChooseButtonState extends State<_themeChooseButton> {
  bool isChosen=false;
  @override
  void initState() {
    isChosen = widget.isChosen;
    super.initState();
  }

  void onClick(){
    setState(() {
      //isChosen ^=true;
      widget.onChosen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Transform.scale(
        scale: widget.isChosen?1.2:1,
        child: Transform.rotate(
          angle: 1,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: widget.isChosen ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  spreadRadius: -7,
                  blurRadius: 10,
                  color: Theme.of(context).textTheme.body1.color.withAlpha(70),
                ),
              ]
            ):null,
            child: ClipOval(
              child: Column(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      gradient:LinearGradient(colors:[
                         widget.theme.primaryColor,
                         widget.theme.canvasColor,
                         widget.theme.accentColor,
                         widget.theme.cardColor,
                      ]),
                    ),
                    height: 28-(widget.isDark*10).toDouble(),
                    width:60,
                  ),
                  Container(height:4,),
                  Container(
                    decoration: BoxDecoration(
                      gradient:LinearGradient(colors:[
                         widget.darkTheme.primaryColor,
                         widget.darkTheme.canvasColor,
                         widget.darkTheme.accentColor,
                         widget.darkTheme.cardColor,
                      ]),
                    ),
                    height: 28+(widget.isDark*10).toDouble(),
                    width:60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}