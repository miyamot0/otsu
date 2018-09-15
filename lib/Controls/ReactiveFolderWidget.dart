import 'package:flutter/material.dart';

import '../Models/IconType.dart';
import '../Controls/VisualFieldWidget.dart';

class ReactiveFolderWidget extends StatefulWidget {
  final String label, assetPath;
  final bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  final double scale, defaultWidth;
  final Function moveToTop, launchEditor, openFolderDialog;
  final Offset initialPosition;
  final IconType iconType;
  final int id;

  final GlobalKey<ReactiveFolderWidgetState> key = GlobalKey<ReactiveFolderWidgetState>();

  ReactiveFolderWidget({@required this.label, 
                      @required this.assetPath,
                      @required this.isInPlay,
                      @required this.isEmbbedded,
                      @required this.isInSingleMode,
                      @required this.isStored,
                      @required this.isPinnedToLocation,
                      @required this.moveToTop,
                      @required this.launchEditor,
                      @required this.openFolderDialog,
                      @required this.iconType,
                      @required this.scale,
                      @required this.defaultWidth,
                      @required this.id,
                      @required this.initialPosition}) : super(key: GlobalKey());

  @override
  ReactiveFolderWidgetState createState() => ReactiveFolderWidgetState(label: label, 
                                                                   assetPath: assetPath,
                                                                   isInPlay: isInPlay, 
                                                                   isEmbbedded: isEmbbedded,
                                                                   isInSingleMode: isInSingleMode,
                                                                   isStored: isStored,
                                                                   isPinnedToLocation: isPinnedToLocation,
                                                                   moveToTop: moveToTop, 
                                                                   launchEditor: launchEditor,
                                                                   openFolderDialog: openFolderDialog,
                                                                   scale: scale,
                                                                   defaultWidth: defaultWidth,
                                                                   currentPosition: initialPosition,
                                                                   key: key);

  static InheritedFolderState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedFolderState) as InheritedFolderState;

  double xIcon1, xIcon2, xFolder1, xFolder2;
  double yIcon1, yIcon2, yFolder1, yFolder2;

  // Check of 
  bool intersectsWith(double size, Offset offset) {
    xIcon1 = offset.dx;
    xIcon2 = offset.dx + size;

    yIcon1 = offset.dy;
    yIcon2 = offset.dy + size;

    xFolder1 = key.currentState.currentPosition.dx;
    xFolder2 = key.currentState.currentPosition.dx + key.currentState.defaultWidth;

    yFolder1 = key.currentState.currentPosition.dy;
    yFolder2 = key.currentState.currentPosition.dy + key.currentState.defaultWidth;
        
    return ((xFolder2 >= xIcon1 && xFolder1 <= xIcon2) && (yFolder2 >= yIcon1 && yFolder1 <= yIcon2));
  }
}

class ReactiveFolderWidgetState extends State<ReactiveFolderWidget> {
  Function moveToTop;
  Function launchEditor;
  Function openFolderDialog;
  String label, assetPath;
  bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  Offset currentPosition;
  double defaultWidth = 200.0;
  double scale;

  ReactiveFolderWidgetState({
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
      this.openFolderDialog,
      this.scale,
      this.defaultWidth,
      this.currentPosition});

  @override
  Widget build(BuildContext context) {
      return InheritedFolderState(
        onTap: onTap,
        onPositionChanged: onPositionChanged,
        label: label,
        assetPath: assetPath,
        isInPlay: isInPlay,
        isEmbbedded: isEmbbedded,
        isInSingleMode: isInSingleMode,
        openFolderDialog: fireDialog,
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

  void fireDialog() {
    print("fireDialog()");

    setState(() {
      openFolderDialog(widget);
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

class InheritedFolderState extends InheritedWidget {
  InheritedFolderState({
    Key key,
    this.onTap,
    this.onPositionChanged,
    this.launchEditor,
    this.openFolderDialog,
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
  final Function openFolderDialog;
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
  bool updateShouldNotify(InheritedFolderState oldWidget) {
    return isInPlay != oldWidget.isInPlay || 
           currentPosition != oldWidget.currentPosition || 
           showEditOptions != oldWidget.showEditOptions || 
           scale != oldWidget.scale || 
           isPinnedToLocation != oldWidget.isPinnedToLocation;
  }

  static InheritedFolderState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedFolderState);
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

  @override
  Widget build(BuildContext context) {
    final inheritedFolderState = InheritedFolderState.of(context);
    final inheritedFieldState = InheritedVisualFieldState.of(context);

    // docs directory is here 

    final screenInformation = MediaQuery.of(context);

    var settingsIcon =  GestureDetector(behavior: HitTestBehavior.opaque,
                                          onTap: () => inheritedFolderState.onTap(),
                                          child: Align(child: Icon(Icons.edit,),
                                                      alignment: Alignment.centerRight,),);

    var topRow = Row(children: [settingsIcon], 
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              verticalDirection: VerticalDirection.up,);

    var imgAsset = Image.asset(inheritedFolderState.assetPath,
                               height: (inheritedFolderState.scale * inheritedFolderState.defaultWidth) * 0.7,
                               fit: BoxFit.cover);

    var centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(child: inheritedFieldState.inDebugMode ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
                                Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                                Flexible(child: Align(alignment: Alignment.center, child: Text(inheritedFolderState.label, style: defaultStyle)), flex: 2)
                              ]
                            );

    var item = Container(width: inheritedFolderState.scale * inheritedFolderState.defaultWidth,
                         height: inheritedFolderState.scale * inheritedFolderState.defaultWidth,
                         decoration: BoxDecoration(border: Border.all(color: Colors.black, width: inheritedFolderState.isPinnedToLocation ? 5.0 : 3.0),
                                                   color: inheritedFolderState.isInPlay ? Colors.greenAccent : Colors.white),
                         child: Column(children: [Expanded(child: centerColumn,)]),);

    var avatar = Container(width: inheritedFolderState.scale * inheritedFolderState.defaultWidth,
                           height: inheritedFolderState.scale * inheritedFolderState.defaultWidth,
                           decoration: BoxDecoration(border: Border.all(color: Colors.black, width: inheritedFolderState.isPinnedToLocation ? 5.0 : 3.0),
                                                     color: inheritedFolderState.isInSingleMode ? Colors.greenAccent : Colors.white),
                           child: Column(children: [Expanded(child: centerColumn,)]),);

    var draggable = new Draggable(
        feedback: avatar,
        maxSimultaneousDrags: inheritedFolderState.isPinnedToLocation ? 0 : 1,
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
          newX = (newX + (inheritedFolderState.scale * inheritedFolderState.defaultWidth) > screenInformation.size.width) ? 
            screenInformation.size.width - (inheritedFolderState.scale * inheritedFolderState.defaultWidth) : newX;

          newY = (newY < 0.0) ? 0.0 : newY;
          newY = (newY + (inheritedFolderState.scale * inheritedFolderState.defaultWidth) > screenInformation.size.height) ? 
            screenInformation.size.height - (inheritedFolderState.scale * inheritedFolderState.defaultWidth) : newY;        
          
          inheritedFolderState.onPositionChanged(Offset(newX, newY));
        });

    if (inheritedFieldState.inDebugMode == false)
    {
      return new Positioned(
        left: inheritedFolderState.currentPosition.dx, 
        key: GlobalKey(),
        top: inheritedFolderState.currentPosition.dy,         
        child: GestureDetector(child: item,
                               onTap: () 
                               {
                                 print("onTap: Folder Pressed (TODO: Open dialog)");
                                 inheritedFolderState.openFolderDialog();
                                 //inheritedFolderState.onPositionChanged(Offset(inheritedFolderState.currentPosition.dx, inheritedFolderState.currentPosition.dy));
                               }));
    }

    return new Positioned(
      left: inheritedFolderState.currentPosition.dx, 
      key: GlobalKey(),
      top: inheritedFolderState.currentPosition.dy, 
      child: draggable);
  }
}