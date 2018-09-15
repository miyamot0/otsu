import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'IconWidget.dart';
import 'FolderWidget.dart';
import 'StripObject.dart';
import 'SpeakerObject.dart';
import 'AnimatedMenu.dart';

import '../Pages/IconCreator.dart';
import '../Models/EmbeddedIconModel.dart';
import '../Storage/IconDatabase.dart';
import '../Models/IconType.dart';

import '../Dialogs/DialogEditorIcon.dart';
import '../Dialogs/DialogEditorFolder.dart';

final bool outputToTerminal = true;

class VisualField extends StatefulWidget {

  @override
  VisualFieldState createState() => VisualFieldState();
}

class InheritedFieldState extends InheritedWidget {
  InheritedFieldState({
    Key key,
    this.background,
    this.inDebugMode,
    Widget child,
  }) : super (key: key, child: child);

  final Color background;
  final bool inDebugMode;

  @override
  bool updateShouldNotify(InheritedFieldState oldWidget) {
    return inDebugMode != oldWidget.inDebugMode;
  }

  static InheritedFieldState of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(InheritedFieldState);
  }
}

class VisualFieldState extends State<VisualField> {
  AnimatedMenuWidget animatedMenu;

  Color background = Colors.lightBlueAccent; 

  final _stackElements = <Widget>[];
  final childButtons = List<AnimatedMenuItem>();

  // Hack
  bool inDebugMode = true;

  StripObject sentenceStripReference;
  SpeakerObject speakerObjectReference;

  IconDatabase iconDb;

  String dir;

  BoardSettings boardSettings = BoardSettings(checkIsInSingleMode:    true, 
                                              checkIsAutoDeselecting: false, 
                                              checkIsAutoSpeaking:    false);

  bool triggerOnFirstLoad = true;

  @override
  void initState() {
    super.initState();

    _loadIcons();
  }

  @override
  void dispose() {
    super.dispose();

    iconDb.close();
  }

  /// Load icons from db
  /// 
  /// 
  _loadIcons() async {
      sentenceStripReference = StripObject(padding: 10.0);
      speakerObjectReference = SpeakerObject(_emitSpeech, _toggleDebug);

      dir = (await getApplicationDocumentsDirectory()).path;

      iconDb = new IconDatabase();
      await iconDb.open();

      boardSettings = await iconDb.loadSettings();

      List<SavedIcon> icons = await iconDb.getSavedIcons();

      setState(()
      {
        _stackElements.clear();

        _stackElements.add(sentenceStripReference);
        _stackElements.add(speakerObjectReference);              

        IconWidget holder;
        FolderWidget folderHolder;

        for (int i = 0; i < icons.length; i++)
        {
            // HACK
            if (icons[i].isFolder)
            {
              folderHolder = FolderWidget(text: icons[i].iconName, 
                                        initialOffset: new Offset(icons[i].x.toDouble(), icons[i].y.toDouble()), 
                                        assetPath: icons[i].iconPath, 
                                        repositionCallback: _bringToTop,
                                        deleteCallback: _removeFromDatabase,
                                        editCallback: _triggerFolderEditor,
                                        openDialogCallback: _navigateToFolderContentDialog,                                        
                                        showEditOptions: inDebugMode ? true : false,
                                        isPinned: icons[i].pinned,
                                        isEmbbedded: icons[i].embedded,
                                        scale: icons[i].scale,
                                        documentsFolder: dir,
                                        inPlay: icons[i].active,
                                        isInSingleMode: boardSettings.checkIsInSingleMode,
                                        id: icons[i].id,);

              _stackElements.add(folderHolder);
            }
            else
            {
              if (icons[i].isStored == false)
              {
                holder = IconWidget(text: icons[i].iconName, 
                                          initialOffset: new Offset(icons[i].x.toDouble(), icons[i].y.toDouble()), 
                                          assetPath: icons[i].iconPath, 
                                          repositionCallback: _bringToTop,
                                          deleteCallback: _removeFromDatabase,
                                          editCallback: _triggerIconEditor,
                                          showEditOptions: inDebugMode ? true : false,
                                          isPinned: icons[i].pinned,
                                          isEmbbedded: icons[i].embedded,
                                          scale: icons[i].scale,
                                          documentsFolder: dir,
                                          inPlay: icons[i].active,
                                          isInSingleMode: boardSettings.checkIsInSingleMode,
                                          id: icons[i].id,
                                          isStored: icons[i].isStored,
                                          storedId: icons[i].storedId,);

                holder.background = holder.inPlay ? Colors.greenAccent : Colors.white;                                          

                _stackElements.add(holder);

              }
            }            
        }

        background = (!inDebugMode) ? Colors.lightBlueAccent : Colors.orange;

        childButtons.add(_buildAddFolderButton());
        childButtons.add(_buildAddIconButton());
        childButtons.add(_buildSwitchModeButton());
        childButtons.add(_buildAutoOutputModeButton()); 
        childButtons.add(_buildAutoDeselectModeButton());      
        childButtons.add(_buildResumeChildModeButton()); 
      
        animatedMenu = _buildAnimatedMenu(childButtons);
        
        speakerObjectReference.speak("").then((_) => debugPrint("TTS Module Loaded..."));
      });
  }

  Widget build(BuildContext context) {
    _checkAndHandleSentenceStrip();

    return Scaffold(body: 
                    Container(child: Stack(children: _stackElements),
                              decoration: BoxDecoration(color: background)),
                    floatingActionButton: inDebugMode ? animatedMenu : null,
                    primary: false,
                    resizeToAvoidBottomPadding: false,);  
  }

  /// Interface updates on changes in mode
  ///
  ///
  _checkAndHandleSentenceStrip() {
    debugPrint("_checkAndHandleSentenceStrip(): ${boardSettings == null}");

    if (boardSettings == null) return;

    if (boardSettings.checkIsInSingleMode == true && _stackElements.contains(sentenceStripReference))
    {
      _stackElements.remove(sentenceStripReference);
    }

    if (boardSettings.checkIsInSingleMode == false && !_stackElements.contains(sentenceStripReference))
    {
      _stackElements.insert(0, sentenceStripReference);
    }

    if (triggerOnFirstLoad == true)
    {
      IconWidget holder;

      for (int i = 0; i < _stackElements.length; i++)
      {
          if (!(_stackElements[i] is IconWidget)) continue;

          holder = _stackElements[i] as IconWidget;

          if (boardSettings.checkIsInSingleMode == false)
          {
            (_stackElements[i] as IconWidget).state.setActive(_isWithinStrip(holder), force: true);
          }
      }

      triggerOnFirstLoad = false;
    }
    
  }

  /// Rebuild menu
  /// 
  /// 
  _rebuildMenus() {    
    setState(() {
      animatedMenu.childButtons[2].labelText = boardSettings.checkIsInSingleMode == true ? "Change to Frame Mode" : "Change to Icon Mode";
      animatedMenu.childButtons[3].labelText = boardSettings.checkIsAutoSpeaking == true ? "Change to Manual Mode" : "Change to Autospeak Mode";
      animatedMenu.childButtons[4].labelText = boardSettings.checkIsAutoDeselecting == true ? "Disable Auto-Deselect" : "Enable Auto-Deselect";

      animatedMenu.updateState();
    });
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

                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);

                _rebuildMenus();
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

                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);

                _rebuildMenus();
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

                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);

                _rebuildMenus();
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

              FolderWidget holder2 = FolderWidget(text: savedIcon.iconName, 
                                                  initialOffset: new Offset(savedIcon.x, savedIcon.y), 
                                                  assetPath: savedIcon.iconPath, 
                                                  repositionCallback: _bringToTop,
                                                  deleteCallback: _removeFromDatabase,
                                                  editCallback: _triggerFolderEditor,
                                                  openDialogCallback: _navigateToFolderContentDialog,
                                                  showEditOptions: inDebugMode ? true : false,
                                                  isPinned: false,
                                                  isEmbbedded: true,
                                                  scale: 1.0,
                                                  documentsFolder: dir,
                                                  inPlay: false,
                                                  id: insert.id);

              setState(() {
                _stackElements.add(holder2);                              
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

  /// Deselect the icons individually, for single icon mode
  /// 
  /// 
  _renderSingleIconsUnselected() {
    setState(()
    {
      for (int i = 0; i < _stackElements.length; i++)
      {
          if (!(_stackElements[i] is IconWidget)) continue;

          (_stackElements[i] as IconWidget).state.setActive(false);
      }
    });    
  }

  /// Collect relevant icons in the speech frame
  /// 
  /// TODO: single icon mode
  _emitSpeech() async {
    debugPrint("_emitSpeech() " + new DateTime.now().toString());

    if (boardSettings.checkIsInSingleMode == true)
    {
      for (var x in _stackElements) 
      {
        if (x is IconWidget)
        {
          if (x.inPlay)
          {
            await speakerObjectReference.speak(x.text);

            if (boardSettings.checkIsAutoDeselecting == true)
            {
              _renderSingleIconsUnselected();   
            }
          }
        }
      }
    }
    else
    {
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
    }    
  }

  /// Resume child interaction mode
  /// 
  /// This disables debug mode (hides buttons)
  _resumeChildMode() {
    setState(() {
      inDebugMode = false;
      background = Colors.lightBlueAccent;

      for (int i = 0; i < _stackElements.length; i++)
      {
          if (_stackElements[i] is IconWidget)
          {
            (_stackElements[i] as IconWidget).state.setEditing(false);
          }
          else if (_stackElements[i] is FolderWidget)
          {
            (_stackElements[i] as FolderWidget).state.setEditing(false);
          }
      }

      _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
    });
  }

  /// Toggle the debug mode
  /// 
  /// Changes the screen color, sets a flag indicating debug
  /// 
  _toggleDebug() {
    debugPrint("_toggleDebug()");

    setState(() 
    {
      inDebugMode = !inDebugMode;
      background = (!inDebugMode) ? Colors.lightBlueAccent : Colors.orangeAccent;

      for (int i = 0; i < _stackElements.length; i++)
      {
          if (_stackElements[i] is IconWidget)
          {
            (_stackElements[i] as IconWidget).state.setEditing(true);
          }
          else if (_stackElements[i] is FolderWidget)
          {
            (_stackElements[i] as FolderWidget).state.setEditing(true);
          }
      }
    });
  }

  /// Remove from stack
  /// 
  /// 
  _removeFromDatabase(Widget widget) async {
    debugPrint("_removeFromStack(Widget widget)");

    if (widget is IconWidget)
    {
      await iconDb.delete(widget.id);
    }

    if (widget is FolderWidget)
    {
       await iconDb.deleteFolder(widget.id);
    }

    setState(() {
      _stackElements.remove(widget);
    });
  }

  /// Route bx into single icon actions
  /// 
  /// 
  _routeSingleIconMode(Widget widget) async {
    if (!(widget is IconWidget)) return;

    debugPrint("_bringToTop: Single Mode");
    
    
    
    for (var x in _stackElements)
    {
      if (x is IconWidget)
      {
         x.state.setActive(false);
      }
    }

    if (widget is IconWidget)
    {
      if (boardSettings.checkIsAutoSpeaking == true)
      {
        widget.state.setActive(false);

        await speakerObjectReference.speak(widget.text);
      }
      else if (boardSettings.checkIsAutoSpeaking == false)
      {
        widget.state.setActive(true);
      }
      
      _stackElements.remove(widget);
      _stackElements.add(widget);
    }
  }

  /// Route bx into framed actions
  /// 
  /// 
  _routeFramedIconMode(Widget widget) {
    debugPrint("_routeFramedIconMode");

    _stackElements.remove(widget);
    _stackElements.add(widget);

    for (var x in _stackElements) 
    {
      if (x is IconWidget)
      {
        x.state.setActive(_isWithinStrip(x));
      }
    }
  }

  /// Trigger edit dialog
  /// 
  /// 
  _triggerIconEditor(IconWidget widget) {
      debugPrint("_triggerIconEditor()");
      
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
              return DialogEditorIcon(widget);
          }
      ));
  }

  /// Trigger edit dialog
  /// 
  /// 
  _triggerFolderEditor(FolderWidget widget) {
      debugPrint("_triggerFolderEditor()");
      
      Navigator.of(context).push(PageRouteBuilder(
          opaque: false,
          pageBuilder: (BuildContext context, _, __) {
              return DialogEditorFolder(widget);
          }
      ));
  }

  /// Bring up in the stack
  ///
  ///
  _bringToTop(Widget widget) async {
    debugPrint("_bringToTop()");

    setState(() 
    {
      if (boardSettings.checkIsInSingleMode == true)
        _routeSingleIconMode(widget);
      else 
        _routeFramedIconMode(widget);
    });

    _refreshIconSelections();

    // Is the icon at the top of the stack overlapping with a folder?
    if (widget is IconWidget)
    {
      if (await _isIconOverlappingWithFolder(widget) == true) 
        return;

      _saveLatestStack(widget);
    }
    else
    {
      _saveLatestStack(widget);
    }
  }

  // TODO
  // Stub, need an "intersect method"
  Future<bool> _isIconOverlappingWithFolder(IconWidget widget) async {
    debugPrint("_isIconOverlappingWithFolder()");

    var folders = _stackElements.where((w) => w is FolderWidget)
                                .where((w) => (w as FolderWidget).state.defaultSize != null)
                                .where((w) => (w as FolderWidget).intersectsWith(widget.state.defaultSize, widget.currentPosition))
                                .toList();   

    if (folders != null && folders.length > 0)
    {
        FolderWidget droppableFolder = folders.first;
        debugPrint("DROP: folder.text = ${droppableFolder.text} folder.id = ${droppableFolder.id} ");

        SavedIcon savedIcon = SavedIcon();
        savedIcon.id        = widget.id;
        savedIcon.iconName  = widget.text;
        savedIcon.iconPath  = widget.assetPath;
        savedIcon.x         = widget.currentPosition.dx;
        savedIcon.y         = widget.currentPosition.dy;
        savedIcon.embedded  = widget.isEmbbedded;
        savedIcon.pinned    = widget.isPinned;
        savedIcon.scale     = widget.scale;
        savedIcon.active    = widget.inPlay;
        savedIcon.isStored  = true;
        savedIcon.storedId  = droppableFolder.id;
        savedIcon.isFolder  = false;

        await iconDb.update(savedIcon);

        setState(() {
          _stackElements.remove(widget);          
        });

        return true;
    }

    debugPrint("_isIconOverlappingWithFolder() == FALSE");

    return false;
  }

  /// Determine if widget fits in the strip
  ///
  /// icon: IconWidget
  _isWithinStrip(IconWidget icon) {
    debugPrint("_isWithinStrip");

    if (sentenceStripReference.stripSize == null) return false;

    if (icon.currentPosition.dy > (sentenceStripReference.stripSize.height + 
                                   sentenceStripReference.padding)) return false;

    if (icon.currentPosition.dx > (sentenceStripReference.stripSize.width + 
                                   sentenceStripReference.padding)) return false;
    return true;
  }

  /// Navigate to the icon creation screen
  /// 
  /// Create icon from either camera or pictures, handle all that business on that screen.
  ///
  /// Return: Text/Path pair for adding to the board
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

    IconWidget holder;

    setState(() 
    {
      holder = IconWidget(text: result.iconText,  
                                initialOffset: new Offset(savedIcon.x, savedIcon.y), 
                                assetPath: savedIcon.iconPath, 
                                repositionCallback: _bringToTop,
                                deleteCallback: _removeFromDatabase,
                                showEditOptions: inDebugMode,
                                editCallback: _triggerIconEditor,
                                scale: savedIcon.scale,
                                isPinned: savedIcon.pinned,
                                isEmbbedded: savedIcon.embedded,
                                documentsFolder: dir,
                                inPlay: false,
                                isInSingleMode: boardSettings.checkIsInSingleMode,
                                id: insert.id,
                                storedId: savedIcon.storedId,);
      
      _stackElements.add(holder);
    });

    //_refreshIconSelections();
  }

  /// Navigate to folder contents
  _navigateToFolderContentDialog(FolderWidget folderWidget) async {
    debugPrint("_navigateToFolderContentDialog: ${folderWidget.text}");

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
  AlertDialog _buildFolderPopupDialog(FolderWidget folderWidget, List<SavedIcon> storedIcons) {
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

    return AlertDialog(title: Center(child: Text(folderWidget.text)),
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

    IconWidget holder = IconWidget(text: savedIcon.iconName, 
                              initialOffset: new Offset(savedIcon.x.toDouble(), savedIcon.y.toDouble()), 
                              assetPath: savedIcon.iconPath, 
                              repositionCallback: _bringToTop,
                              deleteCallback: _removeFromDatabase,
                              editCallback: _triggerIconEditor,
                              showEditOptions: inDebugMode ? true : false,
                              isPinned: savedIcon.pinned,
                              isEmbbedded: savedIcon.embedded,
                              scale: savedIcon.scale,
                              documentsFolder: dir,
                              inPlay: savedIcon.active,
                              isInSingleMode: boardSettings.checkIsInSingleMode,
                              id: savedIcon.id,
                              isStored: savedIcon.isStored,
                              storedId: savedIcon.storedId,);

    holder.background = holder.inPlay ? Colors.greenAccent : Colors.white;

    setState(() {
      _stackElements.add(holder);              
    });
  }

  /// Refresh the UI
  /// 
  /// 
  _refreshIconSelections({bool blankAll = false}) {
    debugPrint("_refreshIconSelections(blankAll: $blankAll)");
    IconWidget holder;

    setState(()
    {
      for (int i = 0; i < _stackElements.length; i++)
      {
          if (!(_stackElements[i] is IconWidget)) continue;

          holder = _stackElements[i] as IconWidget;

          if (blankAll == true)
          {
            (_stackElements[i] as IconWidget).state.setActive(false);
          }
          else if (boardSettings.checkIsInSingleMode == true)
          {
            (_stackElements[i] as IconWidget).state.setActive(holder.inPlay);
          }
          else if (boardSettings.checkIsInSingleMode == false)
          {
            (_stackElements[i] as IconWidget).state.setActive(_isWithinStrip(holder));
          }
      }
    });
  }

  /// Save to db
  /// 
  /// 
  _saveLatestStack(Widget widget) async {
    debugPrint("_saveLatestStack() " + new DateTime.now().toString());

    if (iconDb == null) return;

    /*
    if (widget != null && widget is IconWidget)
    {
        if (widget.type != IconType.Icon)
        {
          return;
        }

        SavedIcon savedIcon = SavedIcon();
        savedIcon.id        = widget.id;
        savedIcon.iconName  = widget.text;
        savedIcon.iconPath  = widget.assetPath;
        savedIcon.x         = widget.currentPosition.dx;
        savedIcon.y         = widget.currentPosition.dy;
        savedIcon.embedded  = widget.isEmbbedded;
        savedIcon.pinned    = widget.isPinned;
        savedIcon.scale     = widget.scale;
        savedIcon.active    = widget.inPlay;
        savedIcon.isStored  = widget.isStored;
        savedIcon.storedId  = widget.storedId;
        savedIcon.isFolder  = false;

        await iconDb.update(savedIcon);
    }

    iconDb.saveSettings(boardSettings);
    */
  }

  void debugPrint(String toTerminal) {
    if (outputToTerminal == false) return;

    print("Visual Field: $toTerminal");
  }
}
