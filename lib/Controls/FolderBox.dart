import 'package:flutter/material.dart';

import '../InheritedWidgets/InheritedFolderState.dart';
import '../InheritedWidgets/InheritedVisualFieldState.dart';

class FolderBox extends StatelessWidget {
  static const defaultStyle = TextStyle(
    color: Colors.black, 
    decoration: TextDecoration.none, 
    fontWeight: FontWeight.normal,
    fontSize: 20.0,
    inherit: false,
  );

  static const Align editMarker = Align(
    child: Icon(
      Icons.edit,
      ),
    alignment: Alignment.centerRight,
  );

  static const double thinBorderWidth  = 3.0;
  static const double thickBorderWidth = 5.0;

  static Border thinBorder = Border.all(
    color: Colors.black, 
    width: thinBorderWidth,
  );

  static Border thickBorder = Border.all(
    color: Colors.black, 
    width: thickBorderWidth,
  );

  @override
  Widget build(BuildContext context) {
    final InheritedFolderState inheritedFolderState = InheritedFolderState.of(context);
    final InheritedVisualFieldState inheritedFieldState = InheritedVisualFieldState.of(context);

    GestureDetector settingsIcon =  GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => inheritedFolderState.onTap(),
      child: editMarker,
    );

    Row topRow = Row(
      children: [settingsIcon],
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      verticalDirection: VerticalDirection.up,
    );

    Image imgAsset = Image.asset(
      inheritedFolderState.assetPath,
      height: (inheritedFolderState.scale * inheritedFolderState.defaultWidth) * 0.7,
      fit: BoxFit.cover,
    );

    Column centerColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: inheritedFieldState.inDebugMode ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
        Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
        Flexible(child: Align(alignment: Alignment.center, child: Text(inheritedFolderState.label, style: defaultStyle)), flex: 2)
      ]
    );

    ConstrainedBox item = ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight:  inheritedFolderState.scale * inheritedFolderState.defaultWidth,
        minWidth:   inheritedFolderState.scale * inheritedFolderState.defaultWidth,
        maxHeight:  inheritedFolderState.scale * inheritedFolderState.defaultWidth,
        maxWidth:   inheritedFolderState.scale * inheritedFolderState.defaultWidth,
      ),      
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: inheritedFolderState.isPinnedToLocation ? thickBorder : thinBorder,
          color: inheritedFolderState.isInPlay ? 
            Colors.greenAccent : 
            Colors.white
        ),
        child: Padding(
          child: centerColumn, 
          padding: EdgeInsets.all(5.0),
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
          //print("onDraggableCanceled. Distance low, kill off event");

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
          onTap: () 
          {
            //print("onTap: Folder Pressed (TODO: Open dialog)");
            inheritedFolderState.openFolderDialog();
            //inheritedFolderState.onPositionChanged(Offset(inheritedFolderState.currentPosition.dx, inheritedFolderState.currentPosition.dy));
          }),
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