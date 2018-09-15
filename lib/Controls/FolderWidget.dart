import 'package:flutter/material.dart';
import 'LabelBox.dart';

import '../Models/IconType.dart';
import '../Models/ModificationType.dart';

final bool outputToTerminal = true;

class FolderWidget extends StatefulWidget {
  final Offset initialOffset;
  final String text, assetPath, documentsFolder;
  final Function repositionCallback, deleteCallback, openDialogCallback, editCallback;
  final bool isEmbbedded, isInSingleMode;
  final IconType type;

  bool showEditOptions, isPinned, inPlay;

  double scale;
  int id;

  Offset currentPosition = new Offset(0.0, 0.0);

  Color background = Colors.white;

  _FolderWidgetState state;

  FolderWidget({this.text, 
              this.initialOffset, 
              this.assetPath,
              this.repositionCallback,
              this.deleteCallback,
              this.openDialogCallback,
              this.showEditOptions,
              this.editCallback,
              this.isPinned,
              this.scale = 1.0,
              this.inPlay,
              this.isEmbbedded,
              this.documentsFolder,
              this.isInSingleMode,
              this.type = IconType.Folder,
              @required this.id}) : super(key: GlobalKey());

    double xIcon1, xIcon2, xFolder1, xFolder2;
    double yIcon1, yIcon2, yFolder1, yFolder2;

  // Check of 
  bool intersectsWith(Size size, Offset offset) {
    xIcon1 = offset.dx;
    xIcon2 = offset.dx + size.width;

    yIcon1 = offset.dy;
    yIcon2 = offset.dy + size.height;

    xFolder1 = currentPosition.dx;
    xFolder2 = currentPosition.dx + state.defaultSize.width;

    yFolder1 = currentPosition.dy;
    yFolder2 = currentPosition.dy + state.defaultSize.height;
        
    return ((xFolder2 >= xIcon1 && xFolder1 <= xIcon2) && (yFolder2 >= yIcon1 && yFolder1 <= yIcon2));
  }

  @override
  _FolderWidgetState createState()
  {
    state = new _FolderWidgetState();

    return state;
  }
}

class _FolderWidgetState extends State<FolderWidget> {
  static double defaultWidth = 200.0;
  double newX, newY;

  Size defaultSize;
  MediaQueryData mediaQueryData;
  LabelBox item, avatar;
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

    avatar = new LabelBox(size: defaultSize,
                                label: widget.text,
                                opacity: 0.2,
                                assetPath: widget.assetPath,
                                backgroundColor: widget.background,
                                editFunction: this.triggerIconEditing,
                                isPinnedToLocation: widget.isPinned,
                                showEditOptions: widget.showEditOptions,
                                documentsDirectory: widget.documentsFolder,
                                isEmbedded: widget.isEmbbedded,);

    draggable = new Draggable(
      feedback: avatar,
      maxSimultaneousDrags: widget.isPinned ? 0 : 1,
      key: GlobalKey(),
      child: item,
      childWhenDragging: new Opacity(opacity: 0.0, child: item),
      onDraggableCanceled: (velocity, offset) {
        setState(() { 
          debugPrint("onDraggableCanceled: ");

          newX = offset.dx;
          newY = offset.dy;

          newX = (newX < 0.0) ? 0.0 : newX;
          newX = (newX + item.size.width > mediaQueryData.size.width) ? mediaQueryData.size.width - item.size.width : newX;

          newY = (newY < 0.0) ? 0.0 : newY;
          newY = (newY + item.size.height > mediaQueryData.size.height) ? mediaQueryData.size.height - item.size.height : newY;        
          
          widget.currentPosition = new Offset(newX, newY);

          //widget.currentPosition = position;
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

      if (avatar != null)
      {
        avatar.backgroundColor = widget.background;
      }
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

    debugPrint("item: ${widget.text} isInPlay: ${widget.inPlay} isInEdit: ${widget.showEditOptions}");

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

    if (avatar == null)
    {
      avatar = new LabelBox(size: defaultSize,
                                  label: widget.text,
                                  opacity: 0.2,
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
        feedback: avatar,
        maxSimultaneousDrags: widget.isPinned ? 0 : 1,
        key: GlobalKey(),
        child: item,
        childWhenDragging: new Opacity(opacity: 0.0, child: item),
        onDraggableCanceled: (velocity, offset) {
          setState(() { 
            debugPrint("onDraggableCanceled: ");

            newX = offset.dx;
            newY = offset.dy;

            newX = (newX < 0.0) ? 0.0 : newX;
            newX = (newX + item.size.width > mediaQueryData.size.width) ? mediaQueryData.size.width - item.size.width : newX;

            newY = (newY < 0.0) ? 0.0 : newY;
            newY = (newY + item.size.height > mediaQueryData.size.height) ? mediaQueryData.size.height - item.size.height : newY;        
            
            widget.currentPosition = new Offset(newX, newY);

            //widget.currentPosition = position;
            widget.repositionCallback(widget);
          });
        });
    }

    if (widget.showEditOptions == false)
    {
      return new Positioned(
        left: widget.currentPosition.dx, 
        key: GlobalKey(),
        top: widget.currentPosition.dy,         
        child: GestureDetector(child: item,
                               onTap: () 
                               {
                                 //debugPrint("onTap: Folder Pressed (TODO: Open dialog)");
                                 //widget.repositionCallback(widget);
                                 widget.openDialogCallback(widget);
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

    print("Folder Widget: $toTerminal");
  }
}
