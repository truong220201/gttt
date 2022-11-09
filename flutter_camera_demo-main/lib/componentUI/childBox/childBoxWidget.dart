import 'package:flutter/material.dart';
import '../fonts/fontTypography.dart';
import '../color/getColor.dart';

class childHalfMiniBox extends StatelessWidget {
  @override
  const childHalfMiniBox();

  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      width: double.infinity,
      child: Text('Thông tin',
          style: TextStyle(
            fontSize: MINISIZE,
            color: Color.fromARGB(117, 255, 255, 255),
            fontFamily: 'BasierCircle',
          )),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(width: 2, color: Color.fromARGB(54, 255, 255, 255)),
        boxShadow: [
          BoxShadow(
            color: BLACKCOLOR,
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment(0.8, 1),
          colors: <Color>[
            Color.fromARGB(77, 255, 255, 255),
            Color.fromARGB(0, 255, 255, 255),
          ], // Gradient from https://learnui.design/tools/gradient-generator.html
          tileMode: TileMode.mirror,
        ),
      ),
    ));
  }
}

class childMiniBox extends StatelessWidget {
  childMiniBox(
      {Key? key,
      required this.title,
      required this.temperature,
      required this.minmax})
      : super(key: key);
  final title;
  final temperature;
  final minmax;
  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(children: [
            Text('$title',
                style: TextStyle(
                  fontSize: MINISIZE,
                  color: Color.fromARGB(117, 255, 255, 255),
                  fontFamily: 'BasierCircle',
                )),
            Text('$temperature',
                style: TextStyle(
                  fontSize: NORMALSIZE,
                  color: const Color(0xFFFFFFFF),
                  fontFamily: 'BasierCircle',
                )),
            Text('$minmax',
                style: TextStyle(
                  fontSize: NORMALSIZE,
                  color: const Color(0xFFFFFFFF),
                  fontFamily: 'BasierCircle',
                ))
          ]),
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: 200.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(width: 2, color: Color.fromARGB(54, 255, 255, 255)),
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(5, 255, 255, 255),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: <Color>[
                Color.fromARGB(77, 255, 255, 255),
                Color.fromARGB(0, 255, 255, 255),
              ], // Gradient from https://learnui.design/tools/gradient-generator.html
              tileMode: TileMode.mirror,
            ),
          ),
        ));
  }
}

class childContainerMini extends StatelessWidget {
  const childContainerMini();
  @override
  Widget build(BuildContext context) {
    return Container(
      // A fixed-height child.

      color: const Color(0xffeeee00), // Yellow
      height: 120.0,
      alignment: Alignment.center,
      child: const Text('Fixed Height Content'),
    );
  }
}
