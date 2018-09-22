/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../Controls/AnimatedMenu.dart';
import '../Controls/VisualFieldBox.dart';
import '../Controls/ReactiveIconWidget.dart';
import '../Controls/ReactiveFolderWidget.dart';
import '../Controls/SpeakerObject.dart';
import '../Controls/StripObject.dart';

import '../Dialogs/DialogEditorIcon.dart';
import '../Dialogs/DialogEditorFolder.dart';

import '../InheritedWidgets/InheritedVisualFieldState.dart';

import '../Models/IconType.dart';
import '../Models/EmbeddedIconModel.dart';

import '../Pages/FolderCreator.dart';
import '../Pages/IconCreator.dart';

import '../Storage/IconDatabase.dart';

class VisualFieldWidget extends StatefulWidget {

  VisualFieldWidget() : super(key: GlobalKey());

  @override
  VisualFieldWidgetState createState() => VisualFieldWidgetState();
}

class VisualFieldWidgetState extends State<VisualFieldWidget> {
  bool inDebugMode = true;

  IconDatabase iconDb;  
  BoardSettings boardSettings;

  AnimatedMenuWidget animatedMenu;
  StripObject sentenceStripReference;
  SpeakerObject speakerObjectReference;

  Color background = Colors.orangeAccent;

  String dir;

  final stackElements = <Widget>[];
  final childButtons = List<AnimatedMenuItem>();

  @override
  void initState() {
    print("initState()");
    sentenceStripReference = StripObject(padding: 10.0);

    speakerObjectReference = SpeakerObject(_emitSpeech, _toggleDebugMode);
      stackElements.add(speakerObjectReference);

    _loadFromDatabase();

    super.initState();
  }

  @override
  void dispose() {
    print("dispose()");
    iconDb.close();

    super.dispose();
  }

  /// Load icons from database
  /// 
  /// 
  void _loadFromDatabase() async {
    print("loadFromDatabase()");
    dir = (await getApplicationDocumentsDirectory()).path;

    iconDb = new IconDatabase();
    await iconDb.open();

    boardSettings = await iconDb.loadSettings();

    if (boardSettings.checkIsInSingleMode == false) 
    {
      stackElements.add(sentenceStripReference);      
    }

    List<SavedIcon> icons = await iconDb.getSavedIcons();

    setState(() {
      for (var i = 0; i < icons.length; i++) {
        if (icons[i].isFolder == false)
        {
          if (icons[i].isStored == true) continue;
          
          stackElements.add(ReactiveIconWidget(
            label: icons[i].iconName,
            iconType: IconType.Icon,
            assetPath: icons[i].iconPath, 
            isInSingleMode: boardSettings.checkIsInSingleMode,
            isEmbbedded: icons[i].embedded,
            isStored: icons[i].isStored, 
            isInPlay: false,
            isPinnedToLocation: icons[i].pinned,
            launchEditor: _triggerEditor,
            scale: icons[i].scale,
            defaultWidth: 200.0,
            moveToTop: _moveIconToTop,
            id: icons[i].id,
            storedId: icons[i].storedId,
            initialPosition: Offset(
              icons[i].x, 
              icons[i].y),
            ),
          );
        }
        else
        {
          stackElements.add(ReactiveFolderWidget(
            label: icons[i].iconName,
            iconType: IconType.Folder,
            assetPath: icons[i].iconPath, 
            isInSingleMode: boardSettings.checkIsInSingleMode,
            isEmbbedded: icons[i].embedded,
            isStored: icons[i].isStored, 
            launchEditor: _triggerEditor,
            openFolderDialog: _navigateToFolderContentDialog,
            isInPlay: false,
            isPinnedToLocation: icons[i].pinned,
            scale: icons[i].scale,
            defaultWidth: 200.0,
            moveToTop: _moveIconToTop,
            id: icons[i].id,
            initialPosition: Offset(
              icons[i].x, 
              icons[i].y),
            ),
          );
        }
      }

      icons.clear();
      icons = null;

      speakerObjectReference.speak("").then((_) => print("TTS Module Loaded..."));
    });

    childButtons.clear();

    childButtons.add(_buildAddFolderButton());
    childButtons.add(_buildAddIconButton());
    childButtons.add(_buildSwitchModeButton());
    childButtons.add(_buildAutoOutputModeButton()); 
    childButtons.add(_buildAutoDeselectModeButton());      
    childButtons.add(_buildResumeChildModeButton()); 
  }

  @override
  Widget build(BuildContext context) {
    print("build(BuildContext context)");

    if (childButtons.length == 0)
    {
      print("childButtons.length == 0");

      childButtons.clear();
      childButtons.add(_buildAddFolderButton());
      childButtons.add(_buildAddIconButton());
      childButtons.add(_buildSwitchModeButton());
      childButtons.add(_buildAutoOutputModeButton()); 
      childButtons.add(_buildAutoDeselectModeButton());      
      childButtons.add(_buildResumeChildModeButton()); 

      animatedMenu = _buildAnimatedMenu(childButtons);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("WidgetsBinding.instance.addPostFrameCallback(_)");
      if (boardSettings != null && boardSettings.checkIsInSingleMode == false)
      {
        _moveIconToTop(null);
      }
    });
  
    _toggleSentenceStrip();
    
    return InheritedVisualFieldState(
      background: background,
      inDebugMode: inDebugMode,
      stackElements: stackElements,
      animatedMenu: animatedMenu,
      boardSettings: boardSettings,
      documentsDirectory: dir,
      boardSize: MediaQuery.of(context).size,
      child: VisualFieldBox(),
      key: GlobalKey(),
    );
  }

  /// Is there an intersection between a folder and an icon?
  /// 
  /// 
  Future<bool> _isIconOverlappingWithFolder(ReactiveIconWidget widget) async {
    print("_isIconOverlappingWithFolder(ReactiveIconWidget widget)");

    var folders =  stackElements.where((w) => w is ReactiveFolderWidget)
                                .where((w) => (w as ReactiveFolderWidget).key.currentState.defaultWidth != null)
                                .where((w) => (w as ReactiveFolderWidget).intersectsWith(widget.key.currentState.defaultWidth,
                                                                                         widget.key.currentState.scale,
                                                                                         widget.key.currentState.currentPosition))
                                .toList();   

    if (folders != null && folders.length > 0)
    {
        ReactiveFolderWidget droppableFolder = folders.first;

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

        //setState(() 
        //{
        //  stackElements.remove(widget);          
        //});

        widget.key.currentState.controller.reverse().then((err) {
        setState(() 
          {
            stackElements.remove(widget);          
          });
        });

        return true;
    }

    return false;
  }

  /// Move icons to top
  /// 
  /// 
  void _moveIconToTop(Widget widget) async {
    print("_moveIconToTop(TestIcon widget)");

    if (boardSettings == null) return;

    ReactiveIconWidget iconHolder;
    if (widget == null)
    {
      if (boardSettings.checkIsInSingleMode == true)
      {
        print("VisualFieldWidget: _moveIconToTop() == IsInSingleMode");

        for (var i = 0; i < stackElements.length; i++)
        {
          // Skip if not an icon
          if (!(stackElements[i] is ReactiveIconWidget)) continue;

          iconHolder = stackElements[i] as ReactiveIconWidget;

          iconHolder.key.currentState.setState(() 
          {
            iconHolder.key.currentState.isInPlay = false;
          });
        }
      }
      else
      {
        //print("VisualFieldWidget: _moveIconToTop() == In Frame Mode");

        for (var i = 0; i < stackElements.length; i++)
        {
          // Skip if not an icon
          if (!(stackElements[i] is ReactiveIconWidget)) continue;

          iconHolder = stackElements[i] as ReactiveIconWidget;

          if (iconHolder.key.currentState == null) continue;

          iconHolder.key.currentState.setState(() 
          {
              iconHolder.key.currentState.isInPlay = _isWithinStrip(iconHolder);
          });
        }
      }

      return;
    }


    // Is the icon at the top of the stack overlapping with a folder?
    if (widget is ReactiveIconWidget && await _isIconOverlappingWithFolder(widget) == true)
    {
        return;
    }

    if (boardSettings.checkIsInSingleMode == true)
    {
      print("VisualFieldWidget: _moveIconToTop() == IsInSingleMode");

      for (var i = 0; i < stackElements.length; i++)
      {
        // Skip if not an icon
        if (!(stackElements[i] is ReactiveIconWidget)) continue;

        iconHolder = stackElements[i] as ReactiveIconWidget;

        if (iconHolder != widget && iconHolder.key.currentState.isInPlay == true)
        {
          iconHolder.key.currentState.setState(() 
          {
            iconHolder.key.currentState.isInPlay = false;
          });
        }
      }

      if (widget is ReactiveIconWidget)
      {
        widget.key.currentState.setState(() 
        {
          widget.key.currentState.isInPlay = true;
        });

        if (boardSettings.checkIsAutoSpeaking == true) 
        {
          _emitSpeech();
        }
      }

      setState(() 
      {
        stackElements.remove(widget);
        stackElements.add(widget);
      });
    }
    else if (boardSettings.checkIsInSingleMode == false)
    {
      //print("VisualFieldWidget: _moveIconToTop() == Is In Frame Mode");

      for (var i = 0; i < stackElements.length; i++)
      {
        // Skip if not an icon
        if (!(stackElements[i] is ReactiveIconWidget)) continue;

        iconHolder = stackElements[i] as ReactiveIconWidget;

        iconHolder.key.currentState.setState(() 
        {
            iconHolder.key.currentState.isInPlay = _isWithinStrip(iconHolder);

            //print("Icon ${iconHolder.key.currentState.label} status = ${iconHolder.key.currentState.isInPlay}");
        });
      }

      setState(() 
      {
        stackElements.remove(widget);
        stackElements.add(widget);
      });    
    }

    _saveLatestStack(widget);
  }

  /// Save the most recent widget
  /// 
  /// 
  void _saveLatestStack(Widget widget) async {
    print("_saveLatestStack() " + new DateTime.now().toString());

    if (iconDb == null) return;

    if (widget != null && widget is ReactiveIconWidget)
    {
      SavedIcon savedIcon = SavedIcon();
      savedIcon.id        = widget.id;
      savedIcon.iconName  = widget.key.currentState.label;
      savedIcon.iconPath  = widget.key.currentState.assetPath;
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
    else if (widget != null && widget is ReactiveFolderWidget)
    {
      SavedIcon savedIcon = SavedIcon();
      savedIcon.id        = widget.id;
      savedIcon.iconName  = widget.key.currentState.label;
      savedIcon.iconPath  = widget.key.currentState.assetPath;
      savedIcon.x         = widget.key.currentState.currentPosition.dx;
      savedIcon.y         = widget.key.currentState.currentPosition.dy;
      savedIcon.embedded  = widget.key.currentState.isEmbbedded;
      savedIcon.pinned    = widget.key.currentState.isPinnedToLocation;
      savedIcon.scale     = widget.key.currentState.scale;
      savedIcon.active    = widget.key.currentState.isInPlay;
      savedIcon.isStored  = widget.key.currentState.isStored;
      savedIcon.storedId  = -1;
      savedIcon.isFolder  = true;

      await iconDb.update(savedIcon);
    }

    await iconDb.saveSettings(boardSettings);
  }

  /// Remove from stack
  /// 
  /// 
  void _removeFromDatabase(Widget widget) async {
    print("_removeFromStack(Widget widget)");

    if (widget is ReactiveIconWidget)
    {
      await iconDb.delete(widget.id);

      setState(() 
      {
        stackElements.remove(widget);
      });
    }

    if (widget is ReactiveFolderWidget)
    {
       await iconDb.deleteFolder(widget.id);

      setState(() 
      {
        stackElements.remove(widget);
      });
    }
  }

  /// Resume child interaction mode
  /// 
  /// This disables debug mode (hides buttons)
  void _resumeChildMode() async {
    print('_resumeChildMode()');

    setState(() {
      inDebugMode = false;
    });

    if (boardSettings.checkIsInSingleMode == true) 
    {
      _deselectAllIcons();
    }
    else 
    {
      for (var i = 0; i < stackElements.length; i++)
      {
        if (stackElements[i] is ReactiveIconWidget)
        {
          (stackElements[i] as ReactiveIconWidget).key.currentState.setState(() 
          {
            (stackElements[i] as ReactiveIconWidget).key.currentState.isInPlay = _isWithinStrip((stackElements[i] as ReactiveIconWidget));
          });
        }
      }
    }

    await iconDb.saveSettings(boardSettings);
  }

  /// Toggle debug mode
  /// 
  /// 
  void _toggleDebugMode() {
    print("_toggleDebugMode()");

    setState(() {
      inDebugMode = true;
    });
  }

  /// Deselect all icons
  /// 
  /// 
  void _deselectAllIcons() {
    print('_deselectAllIcons');

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

  /// Emit speech
  /// 
  /// 
  void _emitSpeech() async {
    print("_emitSpeech()");

    if (boardSettings.checkIsInSingleMode == true)
    {
      print("boardSettings.checkIsInSingleMode == true");

      for (var x in stackElements) 
      {
        if (x is ReactiveIconWidget)
        {
          if (x.key.currentState.isInPlay == true)
          {
            //print('boardSettings.checkIsAutoDeselecting: ${boardSettings.checkIsAutoDeselecting}');

            if (boardSettings.checkIsAutoDeselecting == true || boardSettings.checkIsAutoSpeaking == true)
            {
              //print('boardSettings.checkIsAutoDeselecting == true');
              _deselectAllIcons();
            }

            await speakerObjectReference.speak(x.key.currentState.label);
          }
        }
      }
    }
    else
    {
      print("boardSettings.checkIsInSingleMode == false");

      var tempList = <ReactiveIconWidget>[];
      var outputString = "";

      for (var x in stackElements) 
        if (x is ReactiveIconWidget && x.key.currentState.isInPlay) tempList.add(x);

      if (tempList.length > 0)
      {
        tempList.sort((a, b) => a.key.currentState.currentPosition.dx.compareTo(b.key.currentState.currentPosition.dx));

        for (var icon in tempList)
          outputString = outputString + " " + icon.key.currentState.label;
        
        await speakerObjectReference.speak(outputString);
      }
    }
  }

  /// Check if icon is within strip, in framed mode
  /// 
  /// 
  bool _isWithinStrip(ReactiveIconWidget icon) {
    print("_isWithinStrip(ReactiveIconWidget icon)");

    if (sentenceStripReference == null || 
        sentenceStripReference.key.currentState == null ||
        sentenceStripReference.key.currentState.stripSize == null) return false;

    if (icon.key.currentState.currentPosition.dy > sentenceStripReference.key.currentState.stripSize.height) return false;

    if (icon.key.currentState.currentPosition.dx > sentenceStripReference.key.currentState.stripSize.width)  return false;

    return true;
  }

  /// Trigger editor for icons
  /// 
  /// 
  void _triggerEditor(Widget widget) async {
    print("_triggerEditor(Widget widget)");

    if (widget is ReactiveIconWidget)
    {
      var res = await showDialog(
        context: context,
        barrierDismissible: true,
        
        builder: (BuildContext context) {
          return DialogEditorIcon(widget, _removeFromDatabase, _saveLatestStack);
        },
      );

      print("res: $res");
    }

    // TODO: 
    if (widget is ReactiveFolderWidget)
    {
      showDialog(
        context: context,
        barrierDismissible: true,
        
        builder: (BuildContext context) {
          return DialogEditorFolder(widget, _removeFromDatabase, _saveLatestStack);
        },
      );

      /*
      //debugPrint("_triggerIconEditor()");
      
      String newName = await Navigator.of(context).push(
        PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
              return DialogEditorFolder(widget, _removeFromDatabase, _saveLatestStack);
          }
        )
      );

      if (newName != null)
      {
          SavedIcon savedIcon = SavedIcon();
          savedIcon.id        = widget.id;
          savedIcon.iconName  = newName;
          savedIcon.iconPath  = widget.assetPath;
          savedIcon.x         = widget.key.currentState.currentPosition.dx;
          savedIcon.y         = widget.key.currentState.currentPosition.dy;
          savedIcon.embedded  = widget.key.currentState.isEmbbedded;
          savedIcon.pinned    = widget.key.currentState.isPinnedToLocation;
          savedIcon.scale     = widget.key.currentState.scale;
          savedIcon.active    = widget.key.currentState.isInPlay;
          savedIcon.isStored  = widget.key.currentState.isStored;
          savedIcon.storedId  = -1;
          savedIcon.isFolder  = true;

          await iconDb.update(savedIcon);

          widget.key.currentState.setState(() {
            widget.key.currentState.label = newName;
          });
      }
      */
    }
  }

  /// Navigate to folder contents
  /// 
  /// 
  void _navigateToFolderContentDialog(ReactiveFolderWidget folderWidget) async {
    print("_navigateToFolderContentDialog: ${folderWidget.key.currentState.label}");

    var storedIcons = await iconDb.getStoredIcons(folderWidget.id);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _buildFolderPopupDialog(folderWidget, storedIcons);
      },
    );
  }

  /*

  /// Show startup
  /// 
  /// 
  AlertDialog _showStartupWindow() {
    return AlertDialog(
      title: Center(
        child: Text(
          "Project Name: Otsu (Version 0.1)"
        ),
      ),
      content: Container(
        child: Wrap(
          alignment: WrapAlignment.start,
          children: <Widget> [
            Text(
              "This application is designed to be used alongside function-based communication training. The application provides Icon- (single icon output) and Frame-based output (sentence strip output). The board begins empty, but you can access the necessary settings for holding the SPEAKER for ~5 seconds. Once in this mode you may edit settings, add or adjust icons, and even change the nature of the communication response.",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontStyle: FontStyle.normal,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      width: 500.0,
      height: 500.0,
      ),
    );
  }

  */

  /// TODO: assign size (square, based on %age height)
  /// 
  /// 
  AlertDialog _buildFolderPopupDialog(ReactiveFolderWidget folderWidget, List<SavedIcon> storedIcons) {
    print("_buildFolderPopupDialog, length = ${storedIcons.length}");

    List<Container> imgs = [];

    for (SavedIcon storedIcon in storedIcons)
    {
      imgs.add(new Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black, 
            width: 1.0,
          ),
          color: Colors.white,
        ),
        child: GestureDetector(
          child: new Image.asset(
            storedIcon.iconPath
          ),
          onTap: () 
          {
            _restoreIconFromStorage(storedIcon);
            Navigator.pop(context);
          },
        ),
      ));
    }

    return AlertDialog(
      title: Center(
        child: Text(
          folderWidget.key.currentState.label
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
        ),
      width: 500.0,
      height: 500.0,
      ),
    );
  }

  /// Restore image from storage
  /// 
  /// 
  void _restoreIconFromStorage(SavedIcon savedIcon) async {
    print("_restoreIconFromStorage(SavedIcon savedIcon)");

    savedIcon.isStored = false;
    savedIcon.storedId = -1;

    await iconDb.update(savedIcon);

    setState(()
    {
      stackElements.add(ReactiveIconWidget(
        label: savedIcon.iconName,
        iconType: IconType.Icon,
        assetPath: savedIcon.iconPath, 
        isInSingleMode: boardSettings.checkIsInSingleMode,
        isEmbbedded: savedIcon.embedded,
        isStored: savedIcon.isStored, 
        isInPlay: false,
        isPinnedToLocation: savedIcon.pinned,
        launchEditor: _triggerEditor,
        scale: savedIcon.scale,
        defaultWidth: 200.0,
        moveToTop: _moveIconToTop,
        id: savedIcon.id,
        storedId: savedIcon.storedId,
        initialPosition: Offset(
          savedIcon.x, 
          savedIcon.y,
          ),
        ),
      );
    });
  }

  /// Toggle visibility of strip
  /// 
  /// 
  void _toggleSentenceStrip() {
    print("_toggleSentenceStrip(): ${boardSettings == null}");

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

  /// Navigate to icon creator
  /// 
  /// 
  void _navigateToIconCreatorScreen(BuildContext context) async {
    print("_navigateToIconCreatorScreen()");
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
      stackElements.add(ReactiveIconWidget(
        label: insert.iconName,
        iconType: IconType.Icon,
        assetPath: insert.iconPath, 
        isInSingleMode: boardSettings.checkIsInSingleMode,
        isEmbbedded: insert.embedded,
        isStored: insert.isStored, 
        isInPlay: false,
        isPinnedToLocation: insert.pinned,
        launchEditor: _triggerEditor,
        scale: insert.scale,
        defaultWidth: 200.0,
        moveToTop: _moveIconToTop,
        id: insert.id,
        storedId: insert.storedId,
        initialPosition: Offset(
          insert.x, 
          insert.y,
          ),
        ),
      );
    });
  }

  /// Navigate to icon creator
  /// 
  /// 
  void _navigateToFolderCreatorScreen(BuildContext context) async {
    print("_navigateToIconCreatorScreen()");
    EmbeddedIconModel result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FolderCreatorScreen(dir)));

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
    savedIcon.isFolder  = true;

    SavedIcon insert = await iconDb.insert(savedIcon);

    setState(() 
    {
      stackElements.add(ReactiveFolderWidget(
        label: insert.iconName,
        iconType: IconType.Folder,
        assetPath: insert.iconPath,
        isInSingleMode: boardSettings.checkIsInSingleMode,
        isEmbbedded: insert.embedded,
        isStored: insert.isStored,
        isInPlay: false,
        isPinnedToLocation: insert.pinned,
        launchEditor: _triggerEditor,
        openFolderDialog: _navigateToFolderContentDialog,
        scale: insert.scale,
        defaultWidth: 200.0,
        moveToTop: _moveIconToTop,
        id: insert.id,
        initialPosition: Offset(insert.x, insert.y),));
    });
  }

  /// Build auto output button
  /// 
  /// 
  AnimatedMenuItem _buildAutoOutputModeButton() {
    print('_buildAutoOutputModeButton()');

    return AnimatedMenuItem(
      labelText: (boardSettings == null || boardSettings.checkIsAutoSpeaking == true) ? "Change to Manual Mode" : "Change to Autospeak Mode",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        heroTag: "autoTag",
        mini: false,
        child: Icon(Icons.volume_up),
        onPressed: () async 
        {
          setState(() 
          {
            boardSettings.checkIsAutoSpeaking = !boardSettings.checkIsAutoSpeaking;
          });

          await iconDb.saveSettings(boardSettings);
        },
      )
    );
  }

  /// Build auto deselect button
  /// 
  /// 
  AnimatedMenuItem _buildAutoDeselectModeButton() {
    print('_buildAutoDeselectModeButton()');

    return AnimatedMenuItem(
      labelText: (boardSettings == null || boardSettings.checkIsAutoDeselecting == true) ? "Disable Auto-Deselect" : "Enable Auto-Deselect",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.red,
        heroTag: "deselectTag",
        mini: false,
        child: Icon(Icons.fingerprint),
        onPressed: () async 
        {
          setState(() 
          {
            boardSettings.checkIsAutoDeselecting = !boardSettings.checkIsAutoDeselecting;   
          });

          await iconDb.saveSettings(boardSettings);
        },
      )
    );
  }

  /// Build switch button
  ///
  ///
  AnimatedMenuItem _buildSwitchModeButton() {
    print('_buildSwitchModeButton()');

    return AnimatedMenuItem(
      labelText: (boardSettings == null || boardSettings.checkIsInSingleMode == true) ? "Change to Frame Mode" : "Change to Icon Mode",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        heroTag: "frameTag",
        mini: false,
        child: Icon(Icons.border_all),
        onPressed: () async 
        {
          setState(() 
          {
            boardSettings.checkIsInSingleMode = !boardSettings.checkIsInSingleMode;
            _moveIconToTop(null);
          });

          await iconDb.saveSettings(boardSettings);
        },
      )
    );
  }

  /// Build resume button
  ///
  ///
  AnimatedMenuItem _buildResumeChildModeButton() {
    print('_buildResumeChildModeButton()');

    return AnimatedMenuItem(
      labelText: "Resume Child Mode",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        heroTag: "resumeTag",
        mini: false,
        child: Icon(Icons.play_arrow),
        onPressed: () async {
          _resumeChildMode();

          await iconDb.saveSettings(boardSettings);
        }
      )
    );
  }

  /// Build icon button 
  ///
  ///
  AnimatedMenuItem _buildAddFolderButton() {
    print('_buildAddFolderButton()');

    return AnimatedMenuItem(
      labelText: "Add a Folder",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        heroTag: "addFolderTag",
        mini: false,
        child: Icon(Icons.folder_open),
        onPressed: () => _navigateToFolderCreatorScreen(context),
      ),
    );
  }

  /// Build icon button 
  ///
  ///
  AnimatedMenuItem _buildAddIconButton() {
    print('_buildAddIconButton()');

    return AnimatedMenuItem(
      labelText: "Add an Icon",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: "addIconTag",
        mini: false,
        child: Icon(Icons.add_a_photo),
        onPressed: () => _navigateToIconCreatorScreen(context),
      ),
    );
  }

  /// Build menu
  ///
  ///
  AnimatedMenuWidget _buildAnimatedMenu(List<Widget> buttons) {
    print('_buildAnimatedMenu()');

    return AnimatedMenuWidget(
      parentButton: Icon(Icons.settings),
      isLeft: false,
      childButtons: buttons
    );
  }
}


