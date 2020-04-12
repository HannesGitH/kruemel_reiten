import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmallDataHandler{
  factory SmallDataHandler() => _instance;
  SharedPreferences _prefs;
  Future<SharedPreferences> getPrefs()async{
    return _prefs??await SharedPreferences.getInstance();
  }
  SmallDataHandler._(){
    print("init SmalldataHandler");
  }
  static final SmallDataHandler _instance = SmallDataHandler._();
  
   Future<List<int>>getIndeces(int length)async{
     String order = (await getPrefs()).getString('groupOrder');//??List.generate(length, (int i){return i.toString();}).reduce((combS,newS){return combS+newS;});
      if (order==null)return List.generate(length, (int i){return i;});
      List<int> indeces=[];
      for (int i=0;i<order.length;i++){
        int val = int.parse(order[i]);
        if(val<length)indeces.add(val);
      }
      return indeces;
   }
  
  void setOrder(List<int> order)async{
    (await getPrefs()).setString('groupOrder', order.fold('',(String combI, int newI){return combI+newI.toString();}));
    return;
  }

}
