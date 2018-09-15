/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';

class DialogWrapper extends StatelessWidget {
  final String assetText;
  TextEditingController myController;

  DialogWrapper({Key key, this.assetText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    myController = TextEditingController(text: assetText);

    return new AnimatedContainer(
        padding: mediaQuery.padding,
        duration: const Duration(milliseconds: 300),
        child: new AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        content: new Row(
          children: <Widget>[
            new Expanded(
              child: TextField(autofocus: true,
                               controller: myController,
                                          decoration: new InputDecoration(labelText: 'Write Icon Text',
                                                                          hintText: '$assetText')),
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(child: const Text('Update Label'),
                         onPressed: () => Navigator.pop(context, myController.text))
        ],
        )
      );
  }
}