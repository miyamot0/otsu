/* 
    The MIT License

    Copyright September 1, 2018 Shawn Gilroy/Louisiana State University

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import 'package:otsu/resources.dart';

class ReactiveFolderWidget extends StatefulWidget {
  final String label, assetPath;
  final bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  final double scale, defaultWidth;
  final Function moveToTop, launchEditor, openFolderDialog;
  final Offset initialPosition;
  final IconType iconType;
  final int id;

  final GlobalKey<ReactiveFolderWidgetState> key = GlobalKey<ReactiveFolderWidgetState>();

  ReactiveFolderWidget({
    @required this.label, 
    @required this.assetPath,
    @required this.isInPlay,
    @required this.isEmbbedded,
    @required this.isInSingleMode,
    @required this.isStored,
    @required this.isPinnedToLocation,
    @required this.moveToTop,
    @required this.launchEditor,
    @required this.openFolderDialog,
    @required this.iconType,
    @required this.scale,
    @required this.defaultWidth,
    @required this.id,
    @required this.initialPosition}) : super(key: GlobalKey());

  @override
  ReactiveFolderWidgetState createState() => ReactiveFolderWidgetState(
    label: label, 
    assetPath: assetPath,
    isInPlay: isInPlay, 
    isEmbbedded: isEmbbedded,
    isInSingleMode: isInSingleMode,
    isStored: isStored,
    isPinnedToLocation: isPinnedToLocation,
    moveToTop: moveToTop, 
    launchEditor: launchEditor,
    openFolderDialog: openFolderDialog,
    scale: scale,
    defaultWidth: defaultWidth,
    currentPosition: initialPosition,
    key: key);

  static InheritedFolderState of(BuildContext context) => context.inheritFromWidgetOfExactType(InheritedFolderState) as InheritedFolderState;

  // Check of 
  bool intersectsWith(double size, double scale, Offset offset) {
    double xIcon1, xIcon2, xFolder1, xFolder2;
    double yIcon1, yIcon2, yFolder1, yFolder2;

    xIcon1 = offset.dx;
    xIcon2 = offset.dx + (size * scale);

    yIcon1 = offset.dy;
    yIcon2 = offset.dy + (size * scale);

    xFolder1 = key.currentState.currentPosition.dx;
    xFolder2 = key.currentState.currentPosition.dx + (key.currentState.defaultWidth * key.currentState.scale);

    yFolder1 = key.currentState.currentPosition.dy;
    yFolder2 = key.currentState.currentPosition.dy + (key.currentState.defaultWidth * key.currentState.scale);
        
    return ((xFolder2 >= xIcon1 && xFolder1 <= xIcon2) && (yFolder2 >= yIcon1 && yFolder1 <= yIcon2));
  }
}

class ReactiveFolderWidgetState extends State<ReactiveFolderWidget> {
  Function moveToTop;
  Function launchEditor;
  Function openFolderDialog;
  String label, assetPath;
  bool isInPlay, isEmbbedded, isInSingleMode, isStored, isPinnedToLocation;
  Offset currentPosition;
  double defaultWidth = 200.0;
  double scale;

  ReactiveFolderWidgetState({
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
    this.openFolderDialog,
    this.scale,
    this.defaultWidth,
    this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return InheritedFolderState(
      onTap: onTap,
      onPositionChanged: onPositionChanged,
      label: label,
      assetPath: assetPath,
      isInPlay: isInPlay,
      isEmbbedded: isEmbbedded,
      isInSingleMode: isInSingleMode,
      openFolderDialog: fireDialog,
      isStored: isStored,
      currentPosition: currentPosition,
      defaultWidth: defaultWidth,
      isPinnedToLocation: isPinnedToLocation,        
      scale: scale,        
      child: FolderBox(),
      key: GlobalKey(),
    );
  }

  void onTap() {
    setState(() {
      launchEditor(widget);
    });
  }

  void fireDialog() {
    setState(() {
      openFolderDialog(widget);
    });
  }

  void onPositionChanged(Offset position) {
    setState(() {
      currentPosition = position;
      
      moveToTop(widget);
    });
  }
}
