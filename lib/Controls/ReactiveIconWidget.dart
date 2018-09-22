/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

import '../Controls/IconBox.dart';
import '../Models/IconType.dart';
import '../InheritedWidgets/InheritedIconState.dart';

class ReactiveIconWidget extends StatefulWidget {
  final String label, assetPath;
  final bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  final double scale, defaultWidth;
  final Function moveToTop, launchEditor;
  final Offset initialPosition;
  final IconType iconType;
  final int id, storedId;

  final GlobalKey<ReactiveIconWidgetState> key = GlobalKey<ReactiveIconWidgetState>();

  ReactiveIconWidget({
    @required this.label, 
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
  ReactiveIconWidgetState createState() => ReactiveIconWidgetState(
    label: label, 
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
    key: key,
  );

  static InheritedIconState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedIconState) as InheritedIconState;
}

class ReactiveIconWidgetState extends State<ReactiveIconWidget> with SingleTickerProviderStateMixin{
  Function moveToTop;
  Function launchEditor;
  String label, assetPath;
  bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  Offset currentPosition;
  double defaultWidth = 200.0;
  double scale;

  AnimationController controller;

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
    this.currentPosition
  });

	@override
	void initState(){
	  super.initState();

	  controller = new AnimationController(
		  duration: const Duration(milliseconds: 500), 
		  vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
	  );

	  controller.addListener(()
    {
		  setState((){});
	  });

	  controller.forward();
	}

	@override
	void dispose(){

	  controller.dispose();
	  super.dispose();
	}

  @override
  Widget build(BuildContext context) {
    IconBox box = IconBox(
      opacity: controller.value,
      controller: controller,
    );

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
      child: box,
      key: GlobalKey(),
    );
  }

  /// Launch editor
  /// 
  /// 
  void onTap() {
    //print('Reactive Icon Widget: onTap(): ${this.label}');

    setState(() {
      launchEditor(widget);
    });
  }

  /// Save and trigger events, since position changed
  /// 
  /// 
  void onPositionChanged(Offset position) {
    //print("Reactive Icon Widget: onPositionChanged(Offset position): ${this.label}");
    setState(() {
      currentPosition = position;
      
      moveToTop(widget);
    });
  }
}
