// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import '../componentUI/space/spaceWidthHeight.dart';
import '../componentUI/fonts/fontTypography.dart';
import '../componentUI/childBox/childBoxWidget.dart';

// ignore: camel_case_types, must_be_immutable
class newpage extends StatelessWidget {
  final face;
  final gtt;
  var infor;
  newpage({
    required this.face,
    required this.gtt,
    required this.infor,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment(0.8, 1),
            colors: <Color>[
              Color.fromARGB(255, 59, 189, 124),
              Color.fromARGB(255, 69, 136, 78),
              Color.fromARGB(28, 2, 1, 1),
            ],
            tileMode: TileMode.mirror,
          ),
        ),
        // ignore: sort_child_properties_last
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text('Information',
                          style: TextStyle(
                            fontSize: NORMALSIZE,
                            color: const Color(0xFFFFFFFF),
                            fontFamily: 'BasierCircle',
                          )),
                    ),
                    Expanded(
                      child: Text('full name...',
                          style: TextStyle(
                            fontSize: MINISIZE,
                            color: const Color.fromARGB(125, 255, 255, 255),
                            fontFamily: 'BasierCircle',
                          )),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                  padding: const EdgeInsets.all(00),
                  decoration: const BoxDecoration(),
                  child: LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                  // ignore: sort_child_properties_last
                                  child: Column(children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.memory(
                                        face,
                                        height: 150,
                                        width: 150,
                                        // fit: BoxFit
                                        //     .cover
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10.0),
                                      child: Image.memory(
                                        gtt,
                                        height: 150,
                                        width: 150,
                                        // fit: BoxFit
                                        //     .cover
                                      ),
                                    ),
                                    Text('Tên',
                                        style: TextStyle(
                                          fontSize: TITLESIZE,
                                          color: const Color(0xFFFFFFFF),
                                          fontFamily: 'BasierCircle',
                                        )),
                                    Text('$infor',
                                        style: TextStyle(
                                          fontSize: STITLESIZE,
                                          color: const Color(0xFFFFFFFF),
                                          fontFamily: 'BasierCircle',
                                        )),
                                  ]),
                                  height: 300,
                                  decoration: const BoxDecoration()),
                              Row(children: [
                                childMiniBox(
                                  title: 'Thông tin chung',
                                  temperature: 'Họ và Tên',
                                  minmax: 'VV...',
                                )
                              ]),
                              spaceHeight(),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                        width: double.infinity,
                                        margin: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 0),
                                        height: 180.0,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              width: 2,
                                              // ignore: prefer_const_constructors
                                              color: Color.fromARGB(
                                                  54, 255, 255, 255)),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          // ignore: prefer_const_literals_to_create_immutables
                                          boxShadow: [
                                            const BoxShadow(
                                              color: Color.fromARGB(
                                                  5, 255, 255, 255),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(0,
                                                  3), // changes position of shadow
                                            ),
                                          ],
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment(0.8, 1),
                                            colors: <Color>[
                                              Color.fromARGB(77, 255, 255, 255),
                                              Color.fromARGB(0, 255, 255, 255),
                                            ], // Gradient from https://learnui.design/tools/gradient-generator.html
                                            tileMode: TileMode.mirror,
                                          ),
                                        ),
                                        child: Text('Thông tin',
                                            style: TextStyle(
                                              fontSize: MINISIZE,
                                              color: const Color.fromARGB(
                                                  117, 255, 255, 255),
                                              fontFamily: 'BasierCircle',
                                            )),
                                      )),
                                  spaceWidth(),
                                  Expanded(
                                      flex: 1,
                                      child: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 0),
                                          height: 180.0,
                                          child: Column(
                                            children: [
                                              const childHalfMiniBox(),
                                              spaceHeight(),
                                              const childHalfMiniBox()
                                            ],
                                          ))),
                                  spaceHeight(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 0),
      ),
    );
  }
}
