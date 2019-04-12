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

import 'package:otsu/resources.dart';

class IconBox extends StatelessWidget {
  static const defaultStyle = TextStyle(
    color: Colors.black,
    decoration: TextDecoration.none,
    fontWeight: FontWeight.normal,
    fontSize: 20.0,
    inherit: false,
  );

  static const double thinBorderWidth  = 3.0;
  static const double thickBorderWidth = 5.0;

  static Border thinBorder = Border.all(
    color: const Color(0xFF000000),
    width: thinBorderWidth,
  );

  static Border thickBorder = Border.all(
    color: const Color(0xFF000000),
    width: thickBorderWidth,
  );

  final double opacity;
  final AnimationController controller;

  IconBox({this.opacity, this.controller});

  @override
  Widget build(BuildContext context) {
    InheritedIconState inheritedIconState = InheritedIconState.of(context);
    InheritedVisualFieldState inheritedFieldState = InheritedVisualFieldState.of(context);

    Image imgAsset = Image.asset(
      inheritedIconState.isEmbbedded == true ? 
        inheritedIconState.assetPath : 
        "${InheritedAppState.of(context).dir}/${inheritedIconState.assetPath}",
      height: (inheritedIconState.scale * inheritedIconState.defaultWidth) * 0.7,
      fit: BoxFit.cover
    );

    var widgetList = (inheritedFieldState.inDebugMode) ? 
    // In debug
    <Widget>[
      AlignPositioned(
        alignment: Alignment.topRight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: ()
          {
            if (!inheritedFieldState.inDebugMode) return;

            inheritedIconState.onTap();
          },
          child: Icon(
            Icons.edit,
          ),
        ),
        dx: -10,
        dy: 10,
      ),
      AlignPositioned(
        alignment: Alignment.center,
        child: imgAsset,
      ),
      AlignPositioned(
        alignment: Alignment.bottomCenter,
        dy: -10,
        child: Text(
          inheritedIconState.label, 
          style: defaultStyle,
          textAlign: TextAlign.center,
        ),
      ),
    ] : 
    // Normal
    <Widget>[
      AlignPositioned(
        alignment: Alignment.center,
        child: imgAsset,
      ),
      AlignPositioned(
        alignment: Alignment.bottomCenter,
        dy: -10,
        child: Text(
          inheritedIconState.label, 
          style: defaultStyle,
          textAlign: TextAlign.center,
        ),
      ),
    ];

    SizedBox item = SizedBox(
      height: inheritedIconState.scale * inheritedIconState.defaultWidth,
      width: inheritedIconState.scale * inheritedIconState.defaultWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: inheritedIconState.isPinnedToLocation ? thickBorder : thinBorder,
          color: inheritedIconState.isInPlay ? 
            Colors.greenAccent :
            Colors.white,
        ),
        child: Stack(
          children: widgetList,
        ),
      ),
    );

    if (inheritedIconState.isPinnedToLocation == true)
    {
      return new Positioned(
        left: inheritedIconState.currentPosition.dx, 
        key: GlobalKey(),
        top: inheritedIconState.currentPosition.dy,
        child: GestureDetector(
          child: item,
          onTap: () 
          {
            inheritedIconState.onPositionChanged(
              Offset(
                inheritedIconState.currentPosition.dx, 
                inheritedIconState.currentPosition.dy
              )
            );
          }
        )
      );
    }

    Draggable draggable = new Draggable(
      feedback: item,
      maxSimultaneousDrags: controller.isAnimating ? 0 : 1,
      ignoringFeedbackSemantics: false,
      child: Opacity(
        child: item,
        opacity: opacity,
      ),
      childWhenDragging: new Opacity(
        opacity: 0.0, 
        child: item
      ),
      onDragStarted: () {},
      onDraggableCanceled: (velocity, offset) 
      {
        if (offset.distance < 1)
        {
          return;
        }

        var newX = offset.dx;
        var newY = offset.dy;

        newX = (newX < 0.0) ? 0.0 : newX;
        newX = (newX + (inheritedIconState.scale * inheritedIconState.defaultWidth) > inheritedFieldState.boardSize.width) ? 
          inheritedFieldState.boardSize.width - (inheritedIconState.scale * inheritedIconState.defaultWidth) : newX;

        newY = (newY < 0.0) ? 0.0 : newY;
        newY = (newY + (inheritedIconState.scale * inheritedIconState.defaultWidth) > inheritedFieldState.boardSize.height) ? 
          inheritedFieldState.boardSize.height - (inheritedIconState.scale * inheritedIconState.defaultWidth) : newY;        
        
        inheritedIconState.onPositionChanged(Offset(newX, newY));
      }
    );

    return new Positioned(
      left: inheritedIconState.currentPosition.dx,
      key: GlobalKey(),
      top: inheritedIconState.currentPosition.dy,
      child: draggable
    );
  }
}