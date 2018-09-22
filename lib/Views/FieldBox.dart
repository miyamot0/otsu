import 'package:flutter/material.dart';

import '../InheritedWidgets/InheritedVisualFieldState.dart';

/// Scaffold for visual field
/// 
/// 
class FieldBox extends StatelessWidget {
  static const defaultStyle = const TextStyle(
    color: Colors.black, 
    decoration: TextDecoration.none, 
    fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    final inheritedState = InheritedVisualFieldState.of(context);

    return Scaffold(
      body: Container(
        child: Stack(
          children: inheritedState.stackElements
        ),
        decoration: BoxDecoration(
          color: inheritedState.inDebugMode ? Colors.orangeAccent : Colors.blueAccent
          )
      ),
      floatingActionButton: inheritedState.inDebugMode ? inheritedState.animatedMenu : null,
      primary: false,
      resizeToAvoidBottomPadding: false,
    );  
  }
}