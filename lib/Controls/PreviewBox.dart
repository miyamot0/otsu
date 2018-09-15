/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

class PreviewBox extends StatelessWidget {

  final Offset position = new Offset(0.0, 0.0);
  final Size size;
  final String label;
  final String assetPath;
  final Color backgroundColor;
  final Function editFunction;
  final String documentsDirectory;
  final bool showEditOptions;
  final bool isPinnedToLocation;
  final bool isEmbedded;

  final double opacity;

  PreviewBox({this.size, this.label, this.assetPath, this.opacity: 1.0, this.backgroundColor, this.editFunction, 
            this.showEditOptions, this.isPinnedToLocation, this.isEmbedded, this.documentsDirectory,});

  static const TextStyle defaultStyle = TextStyle(
    color: Colors.black, 
    decoration: TextDecoration.none, 
    fontSize: 20.0);

  static const Align pinnedIcon = Align(child: Icon(Icons.pin_drop,),);
  static const Align deleteIcon = Align(child: Icon(Icons.delete,  ),);
  static const Align growIcon   = Align(child: Icon(Icons.photo_size_select_large,),);
  static const Align shrinkIcon = Align(child: Icon(Icons.photo_size_select_small,),);

  static const childArray = [pinnedIcon, growIcon, shrinkIcon, deleteIcon];

  static Row topRow = Row(
    children: childArray, 
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    verticalDirection: VerticalDirection.up,
  );

  @override
  Widget build(BuildContext context) {
    Image imgAsset;

    if (isEmbedded == true)
    {
      imgAsset = Image.asset(
        assetPath,
        height: size.height * 0.7,
        fit: BoxFit.cover);
    }
    else if (isEmbedded == false)
    {
      imgAsset = Image.asset(
        "$documentsDirectory/$assetPath",
        height: size.height * 0.7,
        fit: BoxFit.cover);
    }

    Column centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                  Flexible(child: showEditOptions ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
                                  Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                                  Flexible(child: Align(alignment: Alignment.center, child: Text(label, style: defaultStyle)), flex: 2)
                                ]
                              );

    return new Container(width: size.width,
                         height: size.height,
                         key: GlobalKey(),
                         decoration: BoxDecoration(border: Border.all(color: Colors.black, width: isPinnedToLocation ? 5.0 : 3.0),
                                                   color: backgroundColor),
                         child: Column(children: [Expanded(child: centerColumn,)]),);
  }
}
