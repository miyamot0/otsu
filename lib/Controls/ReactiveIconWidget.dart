import 'package:flutter/material.dart';
import '../Models/IconType.dart';

class ReactiveIconWidget extends StatefulWidget {
  final String label, assetPath, documentsFolder;
  final bool isInPlay, isEmbbedded, isInSingleMode, isStored, showEditOptions;
  final double scale, defaultWidth;
  final Function moveToTop;
  final Offset initialPosition;
  final IconType iconType;

  ReactiveIconWidget({@required this.label, 
                      @required this.assetPath,
                      @required this.documentsFolder,
                      @required this.isInPlay,
                      @required this.isEmbbedded,
                      @required this.isInSingleMode,
                      @required this.isStored,
                      @required this.showEditOptions,
                      @required this.moveToTop, 
                      @required this.iconType,
                      @required this.scale,
                      @required this.defaultWidth,
                      @required this.initialPosition}) : super(key: GlobalKey());

  @override
  ReactiveIconWidgetState createState() => ReactiveIconWidgetState(label: label, 
                                                                   assetPath: assetPath,
                                                                   documentsFolder: documentsFolder,
                                                                   isInPlay: isInPlay, 
                                                                   isEmbbedded: isEmbbedded,
                                                                   isInSingleMode: isInSingleMode,
                                                                   isStored: isStored,
                                                                   showEditOptions: showEditOptions,
                                                                   moveToTop: moveToTop, 
                                                                   scale: scale,
                                                                   defaultWidth: defaultWidth,
                                                                   currentPosition: initialPosition);  
}

class ReactiveIconWidgetState extends State<ReactiveIconWidget> {
  Function moveToTop;

  String label, assetPath, documentsFolder;
  bool isInPlay, isEmbbedded, isInSingleMode, isStored, showEditOptions;
  Color color = Colors.white;
  Offset currentPosition;
  double defaultWidth = 200.0;
  double scale;

  ReactiveIconWidgetState({
      this.label, 
      this.assetPath,
      this.documentsFolder,
      this.isInPlay,
      this.isEmbbedded,
      this.isInSingleMode,
      this.isStored,
      this.showEditOptions,
      this.moveToTop, 
      this.scale,
      this.defaultWidth,
      this.currentPosition});

  @override
  Widget build(BuildContext context) {
      return InheritedIconState(
        color: color,
        onTap: onTap,
        onPositionChanged: onPositionChanged,
        label: label,
        assetPath: assetPath,
        documentsFolder: documentsFolder,
        isInPlay: isInPlay,
        isEmbbedded: isEmbbedded,
        isInSingleMode: isInSingleMode,
        isStored: isStored,
        showEditOptions: showEditOptions,
        currentPosition: currentPosition,
        defaultWidth: defaultWidth,
        scale: scale,        
        child: IconTree(),
        key: GlobalKey(),
      );
  }

  void onTap() {
    print('onTap(): ${this.label}');

    setState(() {
      isInPlay = !isInPlay;

      color = (isInPlay == true) ? Colors.greenAccent : Colors.white;
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
    this.color,
    this.onTap,
    this.onPositionChanged,
    this.label,
    this.assetPath,
    this.documentsFolder,
    this.isInPlay,
    this.isEmbbedded,
    this.isInSingleMode,
    this.isStored,
    this.defaultWidth,
    this.showEditOptions,
    this.currentPosition,
    this.startingPosition,
    this.scale,
    Widget child,
  }) : super (key: key, child: child);

  final Offset currentPosition, startingPosition;
  final Color color;
  final Function onTap;
  final Function onPositionChanged;
  final String label;
  final String assetPath;
  final String documentsFolder;
  final double defaultWidth;
  final double scale;
  final bool isPinnedToLocation = false;
  final bool isInPlay;
  final bool showEditOptions;
  final bool isEmbbedded; 
  final bool isInSingleMode;
  final bool isStored;


  @override
  bool updateShouldNotify(InheritedIconState oldWidget) {
    return isInPlay != oldWidget.isInPlay || 
           currentPosition != oldWidget.currentPosition || 
           showEditOptions != oldWidget.showEditOptions;
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

  @override
  Widget build(BuildContext context) {
    final inheritedIconState = InheritedIconState.of(context);
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
                                Flexible(child: inheritedIconState.showEditOptions ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
                                Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                                Flexible(child: Align(alignment: Alignment.center, child: Text(inheritedIconState.label, style: defaultStyle)), flex: 2)
                              ]
                            );

    var item = Container(width: inheritedIconState.scale * inheritedIconState.defaultWidth,
                         height: inheritedIconState.scale * inheritedIconState.defaultWidth,
                         decoration: BoxDecoration(border: Border.all(color: Colors.black, width: inheritedIconState.isPinnedToLocation ? 5.0 : 3.0),
                                                   color: inheritedIconState.color),
                         child: Column(children: [Expanded(child: centerColumn,)]),);

    var avatar = Container(width: inheritedIconState.scale * inheritedIconState.defaultWidth,
                           height: inheritedIconState.scale * inheritedIconState.defaultWidth,
                           decoration: BoxDecoration(border: Border.all(color: Colors.black, width: inheritedIconState.isPinnedToLocation ? 5.0 : 3.0),
                                                     color: inheritedIconState.color),
                           child: Column(children: [Expanded(child: centerColumn,)]),);

    var draggable = new Draggable(
        feedback: avatar,
        maxSimultaneousDrags: 1,//widget.isPinned ? 0 : 1,
        ignoringFeedbackSemantics: false,
        child: item,
        childWhenDragging: new Opacity(opacity: 0.0, child: item),
        onDragStarted: () => print("onDragStarted: ..."),
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

    return new Positioned(
      left: inheritedIconState.currentPosition.dx, 
      key: GlobalKey(),
      top: inheritedIconState.currentPosition.dy, 
      child: draggable);
  }
}
