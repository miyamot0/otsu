/// Shawn Gilroy - 2018, MIT - Licensed
///
///

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
import '../Pages/FolderCreator.dart';
import '../Pages/IconCreator.dart';
import '../Storage/IconDatabase.dart';

class VisualFieldWidget extends StatefulWidget {

  VisualFieldWidget() : super(key: GlobalKey());

  @override
  VisualFieldWidgetState createState() => VisualFieldWidgetState();  
}

class VisualFieldWidgetState extends State<VisualFieldWidget> {
  bool inDebugMode = false;
  bool isInStartup = true;

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
    sentenceStripReference = StripObject(padding: 10.0);

    speakerObjectReference = SpeakerObject(emitSpeech, toggleDebugMode);
      stackElements.add(speakerObjectReference);

    loadFromDatabase();

    super.initState();
  }

  @override
  void dispose() {
    iconDb.close();

    super.dispose();
  }

  /// Load icons from database
  /// 
  /// 
  void loadFromDatabase() async {
    //print("loadFromDatabase()");
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
            launchEditor: triggerEditor,
            scale: icons[i].scale,
            defaultWidth: 200.0,
            moveToTop: moveIconToTop,
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
            launchEditor: triggerEditor,
            openFolderDialog: _navigateToFolderContentDialog,
            isInPlay: false,
            isPinnedToLocation: icons[i].pinned,
            scale: icons[i].scale,
            defaultWidth: 200.0,
            moveToTop: moveIconToTop,
            id: icons[i].id,
            initialPosition: Offset(
              icons[i].x, 
              icons[i].y),
            ),
          );
        }
      }
        
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

  /// Is there an intersection between a folder and an icon?
  /// 
  /// 
  Future<bool> _isIconOverlappingWithFolder(ReactiveIconWidget widget) async {
    //print("_isIconOverlappingWithFolder(ReactiveIconWidget widget)");

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
  void moveIconToTop(Widget widget) async {
    //print("VisualFieldWidget: moveIconToTop(TestIcon widget)");

    ReactiveIconWidget iconHolder;
    if (widget == null)
    {
      if (boardSettings.checkIsInSingleMode == true)
      {
        //print("VisualFieldWidget: moveIconToTop() == IsInSingleMode");

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
        //print("VisualFieldWidget: moveIconToTop() == In Frame Mode");

        for (var i = 0; i < stackElements.length; i++)
        {
          // Skip if not an icon
          if (!(stackElements[i] is ReactiveIconWidget)) continue;

          iconHolder = stackElements[i] as ReactiveIconWidget;

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
      //print("VisualFieldWidget: moveIconToTop() == IsInSingleMode");

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

      setState(() 
      {
        stackElements.remove(widget);
        stackElements.add(widget);
      });

      if (widget is ReactiveIconWidget)
      {
        widget.key.currentState.setState(() 
        {
          widget.key.currentState.isInPlay = true;
        });

        if (boardSettings.checkIsAutoSpeaking) 
        {
          emitSpeech();
        }
      }
    }
    else if (boardSettings.checkIsInSingleMode == false)
    {
      //print("VisualFieldWidget: moveIconToTop() == Is In Frame Mode");

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
    //print("_saveLatestStack() " + new DateTime.now().toString());

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
    else if (widget != null && widget is ReactiveFolderWidget)
    {
        if (widget.iconType == IconType.Folder)
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
          savedIcon.storedId  = -1;
          savedIcon.isFolder  = true;

          await iconDb.update(savedIcon);
        }
    }

    await iconDb.saveSettings(boardSettings);
  }

  /// Remove from stack
  /// 
  /// 
  void _removeFromDatabase(Widget widget) async {
    //print("_removeFromStack(Widget widget)");

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

  /// Build auto output button
  /// 
  /// 
  AnimatedMenuItem _buildAutoOutputModeButton() {
    return AnimatedMenuItem(
      labelText: boardSettings.checkIsAutoSpeaking == true ? "Change to Manual Mode" : "Change to Autospeak Mode",
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

            //print("autoSpeaking Delegate: Status = ${boardSettings.checkIsAutoSpeaking}");
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
    return AnimatedMenuItem(
      labelText: boardSettings.checkIsAutoDeselecting == true ? "Disable Auto-Deselect" : "Enable Auto-Deselect",
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

            //print("autoDeselect Delegate: Status = ${boardSettings.checkIsAutoDeselecting}");
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
    return AnimatedMenuItem(
      labelText: boardSettings.checkIsInSingleMode == true ? "Change to Frame Mode" : "Change to Icon Mode",
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

            //print("modeSelect Delegate: Status = ${boardSettings.checkIsInSingleMode}");

            moveIconToTop(null);
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

  /// Resume child interaction mode
  /// 
  /// This disables debug mode (hides buttons)
  void _resumeChildMode() async {
    //print('_resumeChildMode()');

    setState(() {
      inDebugMode = false;
    });

    if (boardSettings.checkIsInSingleMode == true) 
    {
      deselectAllIcons();
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
  void toggleDebugMode() {
    //print("toggleDebugMode()");

    setState(() {
      inDebugMode = true;
    });
  }

  /// Deselect all icons
  /// 
  /// 
  void deselectAllIcons() {

    // TODO strip
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
  void emitSpeech() async {
    //print("emitSpeech()");

    if (boardSettings.checkIsInSingleMode == true)
    {
      for (var x in stackElements) 
      {
        if (x is ReactiveIconWidget)
        {
          if (x.key.currentState.isInPlay)
          {
            await speakerObjectReference.speak(x.key.currentState.label);

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
    //print("_isWithinStrip");

    if (sentenceStripReference == null) return false;

    if (icon.key.currentState.currentPosition.dy > sentenceStripReference.key.currentState.stripSize.height) return false;

    if (icon.key.currentState.currentPosition.dx > sentenceStripReference.key.currentState.stripSize.width)  return false;

    return true;
  }

  /// Trigger editor for icons
  /// 
  /// 
  void triggerEditor(Widget widget) async {
    //print("_triggerIconEditor()");

    if (widget is ReactiveIconWidget)
    {
      String newName = await Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
              return DialogEditorIcon(widget, _removeFromDatabase, _saveLatestStack);
          }
      ));

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
          savedIcon.storedId  = widget.storedId;
          savedIcon.isFolder  = false;

          await iconDb.update(savedIcon);

          widget.key.currentState.setState(() {
            widget.key.currentState.label = newName;
          });
      }
    }

    if (widget is ReactiveFolderWidget)
    {
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
    }
  }

  /// Navigate to folder contents
  /// 
  /// 
  void _navigateToFolderContentDialog(ReactiveFolderWidget folderWidget) async {
    //print("_navigateToFolderContentDialog: ${folderWidget.key.currentState.label}");

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
  /// 
  /// 
  AlertDialog _buildFolderPopupDialog(ReactiveFolderWidget folderWidget, List<SavedIcon> storedIcons) {
    //print("_buildFolderPopupDialog, length = ${storedIcons.length}");

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
    //print("_restoreIconFromStorage(SavedIcon savedIcon)");

    savedIcon.isStored = false;
    savedIcon.storedId = -1;

    await iconDb.update(savedIcon);

    setState(()
    {
      stackElements.add(ReactiveIconWidget(label: savedIcon.iconName,
                                          iconType: IconType.Icon,
                                          assetPath: savedIcon.iconPath, 
                                          isInSingleMode: boardSettings.checkIsInSingleMode,
                                          isEmbbedded: savedIcon.embedded,
                                          isStored: savedIcon.isStored, 
                                          isInPlay: false,
                                          isPinnedToLocation: savedIcon.pinned,
                                          launchEditor: triggerEditor,
                                          scale: savedIcon.scale,
                                          defaultWidth: 200.0,
                                          moveToTop: moveIconToTop,
                                          id: savedIcon.id,
                                          storedId: savedIcon.storedId,
                                          initialPosition: Offset(savedIcon.x, savedIcon.y),)
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isInStartup == true)
    {
      isInStartup = false;

      Future.delayed(const Duration(seconds: 2)).then((_)
      {
        moveIconToTop(null);
      });
    }

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
    //print("toggleSentenceStrip(): ${boardSettings == null}");

    if (boardSettings == null) return;

    if (boardSettings.checkIsInSingleMode == true && stackElements.contains(sentenceStripReference))
    {
      //print("toggleSentenceStrip() remove strip");
      stackElements.remove(sentenceStripReference);
    }

    if (boardSettings.checkIsInSingleMode == false && !stackElements.contains(sentenceStripReference))
    {
      //print("toggleSentenceStrip() add strip");
      stackElements.insert(0, sentenceStripReference);
    }
  }

  /// Navigate to icon creator
  /// 
  /// 
  void _navigateToIconCreatorScreen(BuildContext context) async {
    //print("_navigateToIconCreatorScreen()");
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
                                          launchEditor: triggerEditor,
                                          scale: insert.scale,
                                          defaultWidth: 200.0,
                                          moveToTop: moveIconToTop,
                                          id: insert.id,
                                          storedId: insert.storedId,
                                          initialPosition: Offset(insert.x, insert.y),));
    });
  }

  /// Navigate to icon creator
  /// 
  /// 
  void _navigateToFolderCreatorScreen(BuildContext context) async {
    //print("_navigateToIconCreatorScreen()");
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
        launchEditor: triggerEditor,
        openFolderDialog: _navigateToFolderContentDialog,
        scale: insert.scale,
        defaultWidth: 200.0,
        moveToTop: moveIconToTop,
        id: insert.id,
        initialPosition: Offset(insert.x, insert.y),));
    });
  }

  /// Build menu
  ///
  ///
  AnimatedMenuWidget _buildAnimatedMenu(List<Widget> buttons) {
    return AnimatedMenuWidget(
      parentButton: Icon(Icons.settings),
      isLeft: false,
      childButtons: buttons
    );
  }
}

/// Inherited members for icons/folders lower in tree
/// 
/// 
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

/// Wrapper for stateless view of field
/// 
/// 
class VisualFieldBox extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FieldBox();
  }
}

/// Scaffold for visual field
/// 
/// 
class FieldBox extends StatelessWidget {
  static const defaultStyle = const TextStyle(
    color: Colors.black, 
    decoration: TextDecoration.none, 
    fontSize: 20.0);

  @override
  Widget build(BuildContext context) {
    final inheritedState = InheritedVisualFieldState.of(context);

    return Scaffold(
      body: Container(
        child: Stack(
          children: inheritedState.stackElements
        ),
        decoration: BoxDecoration(
          color: inheritedState.inDebugMode ? Colors.orangeAccent : Colors.blueAccent
          )
      ),
      floatingActionButton: inheritedState.inDebugMode ? inheritedState.animatedMenu : null,
      primary: false,
      resizeToAvoidBottomPadding: false,
    );  
  }
}