import 'package:flutter/material.dart';

import '../Models/IconType.dart';
import '../Controls/VisualFieldWidget.dart';

class ReactiveIconWidget extends StatefulWidget {
  final String label, assetPath;
  final bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  final double scale, defaultWidth;
  final Function moveToTop, launchEditor;
  final Offset initialPosition;
  final IconType iconType;
  final int id, storedId;

  final GlobalKey<ReactiveIconWidgetState> key = GlobalKey<ReactiveIconWidgetState>();

  ReactiveIconWidget({@required this.label, 
                      @required this.assetPath,
                      @required this.isInPlay,
                      @required this.isEmbbedded,
                      @required this.isInSingleMode,
                      @required this.isStored,
                      @required this.isPinnedToLocation,
                      @required this.moveToTop,
                      @required this.launchEditor,
                      @required this.iconType,
                      @required this.scale,
                      @required this.defaultWidth,
                      @required this.id,
                      @required this.storedId,
                      @required this.initialPosition}) : super(key: GlobalKey());

  @override
  ReactiveIconWidgetState createState() => ReactiveIconWidgetState(label: label, 
                                                                   assetPath: assetPath,
                                                                   isInPlay: isInPlay, 
                                                                   isEmbbedded: isEmbbedded,
                                                                   isInSingleMode: isInSingleMode,
                                                                   isStored: isStored,
                                                                   isPinnedToLocation: isPinnedToLocation,
                                                                   moveToTop: moveToTop, 
                                                                   launchEditor: launchEditor,
                                                                   scale: scale,
                                                                   defaultWidth: defaultWidth,
                                                                   currentPosition: initialPosition,
                                                                   key: key);

  static InheritedIconState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedIconState) as InheritedIconState;
}

class ReactiveIconWidgetState extends State<ReactiveIconWidget> {
  Function moveToTop;
  Function launchEditor;
  String label, assetPath;
  bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  Offset currentPosition;
  double defaultWidth = 200.0;
  double scale;

  ReactiveIconWidgetState({
      Key key,
      this.label, 
      this.assetPath,
      this.isInPlay,
      this.isEmbbedded,
      this.isInSingleMode,
      this.isStored,
      this.isPinnedToLocation,
      this.moveToTop,
      this.launchEditor,
      this.scale,
      this.defaultWidth,
      this.currentPosition});

  @override
  Widget build(BuildContext context) {
      return InheritedIconState(
        onTap: onTap,
        onPositionChanged: onPositionChanged,
        label: label,
        assetPath: assetPath,
        isInPlay: isInPlay,
        isEmbbedded: isEmbbedded,
        isInSingleMode: isInSingleMode,
        isStored: isStored,
        currentPosition: currentPosition,
        defaultWidth: defaultWidth,
        isPinnedToLocation: isPinnedToLocation,        
        scale: scale,        
        child: IconTree(),
        key: GlobalKey(),
      );
  }

  void onTap() {
    print('onTap(): ${this.label}');

    setState(() {
      launchEditor(widget);

      //isInPlay = !isInPlay;
      // launch editor

      //color = (isInPlay == true) ? Colors.greenAccent : Colors.white;
    });
  }

  void onPositionChanged(Offset position) {
    print("onPositionChanged(Offset position): ${this.label}");
    setState(() {
      currentPosition = position;
      
      moveToTop(widget);
    });
  }
}

class InheritedIconState extends InheritedWidget {
  InheritedIconState({
    Key key,
    this.onTap,
    this.onPositionChanged,
    this.launchEditor,
    this.label,
    this.assetPath,
    this.documentsFolder,
    this.isInPlay,
    this.isEmbbedded,
    this.isInSingleMode,
    this.isStored,
    this.defaultWidth,
    this.showEditOptions,
    this.isPinnedToLocation,
    this.currentPosition,
    this.startingPosition,
    this.scale,
    Widget child,
  }) : super (key: key, child: child);

  final Offset currentPosition, startingPosition;
  final Function onTap;
  final Function onPositionChanged;
  final Function launchEditor;
  final String label;
  final String assetPath;
  final String documentsFolder;
  final double defaultWidth;
  final double scale;
  final bool isPinnedToLocation;
  final bool isInPlay;
  final bool showEditOptions;
  final bool isEmbbedded; 
  final bool isInSingleMode;
  final bool isStored;

  @override
  bool updateShouldNotify(InheritedIconState oldWidget) {
    return isInPlay != oldWidget.isInPlay || 
           currentPosition != oldWidget.currentPosition || 
           showEditOptions != oldWidget.showEditOptions || 
           scale != oldWidget.scale || 
           isPinnedToLocation != oldWidget.isPinnedToLocation;
  }

  static InheritedIconState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedIconState);
  }
}

class IconTree extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconBox();
  }
}

class IconBox extends StatelessWidget {
  final defaultStyle = new TextStyle(color: Colors.black, 
                                     decoration: TextDecoration.none, 
                                     fontSize: 20.0);

  Color getColor(InheritedIconState iconState, InheritedVisualFieldState fieldState, MediaQueryData mediaQuery) {
    if (fieldState.boardSettings.checkIsInSingleMode == true)
    {
      return iconState.isInPlay ? Colors.greenAccent : Colors.white;
    }
    else
    {
      if (iconState.currentPosition.dy <= (mediaQuery.size.height * 0.25) && 
          iconState.currentPosition.dx <= (mediaQuery.size.width  * 0.80)) 
      {
        return Colors.greenAccent;
      }
      else 
      {
        return Colors.white;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inheritedIconState = InheritedIconState.of(context);
    final inheritedFieldState = InheritedVisualFieldState.of(context);
    final mediaQueryData = MediaQuery.of(context);

    

    // docs directory is here 

    final screenInformation = MediaQuery.of(context);

    var settingsIcon =  GestureDetector(behavior: HitTestBehavior.opaque,
                                          onTap: () => inheritedIconState.onTap(),
                                          child: Align(child: Icon(Icons.edit,),
                                                      alignment: Alignment.centerRight,),);

    var topRow = Row(children: [settingsIcon], 
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              verticalDirection: VerticalDirection.up,);

    var imgAsset = Image.asset(inheritedIconState.assetPath,
                               height: (inheritedIconState.scale * inheritedIconState.defaultWidth) * 0.7,
                               fit: BoxFit.cover);

    var centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(child: inheritedFieldState.inDebugMode ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
                                Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                                Flexible(child: Align(alignment: Alignment.center, child: Text(inheritedIconState.label, style: defaultStyle)), flex: 2)
                              ]
                            );

    var item = Container(width: inheritedIconState.scale * inheritedIconState.defaultWidth,
                         height: inheritedIconState.scale * inheritedIconState.defaultWidth,
                         decoration: BoxDecoration(border: Border.all(color: Colors.black, width: inheritedIconState.isPinnedToLocation ? 5.0 : 3.0),
                                                   color: getColor(inheritedIconState, inheritedFieldState, mediaQueryData)),
                         child: Column(children: [Expanded(child: centerColumn,)]),);

    var avatar = Container(width: inheritedIconState.scale * inheritedIconState.defaultWidth,
                           height: inheritedIconState.scale * inheritedIconState.defaultWidth,
                           decoration: BoxDecoration(border: Border.all(color: Colors.black, width: inheritedIconState.isPinnedToLocation ? 5.0 : 3.0),
                                                     color: inheritedIconState.isInSingleMode ? Colors.greenAccent : Colors.white),
                           child: Column(children: [Expanded(child: centerColumn,)]),);

    var draggable = new Draggable(
        feedback: avatar,
        maxSimultaneousDrags: 1,
        ignoringFeedbackSemantics: false,
        child: item,
        childWhenDragging: new Opacity(opacity: 0.0, child: item),
        onDragStarted: () {
        },
        onDraggableCanceled: (velocity, offset) {
          if (offset.distance < 1)
          {
            print("onDraggableCanceled. Distance low, kill off event");

            return;
          }

          var newX = offset.dx;
          var newY = offset.dy;

          newX = (newX < 0.0) ? 0.0 : newX;
          newX = (newX + (inheritedIconState.scale * inheritedIconState.defaultWidth) > screenInformation.size.width) ? 
            screenInformation.size.width - (inheritedIconState.scale * inheritedIconState.defaultWidth) : newX;

          newY = (newY < 0.0) ? 0.0 : newY;
          newY = (newY + (inheritedIconState.scale * inheritedIconState.defaultWidth) > screenInformation.size.height) ? 
            screenInformation.size.height - (inheritedIconState.scale * inheritedIconState.defaultWidth) : newY;        
          
          inheritedIconState.onPositionChanged(Offset(newX, newY));
        });

    if (inheritedIconState.isPinnedToLocation == true)
    {
      return new Positioned(
        left: inheritedIconState.currentPosition.dx, 
        key: GlobalKey(),
        top: inheritedIconState.currentPosition.dy,         
        child: GestureDetector(child: item,
                               onTap: () 
                               {
                                 debugPrint("onTap: Widget pinned");
                                 inheritedIconState.onPositionChanged(Offset(inheritedIconState.currentPosition.dx, inheritedIconState.currentPosition.dy));
                               }));
    }

    return new Positioned(
      left: inheritedIconState.currentPosition.dx, 
      key: GlobalKey(),
      top: inheritedIconState.currentPosition.dy, 
      child: draggable);
  }
}
