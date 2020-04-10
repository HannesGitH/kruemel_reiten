import 'package:flutter/material.dart';
import 'package:kruemelreiten/homePageWidgets/MainPageChildren/GroupLabels.dart';

class sideBar extends StatefulWidget{
  AnimationController _c;
  double width;
  double height=200;
  double estGH;

  bool isOut=false;

  sideBar({@required this.height,this.width=160,this.estGH=100});

  toggle(){isOut?rin():out();print("sideBar toggled");}
  out(){_c.forward();isOut=true;}
  rin(){_c.reverse();isOut=false;}

  @override
  State<StatefulWidget> createState() => _sideBarState();
}

class _sideBarState extends State<sideBar>  with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;
  double xOff = 0;
  int alpha = 255;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    widget._c = controller;
    animation = Tween<double>(begin: -widget.width, end: 0).animate(
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn))
      ..addListener(() {
        setState(() {});
      });
    //controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    widget._c = controller;

    xOff = animation.value;
    alpha = (((-xOff/widget.width)*255).floor());
    return Transform.translate(
      offset: Offset(xOff, 0),
      child: Container(
        width: widget.width+50,
        height: widget.height+15,
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: <Widget>[
            Transform.translate(
              offset: Offset(-50, 0),
              child: Container(
                width: widget.width,
                height: widget.height+10,
                child: GestureDetector(
                  onTap: (){
                    print("tapped");
                    widget.toggle();
                  },
                  child: CustomPaint( //TODO maybe mak the gnubbel not scrollable
                    painter: _sideBarBG(
                      color: Theme.of(context).canvasColor,//.withAlpha(alpha),
                      gSize: (-xOff/widget.width)*70
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(offset: Offset(-50,0),child: GrouplabelColumn(estGH: widget.estGH,)),
            Transform.translate(
              offset: Offset(0, 0),
                child: IconButton(
                    icon: Icon(widget.isOut?Icons.chevron_left:Icons.chevron_right,color: Theme.of(context).accentColor,),
                    onPressed: (){
                      print("icon pressed");
                      widget.toggle();
                    },
                ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class _sideBarBG extends CustomPainter {

  //gnubbelParameter
  double gHeight=100;
  double gSize=50;


  Color color;
  _sideBarBG({@required this.color,this.gSize});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
        ..color = color
            ..style = PaintingStyle.fill;


    Paint shadowPaint = Paint()
        ..color = Colors.black.withAlpha(150)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 9);

    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    //Gnobbel
    path.lineTo(size.width, size.height / 2 - gHeight * 2);
    path.quadraticBezierTo(
        size.width, size.height / 2 - gHeight, size.width + gSize / 2,
        size.height / 2 - gHeight / 2);
    path.quadraticBezierTo(
        size.width + gSize, size.height / 2, size.width + gSize / 2,
        size.height / 2 + gHeight / 2);
    path.quadraticBezierTo(size.width, size.height / 2 + gHeight, size.width,
        size.height / 2 + gHeight * 2);

    path.lineTo(size.width, size.height / 2 + gHeight / 2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    canvas.drawPath(path, shadowPaint);

    canvas.drawPath(path, paint);

    canvas.drawCircle(
        Offset(size.width + (35 - gSize), size.height / 2), (70 - gSize) * 0.45,
        shadowPaint);

    canvas.drawCircle(
        Offset(size.width + (35 - gSize), size.height / 2), (70 - gSize) * 0.45,
        paint);


  }

    @override
    bool shouldRepaint(CustomPainter oldDelegate) {
      return true;
    }
}