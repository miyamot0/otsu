import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../Controls/AnimatedMenu.dart';
import '../Controls/ReactiveIconWidget.dart';
import '../Controls/SpeakerObject.dart';
import '../Controls/StripObject.dart';

import '../Storage/IconDatabase.dart';

class IconField extends StatefulWidget {
  IconField({this.iconDb});

  final IconDatabase iconDb;
  
  @override
  IconFieldState createState() => IconFieldState(iconDb: iconDb);
}

class IconFieldState extends State<IconField> {
  IconFieldState({this.iconDb});

  final IconDatabase iconDb;
  AnimatedMenuWidget animatedMenu;
  BoardSettings boardSettings;

  final childButtons = List<AnimatedMenuItem>();

  List<Widget> _stackElements = [];

  Color background = Colors.blueAccent;

  bool inDebugMode = true;

  StripObject sentenceStripReference;
  SpeakerObject speakerObjectReference;

  String dir;

  void moveTestIconToTop(ReactiveIconWidget widget) {
    print("moveTestIconToTop(TestIcon widget)");

    _stackElements.remove(widget);
    _stackElements.add(widget);

    //setState(() {
    //  background = (background != Colors.blueAccent) ? Colors.blueAccent : Colors.orangeAccent;
    //});

    //print("moveTestIconToTop(TestIcon widget): Item at end of stack = ${_stackElements.last.label}");
  }

  @override
  void initState() {
    print("initState()");

    /*

    _stackElements.add(ReactiveIconWidget(label: "two", 
                                isInPlay: true,
                                moveToTop: moveTestIconToTop,
                                initialPosition: Offset(200.0, 200.0),));

    _stackElements.add(ReactiveIconWidget(label: "three", 
                                isInPlay: true,
                                moveToTop: moveTestIconToTop,
                                initialPosition: Offset(300.0, 300.0),));

    */

    _loadIcons();

    super.initState();
  }

  _loadIcons() async {
      sentenceStripReference = StripObject(padding: 10.0);
      speakerObjectReference = SpeakerObject(_emitSpeech, _toggleDebug);

      boardSettings = await iconDb.loadSettings();
      List<SavedIcon> icons = await iconDb.getSavedIcons();

      dir = (await getApplicationDocumentsDirectory()).path;      

      setState(()
      {
        background = (!inDebugMode) ? Colors.lightBlueAccent : Colors.orange;


        _stackElements.clear();

        _stackElements.add(sentenceStripReference);
        _stackElements.add(speakerObjectReference);              

        _stackElements.add(ReactiveIconWidget(label: "almond (test)", 
                                              assetPath: "images/almond.png",
                                              isInPlay: false,
                                              moveToTop: moveTestIconToTop,
                                              documentsFolder: dir,
                                              initialPosition: Offset(100.0, 100.0),
                                              isInSingleMode: boardSettings.checkIsInSingleMode,
                                              showEditOptions: false,
                                              isStored: false)
                                              );


        //IconWidget holder;
        //FolderWidget folderHolder;

        for (int i = 0; i < icons.length; i++)
        {
            /*
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
            */        
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

  @override
  Widget build(BuildContext context) {
    print("build(BuildContext context)");

    return Scaffold(body: 
                    Container(child: Stack(children: _stackElements),
                              decoration: BoxDecoration(color: background)),
                    floatingActionButton: inDebugMode ? animatedMenu : null,
                    primary: false,
                    resizeToAvoidBottomPadding: false,);
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

              /*
                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);
              */

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

              /*
                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);
              */

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

                /*
                // Blank them only if going into single mode
                _refreshIconSelections(blankAll: boardSettings.checkIsInSingleMode == true);
                _saveLatestStack(null);
                */

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
            /*

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
              */
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

  /// Navigate to the icon creation screen
  /// 
  /// Create icon from either camera or pictures, handle all that business on that screen.
  ///
  /// Return: Text/Path pair for adding to the board
  _navigateToIconCreatorScreen(BuildContext context) async {
    debugPrint("_navigateToIconCreatorScreen()");

    /*
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

    */

    //_refreshIconSelections();
  }

  /// Collect relevant icons in the speech frame
  /// 
  /// TODO: single icon mode
  _emitSpeech() async {
    debugPrint("_emitSpeech() " + new DateTime.now().toString());

    /*

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
    */
  }

  /// Resume child interaction mode
  /// 
  /// This disables debug mode (hides buttons)
  _resumeChildMode() {
    setState(() {
      inDebugMode = false;
      background = Colors.lightBlueAccent;

      /*

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
      */
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
      /*
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
      */
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

