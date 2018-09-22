import 'package:flutter/material.dart';

import '../Controls/AnimatedMenu.dart';
import '../Storage/IconDatabase.dart';

/// Inherited members for icons/folders lower in tree
/// 
/// 
class InheritedVisualFieldState extends InheritedWidget {
  InheritedVisualFieldState({
    Key key,
    @required this.documentsDirectory,
    @required this.background,
    @required this.inDebugMode,
    @required this.stackElements,
    @required this.animatedMenu,
    @required this.boardSize,
    @required this.boardSettings,
    Widget child,
  }) : super (key: key, child: child);

  final String documentsDirectory;
  final Color background;
  final bool inDebugMode;
  final List<Widget> stackElements;
  final AnimatedMenuWidget animatedMenu;
  final Size boardSize;
  final BoardSettings boardSettings;

  @override
  bool updateShouldNotify(InheritedVisualFieldState oldWidget) {
    return inDebugMode != oldWidget.inDebugMode ||
      boardSettings.checkIsInSingleMode != oldWidget.boardSettings.checkIsInSingleMode ||
      boardSettings.checkIsAutoDeselecting != oldWidget.boardSettings.checkIsAutoDeselecting ||
      boardSettings.checkIsAutoSpeaking != oldWidget.boardSettings.checkIsAutoSpeaking;
  }

  static InheritedVisualFieldState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedVisualFieldState);
  }
}
