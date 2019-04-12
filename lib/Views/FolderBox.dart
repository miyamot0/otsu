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

class FolderBox extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final InheritedFolderState inheritedFolderState = InheritedFolderState.of(context);
    final InheritedVisualFieldState inheritedFieldState = InheritedVisualFieldState.of(context);

    Image imgAsset = Image.asset(
      inheritedFolderState.assetPath,
      height: (inheritedFolderState.scale * inheritedFolderState.defaultWidth) * 0.7,
      fit: BoxFit.cover,
    );

    var widgetList = (inheritedFieldState.inDebugMode) ? 
    // In debug
    <Widget>[
      AlignPositioned(
        alignment: Alignment.topRight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => inheritedFolderState.onTap(),
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
          inheritedFolderState.label, 
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
          inheritedFolderState.label, 
          style: defaultStyle,
          textAlign: TextAlign.center,
        ),
      ),
    ];

    SizedBox item = SizedBox(
      height: inheritedFolderState.scale * inheritedFolderState.defaultWidth,
      width: inheritedFolderState.scale * inheritedFolderState.defaultWidth,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: inheritedFolderState.isPinnedToLocation ? thickBorder : thinBorder,
          color: inheritedFolderState.isInPlay ?
            Colors.greenAccent : 
            Colors.white
        ),
        child: Stack(
          children: widgetList,
        ),
      ),
    );

    Draggable draggable = new Draggable(
      maxSimultaneousDrags: inheritedFolderState.isPinnedToLocation ? 0 : 1,
      child: item,
      childWhenDragging: new Opacity(opacity: 0.0, child: item),
      onDragStarted: () {},
      feedback: item,
      ignoringFeedbackSemantics: false,
      onDraggableCanceled: (velocity, offset)
      {
        if (offset.distance < 1)
        {
          return;
        }

        double newX = offset.dx;
        double newY = offset.dy;

        newX = (newX < 0.0) ? 0.0 : newX;
        newX = (newX + (inheritedFolderState.scale * inheritedFolderState.defaultWidth) > inheritedFieldState.boardSize.width) ? 
          inheritedFieldState.boardSize.width - (inheritedFolderState.scale * inheritedFolderState.defaultWidth) : newX;

        newY = (newY < 0.0) ? 0.0 : newY;
        newY = (newY + (inheritedFolderState.scale * inheritedFolderState.defaultWidth) > inheritedFieldState.boardSize.height) ? 
          inheritedFieldState.boardSize.height - (inheritedFolderState.scale * inheritedFolderState.defaultWidth) : newY;        
        
        inheritedFolderState.onPositionChanged(Offset(newX, newY));
      });

    if (inheritedFieldState.inDebugMode == false)
    {
      return new Positioned(
        left: inheritedFolderState.currentPosition.dx, 
        key: GlobalKey(),
        top: inheritedFolderState.currentPosition.dy,         
        child: GestureDetector(
          child: item,
          onTap: () => inheritedFolderState.openFolderDialog(),
        ),
      );
    }

    return new Positioned(
      left: inheritedFolderState.currentPosition.dx, 
      key: GlobalKey(),
      top: inheritedFolderState.currentPosition.dy, 
      child: draggable,
    );
  }
}