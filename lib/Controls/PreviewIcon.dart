/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';
import 'PreviewBox.dart';

class PreviewIcon extends StatelessWidget {
  final Size previewSize;
  final String assetPath;
  final String text;
  final String documentsDirectory;
  final bool isEmbedded;

  static const backgroundColor = Colors.white;
  static const showingEditOptions = false;
  static const isPinnedToCurrentLocation = true;
  static const currentOpacity = 1.0;

  PreviewIcon(this.previewSize, this.assetPath, this.text, this.isEmbedded, this.documentsDirectory);

  @override
  Widget build(BuildContext context) {

    return PreviewBox(
      size: previewSize,
      label: text,
      assetPath: assetPath,
      opacity: currentOpacity,
      isPinnedToLocation: isPinnedToCurrentLocation,
      showEditOptions: showingEditOptions,
      isEmbedded: isEmbedded,
      documentsDirectory: documentsDirectory,
      editFunction: () {},
      backgroundColor: backgroundColor);
  }
}