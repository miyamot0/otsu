import 'package:flutter/material.dart';

final bool outputToTerminal = true;

class LabelBox extends StatefulWidget {

  final Offset position = new Offset(0.0, 0.0);
  final Size size;
  final String label;
  final String assetPath;
  Color backgroundColor;
  final Function editFunction;
  final String documentsDirectory;
  final bool showEditOptions;
  final bool isPinnedToLocation;
  final bool isEmbedded;

  final double opacity;

  LabelBoxState state;

  LabelBox({this.size, this.label, this.assetPath, this.opacity: 1.0, this.backgroundColor, this.editFunction, 
            this.showEditOptions, this.isPinnedToLocation, this.isEmbedded, this.documentsDirectory,});

  @override
  State<StatefulWidget> createState()
  {
    state = new LabelBoxState();

    return state;
  }
}

class LabelBoxState extends State<LabelBox> {
  final defaultStyle = new TextStyle(color: Colors.black, 
                                     decoration: TextDecoration.none, 
                                     fontSize: 20.0);
                                     
  Row topRow;
  Image imgAsset;
  Column centerColumn;

  void showEditButtons(bool showingOptions) {
    debugPrint("showEditOptions(): $showingOptions");

    if (showingOptions == true)
    {
      centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: topRow, flex: 1),
                              Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                              Flexible(child: Align(alignment: Alignment.center, child: Text(widget.label, style: defaultStyle)), flex: 2)
                            ]
                          );
    } 
    else
    {
      centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: Opacity(child: topRow, opacity: 0.0,), flex: 1),
                              Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                              Flexible(child: Align(alignment: Alignment.center, child: Text(widget.label, style: defaultStyle)), flex: 2)
                            ]
                          );

    }   
  }

  @override
  Widget build(BuildContext context) {

    if (topRow == null) {
      var settingsIcon =  GestureDetector(behavior: HitTestBehavior.opaque,
                                          onTap: () => widget.editFunction(),
                                          child: Align(child: Icon(Icons.edit,),
                                                      alignment: Alignment.centerRight,),);

      topRow = Row(children: [settingsIcon], 
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              verticalDirection: VerticalDirection.up,);
    }

    if (imgAsset == null) 
    {
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
    }

    if (centerColumn == null)
    {
      centerColumn = Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: widget.showEditOptions ? topRow : Opacity(child: topRow, opacity: 0.0,), flex: 1),
                              Flexible(child: Align(alignment: Alignment.center, child: imgAsset,), flex: 6),
                              Flexible(child: Align(alignment: Alignment.center, child: Text(widget.label, style: defaultStyle)), flex: 2)
                            ]
                          );
    }

    return new Container(width: widget.size.width,
                         height: widget.size.height,
                         key: GlobalKey(),
                         decoration: BoxDecoration(border: Border.all(color: Colors.black, width: widget.isPinnedToLocation ? 5.0 : 3.0),
                                                   color: widget.backgroundColor),
                         child: Column(children: [Expanded(child: centerColumn,)]),);
  }

  void debugPrint(String toTerminal) {
    if (outputToTerminal == false) return;

    print("Label Box: $toTerminal");
  }
}
