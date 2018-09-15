import 'package:flutter/material.dart';

import '../Controls/FolderWidget.dart';
import '../Models/ModificationType.dart';

class DialogEditorFolder extends StatefulWidget {
  final FolderWidget folderWidget;

  DialogEditorFolder(this.folderWidget);

  @override
  DialogEditorFolderState createState() => new DialogEditorFolderState();
}

class DialogEditorFolderState extends State<DialogEditorFolder> {

  _getGrowButton(double reccHeight) {
      return new MaterialButton( 
        height: reccHeight, 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white,
        child: new Text("Increase Size"), 
        onPressed: () {
          print("onPressed - Increase()");
          widget.folderWidget.state.modifyWidget(ModifyAction.Grow, silent: true);
        }, 
        splashColor: Colors.redAccent);
  }

  _getShrinkButton(double reccHeight) {
      return new MaterialButton( 
        height: reccHeight, 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white, 
        child: new Text("Decrease Size"), 
        onPressed: () {
          print("onPressed - Decrease()");
          widget.folderWidget.state.modifyWidget(ModifyAction.Shrink, silent: true);
        }, 
        splashColor: Colors.redAccent);
  }

  _getPinButton(double reccHeight) {
      return new MaterialButton( 
        height: reccHeight, 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white, 
        child: new Text("Fix/Unfix Position"), 
        onPressed: () {
          print("onPressed - Pin()");
          widget.folderWidget.state.modifyWidget(ModifyAction.Pin, silent: true);
        }, 
        splashColor: Colors.redAccent);
  }

  _getRenameButton(double reccHeight) {
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

  _getDeleteButton(double reccHeight) {
      return new MaterialButton( 
        height: reccHeight, 
        color: Colors.redAccent, 
        textColor: Colors.white, 
        child: new Text("Delete Element"), 
        onPressed: () {
          print("onPressed - Delete()");
          widget.folderWidget.state.modifyWidget(ModifyAction.Delete, silent: true);

          Navigator.pop(context);
        }, 
        splashColor: Colors.redAccent);
  }

  _getDefaultButton(double reccHeight) {
      return new MaterialButton( 
        height: reccHeight, 
        color: Theme.of(context).primaryColor, 
        textColor: Colors.white, 
        child: new Text("Default Size"), 
        onPressed: () {
          print("onPressed - Default Size()");

          widget.folderWidget.state.modifyWidget(ModifyAction.Default, silent: true);
        }, 
        splashColor: Colors.redAccent);
  }

  final defaultStyle = new TextStyle(color: Colors.black, 
                                     decoration: TextDecoration.none, 
                                     fontSize: 20.0);

  @override
  Widget build(BuildContext context) {

    var dialogDimension = MediaQuery.of(context).size.height * 0.7;

    // 10% of window?
    var closeIcon = GestureDetector(child: Icon(Icons.close, size: dialogDimension * 0.125,),
                                    onTap: () => Navigator.pop(context),);

    var numRows = 3;
    var rowHeight = (dialogDimension * 3.0/4.0) / numRows;

    var buttonContainer = Expanded(
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: <Widget>[
        Expanded(child: Column(children: <Widget>[
          Padding(child: _getGrowButton(rowHeight), padding: EdgeInsets.all(5.0),),
          Padding(child: _getDefaultButton(rowHeight), padding: EdgeInsets.all(5.0),),          
          
          ],
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              ),
        ),
        Expanded(child: Column(children: <Widget>[
          Padding(child: _getShrinkButton(rowHeight), padding: EdgeInsets.all(5.0),),
          Padding(child: _getRenameButton(rowHeight), padding: EdgeInsets.all(5.0),),
          
          ],
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              ),
        ),
        Expanded(child: Column(children: <Widget>[
          Padding(child: _getPinButton(rowHeight), padding: EdgeInsets.all(5.0),),
          Padding(child: _getDeleteButton(rowHeight), padding: EdgeInsets.all(5.0),),
          
          ],
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              ),
        ),
      ],
      
      ),
    );

    var columnContent = Column(children: [
            Row(children: <Widget>[
              Expanded(child: Padding(child: Text("Editing Widget: ${widget.folderWidget.text}", style: defaultStyle,), padding: EdgeInsets.all(5.0),), ),
              Align(child: closeIcon, alignment: Alignment.topRight,)
            ],
            ),
            buttonContainer,
    ],
    );

    var dialogContainer = Container(child: columnContent,
                                           width: dialogDimension,
                                           height: dialogDimension * 3.0/4.0,
                                           decoration: BoxDecoration(
                                             border: Border.all(color: Colors.black, width: 3.0),
                                             color: Colors.white,
                                           ),);

    return new Scaffold(
      backgroundColor: Colors.black.withAlpha(150),
      body: Center(child: Opacity(child: dialogContainer,
                                  opacity: 0.9,)
                  ),
    );
  }
}