import 'package:flutter/material.dart';
import '../Models/ModificationType.dart';

class PreviewBox extends StatefulWidget {

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

  @override
  State<StatefulWidget> createState() => new PreviewBoxState();
}

class PreviewBoxState extends State<PreviewBox> {
  final defaultStyle = new TextStyle(color: Colors.black, 
                                     decoration: TextDecoration.none, 
                                     fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    var pinnedIcon =   GestureDetector(behavior: HitTestBehavior.opaque,
                                       onTap: () => widget.editFunction(ModifyAction.Pin),
                                       child: Align(child: Icon(Icons.pin_drop,),),);

    var deleteIcon =   GestureDetector(behavior: HitTestBehavior.opaque,
                                       onTap: () => widget.editFunction(ModifyAction.Delete),
                                       child: Align(child: Icon(Icons.delete,),),);

    var growIcon =     GestureDetector(behavior: HitTestBehavior.opaque,
                                       onTap: () => widget.editFunction(ModifyAction.Grow),
                                       child: Align(child: Icon(Icons.photo_size_select_large,),),);

    var shrinkIcon =   GestureDetector(behavior: HitTestBehavior.opaque,
                                       onTap: () => widget.editFunction(ModifyAction.Shrink),
                                       child: Align(child: Icon(Icons.photo_size_select_small,),),);

    Row topRow = Row(children: [pinnedIcon, growIcon, shrinkIcon, deleteIcon], 
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                verticalDirection: VerticalDirection.up,);

    Image imgAsset;

    if (widget.isEmbedded == true)
    {
      imgAsset =     Image.asset(widget.assetPath,
                                height: widget.size.height * 0.7,
                                fit: BoxFit.cover);
    }
    else
    {
      imgAsset =     Image.asset("${widget.documentsDirectory}/${widget.assetPath}",
                                height: widget.size.height * 0.7,
                                fit: BoxFit.cover);
    }

    Column centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                  Flexible(child: widget.showEditOptions ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
                                  Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                                  Flexible(child: Align(alignment: Alignment.center, child: Text(widget.label, style: defaultStyle)), flex: 2)
                                ]
                              );

    return new Container(width: widget.size.width,
                         height: widget.size.height,
                         key: GlobalKey(),
                         decoration: BoxDecoration(border: Border.all(color: Colors.black, width: widget.isPinnedToLocation ? 5.0 : 3.0),
                                                   color: widget.backgroundColor),
                         child: Column(children: [Expanded(child: centerColumn,)]),);
  }
}