import 'package:flutter/material.dart';

class spaceHeight extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(height: 20.0.pxToPercentage(context));
  }
}

class spaceWidth extends StatelessWidget {
  Widget build(BuildContext context) {
    return Container(width: 20.0.pxToPercentage(context));
  }
}

// chia ti le chieu dai theo man hinh
extension DimensEx on double {
  double pxToPercentage(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double percentageWidth = width / 392; // default: 667h x 375w, iPhone 11
    return percentageWidth * this;
  }
}
