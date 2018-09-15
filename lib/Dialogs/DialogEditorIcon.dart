/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

import '../Controls/ReactiveIconWidget.dart';

class DialogEditorIcon extends StatefulWidget {
  final ReactiveIconWidget iconWidget;
  final Function deleteCallback;

  DialogEditorIcon(this.iconWidget, this.deleteCallback);

  @override
  DialogEditorIconState createState() => new DialogEditorIconState();
}

class DialogEditorIconState extends State<DialogEditorIcon> {

  MaterialButton _getGrowButton(double reccHeight) {
    return new MaterialButton( 
      height: reccHeight, 
      color: Theme.of(context).primaryColor, 
      textColor: Colors.white,
      child: new Text("Increase Size"), 
      onPressed: () {
        widget.iconWidget.key.currentState.setState(() {
          widget.iconWidget.key.currentState.scale = widget.iconWidget.key.currentState.scale * 1.05;
        });
      }, 
      splashColor: Colors.redAccent);
  }

  MaterialButton _getShrinkButton(double reccHeight) {
    return new MaterialButton( 
      height: reccHeight, 
      color: Theme.of(context).primaryColor, 
      textColor: Colors.white, 
      child: new Text("Decrease Size"), 
      onPressed: () {
        widget.iconWidget.key.currentState.setState(() {
          widget.iconWidget.key.currentState.scale = widget.iconWidget.key.currentState.scale * 0.95;
        });
      }, 
      splashColor: Colors.redAccent);
  }

  MaterialButton _getPinButton(double reccHeight) {
    return new MaterialButton( 
      height: reccHeight, 
      color: Theme.of(context).primaryColor, 
      textColor: Colors.white, 
      child: new Text("Fix/Unfix Position"), 
      onPressed: () {
        widget.iconWidget.key.currentState.setState(() {
          widget.iconWidget.key.currentState.isPinnedToLocation = !widget.iconWidget.key.currentState.isPinnedToLocation;
        });
      }, 
      splashColor: Colors.redAccent);
  }

  MaterialButton _getRenameButton(double reccHeight) {
    return new MaterialButton( 
      height: reccHeight, 
      color: Theme.of(context).primaryColor, 
      textColor: Colors.white, 
      child: new Text("Rename Element"), 
      onPressed: () {
        print("STUB: Rename Element");
        
      }, 
      splashColor: Colors.redAccent);
  }

  MaterialButton _getDeleteButton(double reccHeight) {
    return new MaterialButton( 
      height: reccHeight, 
      color: Colors.redAccent, 
      textColor: Colors.white, 
      child: new Text("Delete Element"), 
      onPressed: () {
        widget.deleteCallback(widget.iconWidget);

        Navigator.pop(context);
      }, 
      splashColor: Colors.redAccent);
  }

  MaterialButton _getDefaultButton(double reccHeight) {
    return new MaterialButton( 
      height: reccHeight, 
      color: Theme.of(context).primaryColor, 
      textColor: Colors.white, 
      child: new Text("Default Size"), 
      onPressed: () {
        widget.iconWidget.key.currentState.setState(() {
          widget.iconWidget.key.currentState.scale = 1.0;
        });
      }, 
      splashColor: Colors.redAccent);
  }

  static const defaultStyle = TextStyle(
    color: Colors.black, 
    decoration: TextDecoration.none, 
    fontSize: 20.0,
  );

  @override
  Widget build(BuildContext context) {
    double dialogDimension = MediaQuery.of(context).size.height * 0.7;

    GestureDetector closeIcon = GestureDetector(
      child: Icon(
        Icons.close, 
        size: dialogDimension * 0.125,
      ),
      onTap: () => Navigator.pop(context),
    );

    double numRows = 3.0;
    double rowHeight = (dialogDimension * 3.0/4.0) / numRows;

    Expanded buttonContainer = Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  child: _getGrowButton(rowHeight), 
                  padding: EdgeInsets.all(5.0),
                ),
                Padding(
                  child: _getDefaultButton(rowHeight), 
                  padding: EdgeInsets.all(5.0),
                ),          
              ],
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  child: _getShrinkButton(rowHeight), 
                  padding: EdgeInsets.all(5.0),
                ),
                Padding(
                  child: _getRenameButton(rowHeight), 
                  padding: EdgeInsets.all(5.0),
                ),
              ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  child: _getPinButton(rowHeight), 
                  padding: EdgeInsets.all(5.0),
                ),
                Padding(
                  child: _getDeleteButton(rowHeight), 
                  padding: EdgeInsets.all(5.0),
                ),
              ],
              crossAxisAlignment: CrossAxisAlignment.stretch,
            ),
          ),
        ],
      ),
    );

    Column columnContent = Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                child: Text(
                  "Editing Widget: ${widget.iconWidget.key.currentState.label}", 
                  style: defaultStyle,
                ), 
                padding: EdgeInsets.all(5.0),
              ), 
            ),
            Align(
              child: closeIcon, 
              alignment: Alignment.topRight,
            ),
          ],
        ),
        buttonContainer,
      ],
    );

    Container dialogContainer = Container(
      child: columnContent,
      width: dialogDimension,
      height: dialogDimension * 3.0/4.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black, 
          width: 3.0,
        ),
        color: Colors.white,
      ),
    );

    return new Scaffold(
      backgroundColor: Colors.black.withAlpha(150),
      body: Center(
        child: Opacity(
          child: dialogContainer,
          opacity: 0.9,
        ),
      ),
    );
  }
}
