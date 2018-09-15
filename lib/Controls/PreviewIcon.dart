import 'package:flutter/material.dart';
import 'PreviewBox.dart';

class PreviewIcon extends StatelessWidget {
  final Size previewSize;
  final String assetPath;
  final String text;
  final String documentsDirectory;
  final bool isEmbedded;

  PreviewIcon(this.previewSize, this.assetPath, this.text, this.isEmbedded, this.documentsDirectory);

  @override
  Widget build(BuildContext context) {

    return PreviewBox(
        size: previewSize,
        label: text,
        assetPath: assetPath,
        opacity: 1.0,
        isPinnedToLocation: true,
        showEditOptions: false,
        isEmbedded: isEmbedded,
        documentsDirectory: documentsDirectory,
        editFunction: () {},
        backgroundColor: Colors.white);    
  }
}