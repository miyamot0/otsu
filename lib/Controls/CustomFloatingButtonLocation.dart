/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';
import 'dart:math' as math;

class CustomFloatingButtonLocation extends FloatingActionButtonLocation {

  const CustomFloatingButtonLocation(); 

  @override 
  Offset getOffset(ScaffoldPrelayoutGeometry geometry) { 
    final double end = geometry.minInsets.left; 
    final double marginLeft = kFloatingActionButtonMargin + end; 

    final double contentBottom = geometry.contentBottom; 
    final double bottomSheetHeight = geometry.bottomSheetSize.height; 
    final double marginTop = geometry.floatingActionButtonSize.height; 
    final double snackBarHeight = geometry.snackBarSize.height; 

    double fabY = contentBottom - marginTop - kFloatingActionButtonMargin; 
    if (snackBarHeight > 0.0)
    {
      fabY = math.min(fabY, contentBottom - snackBarHeight - marginTop - kFloatingActionButtonMargin); 
    }
    if (bottomSheetHeight > 0.0)
    {
      fabY = math.min(fabY, contentBottom - bottomSheetHeight - marginTop / 2.0); 
    }

    return new Offset(marginLeft, fabY); 
  } 
} 