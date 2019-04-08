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

import 'package:otsu/resources.dart';

class DialogIconLabel extends StatefulWidget {
  final String assetText;

  DialogIconLabel({
    this.assetText,
  });

  @override
  DialogIconLabelState createState() => DialogIconLabelState(
    assetText: assetText
  );
}

class DialogIconLabelState extends State<DialogIconLabel> {
  String assetText;
  TextControllerCustom myController;

  DialogIconLabelState({
    this.assetText
  });

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
            onPressed: () => Navigator.pop(
              context, 
              myController.text
            ),
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
      selection: TextSelection.collapsed(
        offset: text.length
      ),
      composing: TextRange.empty
    );
  }
}
