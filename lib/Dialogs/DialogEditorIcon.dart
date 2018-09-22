/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Controls/ReactiveIconWidget.dart';
import '../Dialogs/DialogIconLabel.dart';

class DialogEditorIcon extends StatefulWidget {
  final ReactiveIconWidget iconWidget;
  final Function deleteCallback;
  final Function saveCallback;

  DialogEditorIcon(
    this.iconWidget, 
    this.deleteCallback,
    this.saveCallback,
  );

  @override
  DialogEditorIconState createState() => new DialogEditorIconState();
}

class DialogEditorIconState extends State<DialogEditorIcon> {

  final List<MaterialButton> imgs = [];

  /// Show edit text dialog
  /// 
  /// 
  Future<String> _showInputDialog() async {
    //debugPrint("_showInputDialog()");
    return await showDialog<String>(
      context: context,
      child: new DialogIconLabel(assetText: widget.iconWidget.key.currentState.label),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (imgs.length == 0) {
      imgs.add(MaterialButton( 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white,
        child: const Text("Increase Size"), 
        onPressed: () async {
          widget.iconWidget.key.currentState.setState(() {
            widget.iconWidget.key.currentState.scale = widget.iconWidget.key.currentState.scale * 1.05;
          });

          widget.saveCallback(widget.iconWidget);
        }, 
        splashColor: Colors.redAccent,
      ));

      imgs.add(MaterialButton( 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white,
        child: const Text("Decrease Size"), 
        onPressed: () async {
          widget.iconWidget.key.currentState.setState(() {
            widget.iconWidget.key.currentState.scale = widget.iconWidget.key.currentState.scale * 0.95;
          });

          widget.saveCallback(widget.iconWidget);
        }, 
        splashColor: Colors.redAccent,
      ));

      imgs.add(MaterialButton( 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white,
        child: const Text("Pin Icon"), 
        onPressed: () async {
            widget.iconWidget.key.currentState.setState(() {
              widget.iconWidget.key.currentState.isPinnedToLocation = !widget.iconWidget.key.currentState.isPinnedToLocation;
            });

            widget.saveCallback(widget.iconWidget);
        }, 
        splashColor: Colors.redAccent,
      ));

      imgs.add(MaterialButton( 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white,
        child: const Text("Rename Icon"), 
        onPressed: () async {
          String newText = await _showInputDialog();

          if (newText == null) return;

          await SystemChrome.setEnabledSystemUIOverlays([]);

          widget.iconWidget.key.currentState.setState(()
          {
            widget.iconWidget.key.currentState.label = newText;  
          });

          widget.saveCallback(widget.iconWidget);
        }, 
        splashColor: Colors.redAccent,
      ));

      imgs.add(MaterialButton( 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white,
        child: const Text("Set Default Size"), 
        onPressed: () async {
          widget.iconWidget.key.currentState.setState(() {
            widget.iconWidget.key.currentState.scale = 1.0;
          });

          widget.saveCallback(widget.iconWidget);
        }, 
        splashColor: Colors.redAccent,
      ));

      imgs.add(MaterialButton( 
        color: Colors.redAccent, 
        textColor: Colors.white,
        child: const Text("Delete Icon"), 
        onPressed: () async {
          widget.iconWidget.key.currentState.controller.reverse().then((err) {
            widget.deleteCallback(widget.iconWidget);

            Navigator.pop(context);
          });
        }, 
        splashColor: Colors.blueAccent,
      ));
    }

    return Opacity(
      child: AlertDialog(
        title: Center(
          child: Text("Editing Icon: ${widget.iconWidget.key.currentState.label}"),
        ),
        content: Container(
          child: new GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            padding: const EdgeInsets.all(4.0),
            childAspectRatio: 1.0,
            children: imgs,
          ),
        width: 500.0,
        height: 500.0,
        ),
      ),
    opacity: 0.9,
    );
  }
}
