import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomFloatingButtonLocation extends FloatingActionButtonLocation { 
  const CustomFloatingButtonLocation(); 

  @override 
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) { 
    final double endPadding = scaffoldGeometry.minInsets.left; 
    final double fabX = kFloatingActionButtonMargin + endPadding; 

    final double contentBottom = scaffoldGeometry.contentBottom; 
    final double bottomSheetHeight = scaffoldGeometry.bottomSheetSize.height; 
    final double fabHeight = scaffoldGeometry.floatingActionButtonSize.height; 
    final double snackBarHeight = scaffoldGeometry.snackBarSize.height; 

    double fabY = contentBottom - fabHeight - kFloatingActionButtonMargin; 
    if (snackBarHeight > 0.0) 
      fabY = math.min(fabY, contentBottom - snackBarHeight - fabHeight - kFloatingActionButtonMargin); 
    if (bottomSheetHeight > 0.0) 
      fabY = math.min(fabY, contentBottom - bottomSheetHeight - fabHeight / 2.0); 

    return new Offset(fabX, fabY); 
  } 
} 