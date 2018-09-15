/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

// TODO: change to stateless

class StripObject extends StatefulWidget {
  final double padding;
  Size stripSize;

  StripObject({this.padding});

  @override
  State<StatefulWidget> createState() => new StripObjectState();
}

class StripObjectState extends State<StripObject> {
  

  @override
  Widget build(BuildContext context) {

    if (widget.stripSize == null)
    {
      var mediaQueryData = MediaQuery.of(context);

      widget.stripSize = Size((mediaQueryData.size.width - (2 * widget.padding)) * 0.8, (mediaQueryData.size.height - (2 * widget.padding)) * 0.25);
    }

    return Positioned(
            left: widget.padding,
            top:  widget.padding,
            child: Container(width: widget.stripSize.width,
                             height: widget.stripSize.height,
                             decoration: BoxDecoration(color: Colors.white,
                                                       border: Border.all(color: Colors.black, 
                                                                          width: 3.0),),
                            ),
                        );
  }
}
