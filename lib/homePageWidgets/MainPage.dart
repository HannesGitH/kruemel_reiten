import 'package:flutter/material.dart';

import 'MainPageChildren/MainSideBar.dart';

class MainPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height*1.5;

    sideBar sb =sideBar(height: height);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context,i){
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        height: 200,
                        color: Colors.amberAccent,
                        child: Text("numero $i  ;"),
                      ),
                    );
                  }
              ),
              sb,
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          sb.toggle();
        },
      ),
    );
  }
}

