/// Shawn Gilroy - 2018, MIT - Licensed
///
///

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
           isPinnedToLocation != oldWidget.isPinnedToLocation ||
           label != oldWidget.label;
  }

  static InheritedIconState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedIconState);
  }
}

class IconBox extends StatelessWidget {
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

  final double opacity;
  final AnimationController controller;

  IconBox({this.opacity, this.controller});

  @override
  Widget build(BuildContext context) {
    InheritedIconState inheritedIconState = InheritedIconState.of(context);
    InheritedVisualFieldState inheritedFieldState = InheritedVisualFieldState.of(context);

    GestureDetector settingsIcon =  GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: ()
      {
        if (!inheritedFieldState.inDebugMode) return;

        inheritedIconState.onTap();
      },
      child: editMarker,
    );

    Row topRow = Row(
      children: [settingsIcon],
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.end,
      verticalDirection: VerticalDirection.up,
    );

    Image imgAsset = Image.asset(
      inheritedIconState.assetPath,
      height: (inheritedIconState.scale * inheritedIconState.defaultWidth) * 0.7,
      fit: BoxFit.cover
    );

    Column centerColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: inheritedFieldState.inDebugMode ? 
          topRow : 
          Opacity(
            child: topRow, 
            opacity: 0.0,
          ), 
          flex: 1,
        ),
        Flexible(
          child: Align(
            alignment: Alignment.center, 
            child: imgAsset,
          ), 
          flex: 6,
        ),
        Flexible(
          child: Align(
            alignment: Alignment.center, 
            child: Text(
              inheritedIconState.label, 
              style: defaultStyle,
            ),
          ), 
          flex: 2
        ),
      ]
    );

    ConstrainedBox item = ConstrainedBox(
      constraints: new BoxConstraints(
        minHeight:  inheritedIconState.scale * inheritedIconState.defaultWidth,
        minWidth:   inheritedIconState.scale * inheritedIconState.defaultWidth,
        maxHeight:  inheritedIconState.scale * inheritedIconState.defaultWidth,
        maxWidth:   inheritedIconState.scale * inheritedIconState.defaultWidth,
      ),      
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: inheritedIconState.isPinnedToLocation ? thickBorder : thinBorder,      
          color: inheritedIconState.isInPlay ? 
            Colors.greenAccent : 
            Colors.white
        ),
        child: Padding(child: centerColumn, padding: EdgeInsets.all(5.0),),
      )
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
            //print("Reactive Icon Widget: onTap: Widget pinned");
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
          //print("Reactive Icon Widget: onDraggableCanceled. Distance low, kill off event");

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
      child: draggable);
  }
}
