/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

import '../Controls/FolderBox.dart';
import '../Models/IconType.dart';
import '../InheritedWidgets/InheritedFolderState.dart';

class ReactiveFolderWidget extends StatefulWidget {
  final String label, assetPath;
  final bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  final double scale, defaultWidth;
  final Function moveToTop, launchEditor, openFolderDialog;
  final Offset initialPosition;
  final IconType iconType;
  final int id;

  final GlobalKey<ReactiveFolderWidgetState> key = GlobalKey<ReactiveFolderWidgetState>();

  ReactiveFolderWidget({
    @required this.label, 
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
  ReactiveFolderWidgetState createState() => ReactiveFolderWidgetState(
    label: label, 
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

  // Check of 
  bool intersectsWith(double size, double scale, Offset offset) {
    double xIcon1, xIcon2, xFolder1, xFolder2;
    double yIcon1, yIcon2, yFolder1, yFolder2;

    xIcon1 = offset.dx;
    xIcon2 = offset.dx + (size * scale);

    yIcon1 = offset.dy;
    yIcon2 = offset.dy + (size * scale);

    xFolder1 = key.currentState.currentPosition.dx;
    xFolder2 = key.currentState.currentPosition.dx + (key.currentState.defaultWidth * key.currentState.scale);

    yFolder1 = key.currentState.currentPosition.dy;
    yFolder2 = key.currentState.currentPosition.dy + (key.currentState.defaultWidth * key.currentState.scale);
        
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
      child: FolderBox(),
      key: GlobalKey(),
    );
  }

  void onTap() {
    //print('onTap(): ${this.label}');
    setState(() {
      launchEditor(widget);
    });
  }

  void fireDialog() {
    setState(() {
      openFolderDialog(widget);
    });
  }

  void onPositionChanged(Offset position) {
    //print("onPositionChanged(Offset position): ${this.label}");
    setState(() {
      currentPosition = position;
      
      moveToTop(widget);
    });
  }
}
