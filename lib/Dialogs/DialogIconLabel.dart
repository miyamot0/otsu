/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

class DialogIconLabel extends StatefulWidget {
  final String assetText;
  final GlobalKey<DialogIconLabelState> key = GlobalKey<DialogIconLabelState>();

  DialogIconLabel({this.assetText}) : super(key: GlobalKey());

  @override
  DialogIconLabelState createState() => DialogIconLabelState(
    key: key, 
    assetText: assetText
  );
}

class DialogIconLabelState extends State<DialogIconLabel> {
  String assetText;
  TextControllerCustom myController;

  DialogIconLabelState({Key key, this.assetText});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);

    myController = TextControllerCustom(text: assetText);
    myController.setText(assetText);

    return new AnimatedContainer(
      padding: mediaQuery.padding,
      duration: const Duration(milliseconds: 300),
      child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: TextField(
                autofocus: false,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                controller: myController,
                decoration: new InputDecoration(
                  labelText: 'Edit Text',
                  hintText: '${myController.text}'
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          new FlatButton(
            child: const Text('Update'),
            onPressed: () => Navigator.pop(context, myController.text)
          ),
        ],
      )
    );
  }
}

class TextControllerCustom extends TextEditingController {
  TextControllerCustom({String text}) : super(text: text);

  void setText(String text) 
  {
    value = value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty
    );
  }
}
