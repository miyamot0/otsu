
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