/* 
    The MIT License

    Copyright September 1, 2018 Shawn Gilroy/Louisiana State University

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

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
