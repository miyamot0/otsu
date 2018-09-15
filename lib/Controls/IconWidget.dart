import 'package:flutter/material.dart';
import 'LabelBox.dart';

import '../Models/IconType.dart';
import '../Models/ModificationType.dart';

final bool outputToTerminal = true;

class IconWidget extends StatefulWidget {
  final Offset initialOffset;
  final String text, assetPath, documentsFolder;
  final Function repositionCallback, deleteCallback, editCallback;
  final bool isEmbbedded, isInSingleMode, isStored;
  final IconType type;

  bool showEditOptions, isPinned, inPlay;

  double scale;
  int id, storedId;

  Offset currentPosition = new Offset(0.0, 0.0);

  Color background = Colors.white;

  _IconWidgetState state;

  IconWidget({this.text, 
              this.initialOffset, 
              this.assetPath,
              this.repositionCallback,
              this.deleteCallback,
              this.showEditOptions,
              this.editCallback,
              this.isPinned,
              this.scale = 1.0,
              this.inPlay,
              this.isEmbbedded,
              this.documentsFolder,
              this.isInSingleMode,
              this.type = IconType.Icon,
              this.isStored = false,
              @required this.id,
              @required this.storedId}) : super(key: GlobalKey());


  @override
  _IconWidgetState createState()
  {
    state = new _IconWidgetState();

    return state;
  }
}

class _IconWidgetState extends State<IconWidget> {
  static double defaultWidth = 200.0;
  double newX, newY;

  Size defaultSize;
  MediaQueryData mediaQueryData;
  LabelBox item; //, avatar;
  Draggable draggable;

  /// Populate call up to Visual Field, to edit
  void triggerIconEditing() {
    debugPrint("triggerEditing()");

    widget.editCallback(widget);
  }

  /// Force a rebuild, especially if elements are not yet built/rendered (state)
  void rebuildChildren() {
    debugPrint("rebuildChildren()");

    item = new LabelBox(size: defaultSize,
                              label: widget.text,
                              assetPath: widget.assetPath,
                              backgroundColor: widget.background,
                              editFunction: this.triggerIconEditing,
                              isPinnedToLocation: widget.isPinned,
                              showEditOptions: widget.showEditOptions,
                              documentsDirectory: widget.documentsFolder,
                              isEmbedded: widget.isEmbbedded,);

    draggable = new Draggable(
      feedback: item,
      maxSimultaneousDrags: widget.isPinned ? 0 : 1,
      key: GlobalKey(),
      child: item,
      childWhenDragging: new Opacity(opacity: 0.0, child: item),
      onDragStarted: () => debugPrint("onDragStarted: ${widget.text}"),
      ignoringFeedbackSemantics: false,
      onDraggableCanceled: (velocity, offset) {
        setState(() { 
          if (velocity.pixelsPerSecond.distance < 1)
          {
            debugPrint("onDraggableCanceled. Velocity low, kill off event");

            widget.repositionCallback(widget);

            return;
          }
          else
          {
            debugPrint("onDraggableCanceled. Velocity: ${velocity.pixelsPerSecond.distance}");
          }

          newX = offset.dx;
          newY = offset.dy;

          newX = (newX < 0.0) ? 0.0 : newX;
          newX = (newX + item.size.width > mediaQueryData.size.width) ? mediaQueryData.size.width - item.size.width : newX;

          newY = (newY < 0.0) ? 0.0 : newY;
          newY = (newY + item.size.height > mediaQueryData.size.height) ? mediaQueryData.size.height - item.size.height : newY;        
          
          widget.currentPosition = new Offset(newX, newY);

          widget.repositionCallback(widget);
        });
      });
  }

  /// Sets an icon to active status, re: background
  void setActive(bool status, {bool force = false}) {
    debugPrint("setActive()");

    if (widget.inPlay == status && force == false) return;

    setState(() 
    {
      widget.inPlay = status;
      widget.background = (widget.inPlay == true) ? Colors.greenAccent : Colors.white;

      item.backgroundColor = widget.background;
    });
  }

  /// Makes the options for editing visible
  void setEditing(bool status) {
    debugPrint("setEditing() ${widget.text}");

    if (widget.showEditOptions != status)
    {
      setState(() 
      {
        widget.showEditOptions = status;

        rebuildChildren();
      });
    }
  }

  /// Callback, modify widget properties
  void modifyWidget(ModifyAction action, {bool silent = false}) {
    if (!widget.showEditOptions) return;

    debugPrint("modifyWidget()");

    setState(()
    {
        switch (action)
        {
          case ModifyAction.Default:
            debugPrint("ModifyAction.Default");            
            widget.scale = 1.0;
            defaultSize = Size.square(defaultWidth * widget.scale);

            if (silent == false)
            {
              widget.repositionCallback(widget);              
            }

            rebuildChildren();

            break;

          case ModifyAction.Grow:
            debugPrint("ModifyAction.Grow");
            widget.scale = widget.scale * 1.05;
            defaultSize = Size.square(defaultWidth * widget.scale);

            if (silent == false)
            {
              widget.repositionCallback(widget);              
            }

            rebuildChildren();

            break;

          case ModifyAction.Shrink:
            debugPrint("ModifyAction.Shrink");
            widget.scale = widget.scale * 0.95;
            defaultSize = Size.square(defaultWidth * widget.scale);

            if (silent == false)
            {
              widget.repositionCallback(widget);              
            }

            rebuildChildren();

            break;

          case ModifyAction.Delete:
            debugPrint("ModifyAction.Delete");
            
            widget.deleteCallback(widget);

            break;

          case ModifyAction.Pin:
            debugPrint("ModifyAction.Pin");
            widget.isPinned = !widget.isPinned;
            
            if (silent == false)
            {
              widget.repositionCallback(widget);              
            }

            rebuildChildren();

            break;

          default:

            break;
        }
    });
  }

  @override
  void initState() {
    widget.currentPosition = widget.initialOffset;
    defaultSize = Size.square(defaultWidth * widget.scale);
    
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    debugPrint("item: ${widget.text} isInPlay: ${widget.inPlay}");

    if (mediaQueryData == null)
    {
      mediaQueryData = MediaQuery.of(context);
    }

    if (item == null)
    {
      item = new LabelBox(size: defaultSize,
                                label: widget.text,
                                assetPath: widget.assetPath,
                                backgroundColor: widget.background,
                                editFunction: this.triggerIconEditing,
                                isPinnedToLocation: widget.isPinned,
                                showEditOptions: widget.showEditOptions,
                                documentsDirectory: widget.documentsFolder,
                                isEmbedded: widget.isEmbbedded,);
    }

    if (draggable == null)
    {
      draggable = new Draggable(
        feedback: item,
        maxSimultaneousDrags: widget.isPinned ? 0 : 1,
        key: GlobalKey(),
        child: item,
        childWhenDragging: new Opacity(opacity: 0.0, child: item),
        onDragStarted: () => debugPrint("onDragStarted: ${widget.text}"),
        ignoringFeedbackSemantics: false,
        onDraggableCanceled: (velocity, offset) {
          setState(() {             
            if (velocity.pixelsPerSecond.distance < 1)
            {
              debugPrint("onDraggableCanceled. Velocity low, kill off event");

              widget.repositionCallback(widget);

              return;
            }
            else
            {
              debugPrint("onDraggableCanceled. Velocity: ${velocity.pixelsPerSecond.distance}");
            }

            newX = offset.dx;
            newY = offset.dy;

            newX = (newX < 0.0) ? 0.0 : newX;
            newX = (newX + item.size.width > mediaQueryData.size.width) ? mediaQueryData.size.width - item.size.width : newX;

            newY = (newY < 0.0) ? 0.0 : newY;
            newY = (newY + item.size.height > mediaQueryData.size.height) ? mediaQueryData.size.height - item.size.height : newY;        
            
            widget.currentPosition = new Offset(newX, newY);

            widget.repositionCallback(widget);
          });
        });
    }

    if (widget.isPinned == true)
    {
      return new Positioned(
        left: widget.currentPosition.dx, 
        key: GlobalKey(),
        top: widget.currentPosition.dy,         
        child: GestureDetector(child: item,
                               onTap: () 
                               {
                                 debugPrint("onTap: Widget pinned");
                                 widget.repositionCallback(widget);
                               }));
    }

    return new Positioned(
      left: widget.currentPosition.dx, 
      key: GlobalKey(),
      top: widget.currentPosition.dy, 
      child: draggable);
  }

  void debugPrint(String toTerminal) {
    if (outputToTerminal == false) return;

    print("Icon Widget: $toTerminal");
  }
}
