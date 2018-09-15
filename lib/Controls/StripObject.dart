/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

class StripObject extends StatefulWidget {
  final double padding;
  final GlobalKey<StripObjectState> key = GlobalKey<StripObjectState>();

  StripObject({this.padding}) : super(key: GlobalKey());

  @override
  State<StatefulWidget> createState() => new StripObjectState(
    key: key
  );
}

class StripObjectState extends State<StripObject> {  
  StripObjectState({Key key});
  Size stripSize;

  static const Color backgroundColor = Colors.white;
  static const Color borderColor = Colors.black;
  static const double borderWidth = 3.0;

  static Border border = Border.all(
    color: borderColor, 
    width: borderWidth
  );

  static BoxDecoration box = BoxDecoration(
    color: backgroundColor,
    border: border,
  );


  @override
  Widget build(BuildContext context) {

    if (stripSize == null)
    {
      var mediaQueryData = MediaQuery.of(context);
      stripSize = Size((mediaQueryData.size.width - (2 * widget.padding)) * 0.8, (mediaQueryData.size.height - (2 * widget.padding)) * 0.25);
    }

    return Positioned(
      left: widget.padding,
      top:  widget.padding,
      child: Container(
        width: stripSize.width,
        height: stripSize.height,
        decoration: box,
      ),
    );
  }
}
