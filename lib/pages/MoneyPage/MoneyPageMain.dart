import 'package:flutter/material.dart';

class MoneyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SlideWrap();
  }
}

///animates its children depending on slides
class SlideWrap extends StatefulWidget {
  SlideWrap({this.swipeThreshHold=150.0,this.renderExtend,@required this.children});

  ///how far the user has to swipe to complete it
  double swipeThreshHold;

  ///how many widgets are rendered
  int renderExtend;

  ///the children need to implement a percent value
  List<PercentWidget> children;

  @override
  _SlideWrapState createState() => _SlideWrapState();
}

class _SlideWrapState extends State<SlideWrap> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  double swipeLength=0;
  double swipePercent=0;
  double scaledSwipeLength=0;

  double dragStartX=0;

  void reset(){
    setState(() {
      dragStartX=0;
      swipeLength=0;
      swipePercent=0;
      scaledSwipeLength=0;
    });
  }

  void updateSwipe(double swipeDiff,BuildContext context){
    setState(() {
      swipeLength+=swipeDiff;
      scaledSwipeLength=swipeLength*100/MediaQuery.of(context).size.width;
      swipePercent=scaledSwipeLength>100?100:(scaledSwipeLength<-100?-100:scaledSwipeLength);
    });
  }
  void endSwipe(double swipeEndVel){
    print('swipeEnded');
    double begin=swipePercent;
    double end=swipeLength.abs()>=widget.swipeThreshHold?(swipeLength.isNegative?-1.0:1.0)*100:0;
    animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        setState(() {
          swipePercent=animation.value;
          if(animation.isCompleted||animation.isDismissed){
            reset();
          }
        });
      });

    controller.reset();
    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onHorizontalDragUpdate: (DragUpdateDetails dut){
        updateSwipe(dut.primaryDelta,context);
      },
      onHorizontalDragEnd: (DragEndDetails det){
        endSwipe(det.primaryVelocity);
      },
      onHorizontalDragStart: (DragStartDetails dst){
        dragStartX=dst.globalPosition.dx;
        print('dsy: $dragStartX');
      },
      child: Stack(
        children: <Widget>[
          Container(constraints: BoxConstraints.expand(),child: Text(''),),
          Transform.translate(
            offset: Offset(swipePercent*8-300,0),
            child: Container(
              width:300,
              height:300,
              color:Colors.red,
            ),
          ),
          Transform.translate(
            offset: Offset(swipePercent*11-300,100),
            child: Container(
              width:230,
              height:230,
              color:Colors.green,
            ),
          ),
          Transform.translate(
            offset: Offset(swipePercent*8+500,0),
            child: Container(
              width:300,
              height:300,
              color:Colors.red,
            ),
          ),
          Transform.translate(
            offset: Offset(swipePercent*11+500,100),
            child: Container(
              width:230,
              height:230,
              color:Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class PercentWidget extends StatefulWidget {
  double percent;
}

