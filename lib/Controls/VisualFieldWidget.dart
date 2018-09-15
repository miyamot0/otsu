import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../Controls/AnimatedMenu.dart';
import '../Controls/ReactiveIconWidget.dart';
import '../Controls/ReactiveFolderWidget.dart';
import '../Controls/SpeakerObject.dart';
import '../Controls/StripObject.dart';

import '../Dialogs/DialogEditorIcon.dart';
import '../Dialogs/DialogEditorFolder.dart';

import '../Models/IconType.dart';
import '../Models/EmbeddedIconModel.dart';

import '../Pages/IconCreator.dart';

import '../Storage/IconDatabase.dart';

class VisualFieldWidget extends StatefulWidget {

  VisualFieldWidget() : super(key: GlobalKey());

  @override
  VisualFieldWidgetState createState() => VisualFieldWidgetState();  
}

class VisualFieldWidgetState extends State<VisualFieldWidget> {
  IconDatabase iconDb;

  bool inDebugMode = true;
  Color background = Colors.orangeAccent;

  BoardSettings boardSettings;

  var stackElements = <Widget>[];

  AnimatedMenuWidget animatedMenu;
  final childButtons = List<AnimatedMenuItem>();

  StripObject sentenceStripReference;
  SpeakerObject speakerObjectReference;

  String dir;

  @override
  void initState() {
    print("initState()");
    sentenceStripReference = StripObject(padding: 10.0);

    speakerObjectReference = SpeakerObject(emitSpeech, toggleDebugMode);
      stackElements.add(speakerObjectReference);

    loadFromDatabase();

    super.initState();
  }

  void loadFromDatabase() async {
    print("loadFromDatabase()");
    dir = (await getApplicationDocumentsDirectory()).path;

    iconDb = new IconDatabase();
    await iconDb.open();

    boardSettings = await iconDb.loadSettings();

    if (boardSettings.checkIsInSingleMode == false) {
      stackElements.add(sentenceStripReference);      
    }

    List<SavedIcon> icons = await iconDb.getSavedIcons();

    print("Icons in db: ${icons.length}");

    setState(() {
      for (var i = 0; i < icons.length; i++) {

        if (icons[i].isFolder == false)
        {
          stackElements.add(ReactiveIconWidget(label: icons[i].iconName,
                                              iconType: IconType.Icon,
                                              assetPath: icons[i].iconPath, 
                                              isInSingleMode: boardSettings.checkIsInSingleMode,
                                              isEmbbedded: icons[i].embedded,
                                              isStored: icons[i].isStored, 
                                              isInPlay: false,
                                              isPinnedToLocation: icons[i].pinned,
                                              launchEditor: _triggerIconEditor,
                                              scale: icons[i].scale,
                                              defaultWidth: 200.0,
                                              moveToTop: moveIconToTop,
                                              id: icons[i].id,
                                              storedId: icons[i].storedId,
                                              initialPosition: Offset(icons[i].x, icons[i].y),));
        }
        else
        {
          stackElements.add(ReactiveFolderWidget(label: icons[i].iconName,
                                              iconType: IconType.Folder,
                                              assetPath: icons[i].iconPath, 
                                              isInSingleMode: boardSettings.checkIsInSingleMode,
                                              isEmbbedded: icons[i].embedded,
                                              isStored: icons[i].isStored, 
                                              launchEditor: _triggerFolderEditor,
                                              openFolderDialog: _navigateToFolderContentDialog,
                                              isInPlay: false,
                                              isPinnedToLocation: icons[i].pinned,
                                              scale: icons[i].scale,
                                              defaultWidth: 200.0,
                                              moveToTop: moveIconToTop,
                                              id: icons[i].id,
                                              initialPosition: Offset(icons[i].x, icons[i].y),));
        }


      }
        
      speakerObjectReference.speak("").then((_) => debugPrint("TTS Module Loaded..."));
    });

    childButtons.clear();

    childButtons.add(_buildAddFolderButton());
    childButtons.add(_buildAddIconButton());
    childButtons.add(_buildSwitchModeButton());
    childButtons.add(_buildAutoOutputModeButton()); 
    childButtons.add(_buildAutoDeselectModeButton());      
    childButtons.add(_buildResumeChildModeButton()); 

  }

  Future<bool> _isIconOverlappingWithFolder(ReactiveIconWidget widget) async {
    debugPrint("_isIconOverlappingWithFolder()");

    var folders =  stackElements.where((w) => w is ReactiveFolderWidget)
                                .where((w) => (w as ReactiveFolderWidget).key.currentState.defaultWidth != null)
                                .where((w) => (w as ReactiveFolderWidget).intersectsWith(widget.key.currentState.defaultWidth, 
                                                                                         widget.key.currentState.currentPosition))
                                .toList();   

    if (folders != null && folders.length > 0)
    {
        ReactiveFolderWidget droppableFolder = folders.first;
        debugPrint("DROP: folder.text = ${droppableFolder.key.currentState.label} folder.id = ${droppableFolder.id} ");

        SavedIcon savedIcon = SavedIcon();
        savedIcon.id        = widget.id;
        savedIcon.iconName  = widget.key.currentState.label;
        savedIcon.iconPath  = widget.assetPath;
        savedIcon.x         = widget.key.currentState.currentPosition.dx;
        savedIcon.y         = widget.key.currentState.currentPosition.dy;
        savedIcon.embedded  = widget.key.currentState.isEmbbedded;
        savedIcon.pinned    = widget.key.currentState.isPinnedToLocation;
        savedIcon.scale     = widget.key.currentState.scale;
        savedIcon.active    = widget.key.currentState.isInPlay;
        savedIcon.isStored  = true;
        savedIcon.storedId  = droppableFolder.id;
        savedIcon.isFolder  = false;

        await iconDb.update(savedIcon);

        setState(() {
          stackElements.remove(widget);          
        });

        return true;
    }

    debugPrint("_isIconOverlappingWithFolder() == FALSE");

    return false;
  }

  void moveIconToTop(Widget widget) async {
    print("moveTestIconToTop(TestIcon widget)");

    // Is the icon at the top of the stack overlapping with a folder?
    if (widget is ReactiveIconWidget)
    {
      if (await _isIconOverlappingWithFolder(widget) == true) 
        return;

    }

    if (boardSettings.checkIsInSingleMode == true)
    {
      for (var i = 0; i < stackElements.length; i++)
      {
        if (stackElements[i] is ReactiveIconWidget && stackElements[i] != widget)
        {
          (stackElements[i] as ReactiveIconWidget).key.currentState.setState(() {
            (stackElements[i] as ReactiveIconWidget).key.currentState.isInPlay = false;
          });
        }
      }

      stackElements.remove(widget);
      stackElements.add(widget);

      if (widget is ReactiveIconWidget)
      {
        widget.key.currentState.setState(() {
          widget.key.currentState.isInPlay = true;
        });

        if (boardSettings.checkIsAutoSpeaking) {
          emitSpeech();
        }
      }
    }

    _saveLatestStack(widget);

  }

  _saveLatestStack(Widget widget) async {
    debugPrint("_saveLatestStack() " + new DateTime.now().toString());

    if (iconDb == null) return;

    if (widget != null && widget is ReactiveIconWidget)
    {
        if (widget.iconType == IconType.Icon)
        {
          SavedIcon savedIcon = SavedIcon();
          savedIcon.id        = widget.id;
          savedIcon.iconName  = widget.label;
          savedIcon.iconPath  = widget.assetPath;
          savedIcon.x         = widget.key.currentState.currentPosition.dx;
          savedIcon.y         = widget.key.currentState.currentPosition.dy;
          savedIcon.embedded  = widget.key.currentState.isEmbbedded;
          savedIcon.pinned    = widget.key.currentState.isPinnedToLocation;
          savedIcon.scale     = widget.key.currentState.scale;
          savedIcon.active    = widget.key.currentState.isInPlay;
          savedIcon.isStored  = widget.key.currentState.isStored;
          savedIcon.storedId  = widget.storedId;
          savedIcon.isFolder  = false;

          await iconDb.update(savedIcon);
        }
    }

    iconDb.saveSettings(boardSettings);
  }

  /// Remove from stack
  /// 
  /// 
  _removeFromDatabase(Widget widget) async {
    print("_removeFromStack(Widget widget)");

    if (widget is ReactiveIconWidget)
    {
      await iconDb.delete(widget.id);

      setState(() {
        stackElements.remove(widget);
      });
    }

    if (widget is ReactiveFolderWidget)
    {
       await iconDb.deleteFolder(widget.id);

      setState(() {
        stackElements.remove(widget);
      });
    }
  }

  /// Build auto output button
  /// 
  /// 
  _buildAutoOutputModeButton() {
    return AnimatedMenuItem(
        hasLabel: true,
        labelText: boardSettings.checkIsAutoSpeaking == true ? "Change to Manual Mode" : "Change to Autospeak Mode",
        labelColor: Colors.black,
        currentButton: FloatingActionButton(
            backgroundColor: Colors.blue,
            heroTag: "autoTag",
            mini: false,
            child: Icon(Icons.volume_up),
            onPressed: () {
              setState(() {
                boardSettings.checkIsAutoSpeaking = !boardSettings.checkIsAutoSpeaking;

                debugPrint("autoSpeaking Delegate: Status = ${boardSettings.checkIsAutoSpeaking}");
              });
            },
        ));
  }

  /// Build auto deselect button
  /// 
  /// 
  _buildAutoDeselectModeButton() {
    return AnimatedMenuItem(
        hasLabel: true,
        labelText: boardSettings.checkIsAutoDeselecting == true ? "Disable Auto-Deselect" : "Enable Auto-Deselect",
        labelColor: Colors.black,
        currentButton: FloatingActionButton(
            backgroundColor: Colors.red,
            heroTag: "deselectTag",
            mini: false,
            child: Icon(Icons.fingerprint),
            onPressed: () {
              setState(() {
                boardSettings.checkIsAutoDeselecting = !boardSettings.checkIsAutoDeselecting;   

                debugPrint("autoDeselect Delegate: Status = ${boardSettings.checkIsAutoDeselecting}");

                /*
                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);
                */
              });
            },
        ));
  }

  /// Build switch button
  ///
  ///
  _buildSwitchModeButton() {
    return AnimatedMenuItem(
        hasLabel: true,
        labelText: boardSettings.checkIsInSingleMode == true ? "Change to Frame Mode" : "Change to Icon Mode",
        labelColor: Colors.black,
        currentButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            heroTag: "frameTag",
            mini: false,
            child: Icon(Icons.border_all),
            onPressed: () {
              setState(() {
                boardSettings.checkIsInSingleMode = !boardSettings.checkIsInSingleMode;

                debugPrint("modeSelect Delegate: Status = ${boardSettings.checkIsInSingleMode}");
              });
            },
        ));
  }

  /// Build resume button
  ///
  ///
  _buildResumeChildModeButton() {
    return AnimatedMenuItem(
        hasLabel: true,
        labelText: "Resume Child Mode",
        labelColor: Colors.black,
        currentButton: FloatingActionButton(
            backgroundColor: Colors.deepPurple,
            heroTag: "resumeTag",
            mini: false,
            child: Icon(Icons.play_arrow),
            onPressed: _resumeChildMode,
        ));
  }

  /// Resume child interaction mode
  /// 
  /// This disables debug mode (hides buttons)
  _resumeChildMode() {
    print('_resumeChildMode()');

    setState(() {
      inDebugMode = false;
    });

    if (boardSettings.checkIsInSingleMode == true) {
      deselectAllIcons();
    }
    
    // TODO strip
  }

  void toggleDebugMode() {
    print("toggleDebugMode()");

    setState(() {
      inDebugMode = true;
    });
  }

  void deselectAllIcons() {
    for (var x in stackElements) 
    {
      if (x is ReactiveIconWidget)
      {
        if (x.key.currentState.isInPlay == true)
        {
          x.key.currentState.setState(() {
            x.key.currentState.isInPlay = false;
          });
        }
      }
    }
  }

  void emitSpeech() async {
    print("emitSpeech()");

    if (boardSettings.checkIsInSingleMode == true)
    {
      print("emitSpeech() single mode");
      for (var x in stackElements) 
      {
        if (x is ReactiveIconWidget)
        {
          if (x.key.currentState.isInPlay)
          {
            await speakerObjectReference.speak(x.label);

            if (boardSettings.checkIsAutoDeselecting == true)
            {
              deselectAllIcons();

              return;
            }
          }
        }
      }
    }
    else
    {
      /*
      var tempList = <IconWidget>[];
      var outputString = "";

      for (var x in _stackElements) 
        if (x is IconWidget && _isWithinStrip(x)) tempList.add(x);

      if (tempList.length > 0)
      {
        tempList.sort((a, b) => a.currentPosition.dx.compareTo(b.currentPosition.dx));

        for (var icon in tempList)
          outputString = outputString + " " + icon.text;
        
        await speakerObjectReference.speak(outputString);
      }
      */
    }
  }

  _triggerIconEditor(ReactiveIconWidget widget) {
      debugPrint("_triggerIconEditor()");
      
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
              return DialogEditorIcon(widget, _removeFromDatabase);
          }
      ));
  }

  _triggerFolderEditor(ReactiveFolderWidget widget) {
      debugPrint("_triggerIconEditor()");
      
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
              return DialogEditorFolder(widget, _removeFromDatabase);
          }
      ));
  }

  /// Navigate to folder contents
  _navigateToFolderContentDialog(ReactiveFolderWidget folderWidget) async {
    debugPrint("_navigateToFolderContentDialog: ${folderWidget.key.currentState.label}");

      var storedIcons = await iconDb.getStoredIcons(folderWidget.id);

      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return _buildFolderPopupDialog(folderWidget, storedIcons);
        },
      );
  }

  /// TODO: assign size (square, based on %age height)
  /// TODO: query stored icons
  /// TODO: display in grid view
  AlertDialog _buildFolderPopupDialog(ReactiveFolderWidget folderWidget, List<SavedIcon> storedIcons) {
    debugPrint("_buildFolderPopupDialog, length = ${storedIcons.length}");

    List<Container> imgs = [];

    for (SavedIcon storedIcon in storedIcons)
    {
        imgs.add(new Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.0),
            color: Colors.white,
          ),
          child: GestureDetector(child: new Image.asset(storedIcon.iconPath),
                                  onTap: () {
                                    _restoreIconFromStorage(storedIcon);

                                    Navigator.pop(context);
                                  },),            
        ));
    }

    return AlertDialog(title: Center(child: Text(folderWidget.key.currentState.label)),
                       content: Container(child: new GridView.count(crossAxisCount: 3,
                                                                    mainAxisSpacing: 4.0,
                                                                    crossAxisSpacing: 4.0,
                                                                    padding: const EdgeInsets.all(4.0),
                                                                    childAspectRatio: 1.0,
                                                                    children: imgs,),
                                          width: 500.0,
                                          height: 500.0,),
                                          ); 
  }

  /// Restore image from storage
  _restoreIconFromStorage(SavedIcon savedIcon) async {
    debugPrint("_restoreIconFromStorage(SavedIcon savedIcon)");

    savedIcon.isStored = false;
    savedIcon.storedId = -1;

    await iconDb.update(savedIcon);

    setState(() {
      stackElements.add(ReactiveIconWidget(label: savedIcon.iconName,
                                          iconType: IconType.Icon,
                                          assetPath: savedIcon.iconPath, 
                                          isInSingleMode: boardSettings.checkIsInSingleMode,
                                          isEmbbedded: savedIcon.embedded,
                                          isStored: savedIcon.isStored, 
                                          isInPlay: false,
                                          isPinnedToLocation: savedIcon.pinned,
                                          launchEditor: _triggerIconEditor,
                                          scale: savedIcon.scale,
                                          defaultWidth: 200.0,
                                          moveToTop: moveIconToTop,
                                          id: savedIcon.id,
                                          storedId: savedIcon.storedId,
                                          initialPosition: Offset(savedIcon.x, savedIcon.y),));           
    });
  }

  @override
  Widget build(BuildContext context) {

    if (childButtons.length > 0)
    {
      childButtons.clear();
      childButtons.add(_buildAddFolderButton());
      childButtons.add(_buildAddIconButton());
      childButtons.add(_buildSwitchModeButton());
      childButtons.add(_buildAutoOutputModeButton()); 
      childButtons.add(_buildAutoDeselectModeButton());      
      childButtons.add(_buildResumeChildModeButton()); 
    }
  
    animatedMenu = _buildAnimatedMenu(childButtons);

    toggleSentenceStrip();
    
    return InheritedVisualFieldState(
      background: background,
      inDebugMode: inDebugMode,
      stackElements: stackElements,
      animatedMenu: animatedMenu,
      boardSettings: boardSettings,
      documentsDirectory: dir,
      child: VisualFieldBox(),
      key: GlobalKey(),
    );
  }

  /// Toggle visibility of strip
  /// 
  /// 
  void toggleSentenceStrip() {
    debugPrint("toggleSentenceStrip(): ${boardSettings == null}");

    if (boardSettings == null) return;

    if (boardSettings.checkIsInSingleMode == true && stackElements.contains(sentenceStripReference))
    {
      stackElements.remove(sentenceStripReference);
    }

    if (boardSettings.checkIsInSingleMode == false && !stackElements.contains(sentenceStripReference))
    {
      stackElements.insert(0, sentenceStripReference);
    }
  }

  /// Build icon button 
  ///
  ///
  _buildAddFolderButton() {
    return AnimatedMenuItem(
        hasLabel: true,
        labelText: "Add a Folder",
        labelColor: Colors.black,
        
        currentButton: FloatingActionButton(
            backgroundColor: Colors.amber,
            heroTag: "addFolderTag",
            mini: false,
            child: Icon(Icons.folder_open),
            onPressed: () async {
              debugPrint("TODO: Folder selection options");

              SavedIcon savedIcon = SavedIcon();
              savedIcon.id        = null;
              savedIcon.iconName  = "Folder 1";
              savedIcon.iconPath  = "images/FolderOpenRed.png";
              savedIcon.x         = 500.0;
              savedIcon.y         = 500.0;
              savedIcon.embedded  = true;
              savedIcon.pinned    = false;
              savedIcon.scale     = 1.0;
              savedIcon.active    = false;
              savedIcon.isStored  = false;
              savedIcon.storedId  = -1;
              savedIcon.isFolder  = true;

              SavedIcon insert = await iconDb.insert(savedIcon);

              setState(() 
              {
                stackElements.add(ReactiveFolderWidget(label: insert.iconName,
                                                    iconType: IconType.Folder,
                                                    assetPath: insert.iconPath, 
                                                    isInSingleMode: boardSettings.checkIsInSingleMode,
                                                    isEmbbedded: insert.embedded,
                                                    isStored: insert.isStored, 
                                                    launchEditor: _triggerFolderEditor,
                                                    openFolderDialog: _navigateToFolderContentDialog,
                                                    isInPlay: false,
                                                    isPinnedToLocation: insert.pinned,
                                                    scale: insert.scale,
                                                    defaultWidth: 200.0,
                                                    moveToTop: moveIconToTop,
                                                    id: insert.id,
                                                    initialPosition: Offset(insert.x, insert.y),));
              });
            },
        ));
  }

  /// Build icon button 
  ///
  ///
  _buildAddIconButton() {
    return AnimatedMenuItem(
        hasLabel: true,
        labelText: "Add an Icon",
        labelColor: Colors.black,
        
        currentButton: FloatingActionButton(
            backgroundColor: Colors.green,
            heroTag: "addIconTag",
            mini: false,
            child: Icon(Icons.add_a_photo),
            onPressed: () => _navigateToIconCreatorScreen(context),
        ));
  }

  _navigateToIconCreatorScreen(BuildContext context) async {
    debugPrint("_navigateToIconCreatorScreen()");
    EmbeddedIconModel result = await Navigator.push(context, MaterialPageRoute(builder: (context) => IconCreatorScreen(dir)));

    if (result == null) return;

    SavedIcon savedIcon = SavedIcon();
    savedIcon.id        = null;
    savedIcon.iconName  = result.iconText;
    savedIcon.iconPath  = result.assetLocation;
    savedIcon.x         = 0.0;
    savedIcon.y         = 0.0;
    savedIcon.embedded  = result.isEmbedded;
    savedIcon.pinned    = false;
    savedIcon.scale     = 1.0;
    savedIcon.active    = false;
    savedIcon.isStored  = false;
    savedIcon.storedId  = -1;
    savedIcon.isFolder  = false;

    SavedIcon insert = await iconDb.insert(savedIcon);

    setState(() 
    {
      stackElements.add(ReactiveIconWidget(label: insert.iconName,
                                          iconType: IconType.Icon,
                                          assetPath: insert.iconPath, 
                                          isInSingleMode: boardSettings.checkIsInSingleMode,
                                          isEmbbedded: insert.embedded,
                                          isStored: insert.isStored, 
                                          isInPlay: false,
                                          isPinnedToLocation: insert.pinned,
                                          launchEditor: _triggerIconEditor,
                                          scale: insert.scale,
                                          defaultWidth: 200.0,
                                          moveToTop: moveIconToTop,
                                          id: insert.id,
                                          storedId: insert.storedId,
                                          initialPosition: Offset(insert.x, insert.y),));
    });
  }

  /// Build menu
  ///
  ///
  _buildAnimatedMenu(List<Widget> buttons) {
    return AnimatedMenuWidget(backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
                              parentButtonBackground: Colors.redAccent,
                              orientation: AnimatedMenuOrientation.VERTICAL,
                              parentButton: Icon(Icons.settings),
                              hasBackground: false,
                              isLeft: false,
                              childButtons: buttons);
  }

}

class InheritedVisualFieldState extends InheritedWidget {
  InheritedVisualFieldState({
    Key key,
    @required this.documentsDirectory,
    @required this.background,
    @required this.inDebugMode,
    @required this.stackElements,
    @required this.animatedMenu,
    @required this.boardSettings,
    Widget child,
  }) : super (key: key, child: child);

  final String documentsDirectory;
  final Color background;
  final bool inDebugMode;
  final List<Widget> stackElements;
  final AnimatedMenuWidget animatedMenu;
  final BoardSettings boardSettings;

  @override
  bool updateShouldNotify(InheritedVisualFieldState oldWidget) {
    return inDebugMode != oldWidget.inDebugMode ||
           boardSettings.checkIsInSingleMode != oldWidget.boardSettings.checkIsInSingleMode ||
           boardSettings.checkIsAutoDeselecting != oldWidget.boardSettings.checkIsAutoDeselecting ||
           boardSettings.checkIsAutoSpeaking != oldWidget.boardSettings.checkIsAutoSpeaking;
  }

  static InheritedVisualFieldState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedVisualFieldState);
  }
}

class VisualFieldBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FieldBox();
  }
}

class FieldBox extends StatelessWidget {
  final defaultStyle = new TextStyle(color: Colors.black, 
                                     decoration: TextDecoration.none, 
                                     fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    final inheritedState = InheritedVisualFieldState.of(context);

    return Scaffold(body: 
                    Container(child: Stack(children: inheritedState.stackElements),
                              decoration: BoxDecoration(color: inheritedState.inDebugMode ? Colors.orangeAccent : Colors.blueAccent)),
                    floatingActionButton: inheritedState.inDebugMode ? inheritedState.animatedMenu : null,
                    primary: false,
                    resizeToAvoidBottomPadding: false,);  
  }
}