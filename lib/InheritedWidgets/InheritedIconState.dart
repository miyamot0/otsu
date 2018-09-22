import 'package:flutter/material.dart';

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
