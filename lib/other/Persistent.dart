import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmallDataHandler{
  factory SmallDataHandler() => _instance;
  SharedPreferences prefs;
  SmallDataHandler._(){
    SharedPreferences.getInstance().then((p){
      prefs=p;
    });
  }
  static final SmallDataHandler _instance = SmallDataHandler._();
  void waitForPrefs(){
    while (prefs==null){}
    return;
  }
   List<int>getIndeces(int length){
     waitForPrefs();
     String order = prefs.getString('groupOrder');//??List.generate(length, (int i){return i.toString();}).reduce((combS,newS){return combS+newS;});
      if (order==null)return List.generate(length, (int i){return i;});
      List<int> indeces=[];
      for (int i=0;i<order.length;i++){
        int val = int.parse(order[i]);
        if(val<length)indeces.add(val);
      }
      return indeces;
   }
  
  void setOrder(List<int> order)async{
    waitForPrefs();
    prefs.setString('groupOrder', order.fold('',(String combI, int newI){return combI+newI.toString();}));
    return;
  }

}
