
import 'package:otsu/resources.dart';

class EditIconEntry extends PopupMenuEntry<int> {
  static int DeleteIcon = -1;

  final ReactiveIconWidget iconWidget;

  EditIconEntry(this.iconWidget);

  @override
  final double height = 100;

  @override
  bool represents(int n) => true;

  @override
  EditIconEntryState createState() => EditIconEntryState();
}

class EditIconEntryState extends State<EditIconEntry> {
  void _editSizeGrow() {
    widget.iconWidget.key.currentState.setState(() {
      widget.iconWidget.key.currentState.scale = widget.iconWidget.key.currentState.scale * 1.05;
    });
  }

  void _editSizeShrink() {
    widget.iconWidget.key.currentState.setState(() {
      widget.iconWidget.key.currentState.scale = widget.iconWidget.key.currentState.scale * 0.95;
    });
  }

  void _pinIcon() {
    widget.iconWidget.key.currentState.setState(() {
      widget.iconWidget.key.currentState.isPinnedToLocation = !widget.iconWidget.key.currentState.isPinnedToLocation;
    });
  }

  void _default() {
    widget.iconWidget.key.currentState.setState(() {
      widget.iconWidget.key.currentState.scale = 1.0;
    });
  }

  void _delete() {
    Navigator.pop<int>(context, EditIconEntry.DeleteIcon);
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
          child: Text('Lock Icon')
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