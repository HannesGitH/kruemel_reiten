import 'package:flutter/material.dart';

class sideBar extends StatefulWidget{
  AnimationController _c;
  double width;
  double height=200;

  bool isOut=false;

  sideBar({@required this.height,this.width=200});

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
    return Transform.translate(
      offset: Offset(xOff, 0),
      child: Container(
        width: widget.width+50,
        height: widget.height,
        child: Stack(
          alignment: AlignmentDirectional.centerEnd,
          children: <Widget>[
            Transform.translate(
              offset: Offset(-50, 0),
              child: Container(
                width: widget.width,
                height: widget.height,
                child: GestureDetector(
                  onTap: (){
                    print("tapped");
                    widget.toggle();
                  },
                  child: CustomPaint( //TODO maybe mak the gnubbel not scrollable
                    painter: _sideBarBG(
                      color: Theme.of(context).backgroundColor,
                    ),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(-5, 0),
                child: IconButton(
                    icon: Icon(widget.isOut?Icons.chevron_left:Icons.chevron_right,color: Colors.purple,),
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
  Color color;
  _sideBarBG({@required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    //gnubbelParameter
    double gHeight=100;
    double gSize=50;


    var paint = Paint();
    paint.color = color;
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    //Gnobbel
    path.lineTo(size.width, size.height/2-gHeight*2);
    path.quadraticBezierTo(size.width, size.height/2-gHeight, size.width+gSize/2, size.height/2-gHeight/2);
    path.quadraticBezierTo(size.width+gSize, size.height/2,size.width+gSize/2, size.height/2+gHeight/2);
    path.quadraticBezierTo(size.width, size.height/2+gHeight,size.width, size.height/2+gHeight*2);

    path.lineTo(size.width, size.height/2+gHeight/2);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    Path path2 = path.shift(Offset(2,-2));
    canvas.drawShadow(path2, Colors.black, 2, false);
    canvas.drawShadow(path2, Colors.black, 5, false);
    canvas.drawShadow(path2, Colors.black, 8, false);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}