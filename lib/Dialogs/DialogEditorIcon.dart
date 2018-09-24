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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Controls/ReactiveIconWidget.dart';

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
  TextEditingController myController;

  @override
  Widget build(BuildContext context) {

    if (myController == null) {
      myController = TextEditingController(text: widget.iconWidget.key.currentState.label);
    }

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

      /*
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
      */

      imgs.add(MaterialButton( 
        color: Colors.greenAccent, 
        textColor: Colors.white,
        child: const Text("Save and Close"), 
        onPressed: () async {
          if (!(myController.text == null) && widget.iconWidget.label != myController.text)
          {
            widget.iconWidget.key.currentState.setState(()
            {
              widget.iconWidget.key.currentState.label = myController.text;  
            });
          }

          widget.saveCallback(widget.iconWidget);

          Navigator.pop(context);
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
        title: TextField(
          autofocus: false,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          controller: myController,
          decoration: new InputDecoration(
            labelText: 'Current Icon Text',
            hintText: '${myController.text}'
          ),
        ),
        content: Container(
          child: new GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            padding: const EdgeInsets.all(4.0),
            childAspectRatio: 1.0,
            children: imgs,
            shrinkWrap: true,
          ),
          width: 500.0,
          height: 500.0,
        ),
        
      ),
    opacity: 0.9,
    );
  }
}
