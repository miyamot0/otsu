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

class EditFolderEntry extends PopupMenuEntry<int> {
  static const int DeleteFolder = -1;
  static const int ModifyFolderLabel = -2;

  final ReactiveFolderWidget folderWidget;

  EditFolderEntry(this.folderWidget);

  @override
  final double height = 100;

  @override
  bool represents(int n) => true;

  @override
  EditFolderEntryState createState() => EditFolderEntryState();
}

class EditFolderEntryState extends State<EditFolderEntry> {
  void _editSizeGrow() {
    widget.folderWidget.key.currentState.setState(() {
      widget.folderWidget.key.currentState.scale = widget.folderWidget.key.currentState.scale * 1.05;
    });
  }

  void _editSizeShrink() {
    widget.folderWidget.key.currentState.setState(() {
      widget.folderWidget.key.currentState.scale = widget.folderWidget.key.currentState.scale * 0.95;
    });
  }

  void _pinIcon() {
    widget.folderWidget.key.currentState.setState(() {
      widget.folderWidget.key.currentState.isPinnedToLocation = !widget.folderWidget.key.currentState.isPinnedToLocation;
    });
  }

  void _editLabel() {
    Navigator.pop<int>(context, EditFolderEntry.ModifyFolderLabel);
  }

  void _default() {
    widget.folderWidget.key.currentState.setState(() {
      widget.folderWidget.key.currentState.scale = 1.0;
    });
  }

  void _delete() {
    Navigator.pop<int>(context, EditFolderEntry.DeleteFolder);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FlatButton(
          onPressed: _editSizeGrow, 
          child: Text('Increase Size')
        ),
        FlatButton(
          onPressed: _editSizeShrink, 
          child: Text('Decrease Size')
        ),
        FlatButton(
          onPressed: _pinIcon, 
          child: Text('Lock Folder')
        ),
        FlatButton(
          onPressed: _editLabel, 
          child: Text('Edit Label')
        ),
        FlatButton(
          onPressed: _default, 
          child: Text('Revert to Default')
        ),
        FlatButton(
          onPressed: _delete, 
          child: Text('Delete')
        ),
      ],
    );
  }
}