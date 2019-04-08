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

class VisualFieldWidget extends StatefulWidget {
  final GlobalKey key;

  VisualFieldWidget({this.key});

  @override
  VisualFieldWidgetState createState() => VisualFieldWidgetState();
}

class VisualFieldWidgetState extends State<VisualFieldWidget> {
  BoardSettings boardSettings;

  AnimatedMenuWidget animatedMenu;

  StripObject sentenceStripReference;
  SpeakerObject speakerObjectReference;

  Color background = Colors.orangeAccent;

  final stackElements = <Widget>[];
  final childButtons = List<AnimatedMenuItem>();


  @override
  void initState() {
    printDebug("VisualFieldWidgetState::initState()");

    sentenceStripReference = StripObject(
      padding: 10.0
    );

    speakerObjectReference = SpeakerObject(
      _emitSpeech, 
      _toggleDebugMode
    );
    
    stackElements.add(speakerObjectReference);

    SchedulerBinding.instance.addPostFrameCallback((_) => _loadFromDatabase());

    super.initState();
  }

  @override
  void dispose() {
    printDebug("VisualFieldWidgetState::dispose()");

    InheritedAppState.of(context).iconDb.close();

    super.dispose();
  }

  /// Load icons from database
  /// 
  /// 
  void _loadFromDatabase() async {
    printDebug("VisualFieldWidgetState::loadFromDatabase()");

    boardSettings = await InheritedAppState.of(context).iconDb.loadSettings();

    if (boardSettings.checkIsInSingleMode == false) 
    {
      stackElements.add(sentenceStripReference);      
    }

    List<SavedIcon> icons = await InheritedAppState.of(context).iconDb.getSavedIcons();

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

      speakerObjectReference.speak("").then((_) => printDebug("TTS Module Loaded..."));
    });

    childButtons.clear();

    childButtons.add(_buildAddFolderButton());
    childButtons.add(_buildAddIconButton());
    childButtons.add(_buildSwitchModeButton());
    childButtons.add(_buildAutoOutputModeButton());
    childButtons.add(_buildAutoDeselectModeButton());
    childButtons.add(_buildResumeChildModeButton());

    animatedMenu = _buildAnimatedMenu(childButtons);

    // Check for positioning on start (for framed speech)
    SchedulerBinding.instance.addPostFrameCallback((_) {
      printDebug("VisualFieldWidgetState::addPostFrameCallback(_)");

      if (boardSettings.checkIsInSingleMode == false)
      {
        _moveIconToTop(null);
      }

      _checkAllCurrentMenuOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
 
    _toggleSentenceStrip();
    
    return InheritedVisualFieldState(
      background: background,
      inDebugMode: inDebugMode,
      stackElements: stackElements,
      animatedMenu: animatedMenu,
      boardSettings: boardSettings,
      boardSize: MediaQuery.of(context).size,
      child: VisualFieldBox(),
    );
  }

  /// Update individual menu items as necessary (not on totally redrawing tree)
  ///
  ///
  void _checkAllCurrentMenuOptions() {
      printDebug("VisualFieldWidgetState::_checkAllCurrentMenuOptions");

      if (boardSettings == null) return;

      if (animatedMenu.childButtons[2].labelText != ((boardSettings.checkIsInSingleMode == true) ? "Change to Frame Mode" : "Change to Icon Mode")) {
        childButtons.removeAt(2);
        childButtons.insert(2, _buildSwitchModeButton());
      }

      if (animatedMenu.childButtons[3].labelText != ((boardSettings.checkIsAutoSpeaking == true) ? "Change to Manual Mode" : "Change to Autospeak Mode")) {
        childButtons.removeAt(3);
        childButtons.insert(3, _buildAutoOutputModeButton());
      }

      if (animatedMenu.childButtons[4].labelText != ((boardSettings.checkIsAutoDeselecting == true) ? "Disable Auto-Deselect" : "Enable Auto-Deselect")) {
        childButtons.removeAt(4);
        childButtons.insert(4, _buildAutoDeselectModeButton());
      }
  }

  /// Is there an intersection between a folder and an icon?
  /// 
  /// 
  Future<bool> _isIconOverlappingWithFolder(ReactiveIconWidget widget) async {
    printDebug("VisualFieldWidgetState::_isIconOverlappingWithFolder(ReactiveIconWidget widget)");

    var folders =  stackElements.where((w) => w is ReactiveFolderWidget)
                                .where((w) => (w as ReactiveFolderWidget).key.currentState.defaultWidth != null)
                                .where((w) => (w as ReactiveFolderWidget).intersectsWith(widget.key.currentState.defaultWidth,
                                                                                         widget.key.currentState.scale,
                                                                                         widget.key.currentState.currentPosition))
                                .toList();   

    if (folders != null && folders.length > 0)
    {
        ReactiveFolderWidget droppableFolder = folders.first;

        SavedIcon savedIcon = SavedIcon()
        ..id        = widget.id
        ..iconName  = widget.key.currentState.label
        ..iconPath  = widget.assetPath
        ..x         = widget.key.currentState.currentPosition.dx
        ..y         = widget.key.currentState.currentPosition.dy
        ..embedded  = widget.key.currentState.isEmbbedded
        ..pinned    = widget.key.currentState.isPinnedToLocation
        ..scale     = widget.key.currentState.scale
        ..active    = widget.key.currentState.isInPlay
        ..isStored  = true
        ..storedId  = droppableFolder.id
        ..isFolder  = false;

        await InheritedAppState.of(context).iconDb.update(savedIcon);

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
    printDebug("VisualFieldWidgetState::_moveIconToTop(TestIcon widget)");

    if (boardSettings == null) return;

    ReactiveIconWidget iconHolder;
    if (widget == null)
    {
      if (boardSettings.checkIsInSingleMode == true)
      {
        //print("VisualFieldWidget: _moveIconToTop() == IsInSingleMode");

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
      //print("VisualFieldWidget: _moveIconToTop() == IsInSingleMode");

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
    printDebug("VisualFieldWidgetState::__saveLatestStack() " + new DateTime.now().toString());

    if (InheritedAppState.of(context).iconDb == null) return;

    if (widget != null && widget is ReactiveIconWidget)
    {
      SavedIcon savedIcon = SavedIcon()
      ..id        = widget.id
      ..iconName  = widget.key.currentState.label
      ..iconPath  = widget.key.currentState.assetPath
      ..x         = widget.key.currentState.currentPosition.dx
      ..y         = widget.key.currentState.currentPosition.dy
      ..embedded  = widget.key.currentState.isEmbbedded
      ..pinned    = widget.key.currentState.isPinnedToLocation
      ..scale     = widget.key.currentState.scale
      ..active    = widget.key.currentState.isInPlay
      ..isStored  = widget.key.currentState.isStored
      ..storedId  = widget.storedId
      ..isFolder  = false;

      await InheritedAppState.of(context).iconDb.update(savedIcon);
    }
    else if (widget != null && widget is ReactiveFolderWidget)
    {
      SavedIcon savedIcon = SavedIcon()
      ..id        = widget.id
      ..iconName  = widget.key.currentState.label
      ..iconPath  = widget.key.currentState.assetPath
      ..x         = widget.key.currentState.currentPosition.dx
      ..y         = widget.key.currentState.currentPosition.dy
      ..embedded  = widget.key.currentState.isEmbbedded
      ..pinned    = widget.key.currentState.isPinnedToLocation
      ..scale     = widget.key.currentState.scale
      ..active    = widget.key.currentState.isInPlay
      ..isStored  = widget.key.currentState.isStored
      ..storedId  = -1
      ..isFolder  = true;

      await InheritedAppState.of(context).iconDb.update(savedIcon);
    }

    await InheritedAppState.of(context).iconDb.saveSettings(boardSettings);
  }

  /// Remove from stack
  /// 
  /// 
  void _removeFromDatabase(Widget widget) async {
    printDebug("VisualFieldWidgetState::_removeFromStack(Widget widget)");

    if (widget is ReactiveIconWidget)
    {
      await InheritedAppState.of(context).iconDb.delete(widget.id);

      setState(() 
      {
        stackElements.remove(widget);
      });
    }

    if (widget is ReactiveFolderWidget)
    {
       await InheritedAppState.of(context).iconDb.deleteFolder(widget.id);

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
    printDebug("VisualFieldWidgetState::_resumeChildMode()");

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

    await InheritedAppState.of(context).iconDb.saveSettings(boardSettings);
  }

  /// Toggle debug mode
  /// 
  /// 
  void _toggleDebugMode() {
    printDebug("VisualFieldWidgetState::_toggleDebugMode()");

    setState(() {
      inDebugMode = true;
    });
  }

  /// Deselect all icons
  /// 
  /// 
  void _deselectAllIcons() {
    printDebug("VisualFieldWidgetState::_deselectAllIcons");

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
    printDebug("VisualFieldWidgetState::_emitSpeech()");

    if (boardSettings.checkIsInSingleMode == true)
    {
      for (var x in stackElements) 
      {
        if (x is ReactiveIconWidget)
        {
          if (x.key.currentState.isInPlay == true)
          {
            if (boardSettings.checkIsAutoDeselecting == true || boardSettings.checkIsAutoSpeaking == true)
            {
              _deselectAllIcons();
            }

            await speakerObjectReference.speak(x.key.currentState.label);
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
    printDebug("VisualFieldWidgetState::_isWithinStrip(icon)");

    if (sentenceStripReference == null || 
        sentenceStripReference.key.currentState.stripSize == null) return false;

    if (icon.key.currentState.currentPosition.dy > sentenceStripReference.key.currentState.stripSize.height) return false;

    if (icon.key.currentState.currentPosition.dx > sentenceStripReference.key.currentState.stripSize.width)  return false;

    return true;
  }

  /// Show on-screen context menu
  ///
  ///
  void _showContextMenuIcon(Offset offset, ReactiveIconWidget widget) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    final resultOfMenu = await showMenu(
      context: context,
      items: <PopupMenuEntry<int>>[EditIconEntry(widget)],
      position: RelativeRect.fromRect(
          offset & Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size   // Bigger rect, the entire screen
      )
    );

    switch (resultOfMenu) {
      case EditIconEntry.DeleteIcon:
        _removeFromDatabase(widget);
        break;
      
      case EditIconEntry.ModifyIconLabel:
        String finalNewString = await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return DialogIconLabel(assetText: widget.label,);
          },
        );

        if (finalNewString != null && widget.label != finalNewString)
        {
          widget.key.currentState.setState(()
          {
            widget.key.currentState.label = finalNewString;  
          });
        }

        _saveLatestStack(widget);

        break;

      default:
        _saveLatestStack(widget);
        break;  
    }
  }

  /// Show on-screen context menu
  ///
  ///
  void _showContextMenuFolder(Offset offset, ReactiveFolderWidget widget) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();

    final resultOfMenu = await showMenu(
      context: context,
      items: <PopupMenuEntry<int>>[EditFolderEntry(widget)],
      position: RelativeRect.fromRect(
          offset & Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size   // Bigger rect, the entire screen
      )
    );

    if (resultOfMenu == EditFolderEntry.DeleteFolder) {
      _removeFromDatabase(widget);
    } else {
      _saveLatestStack(widget);
    }
  }

  /// Trigger editor for icons
  /// 
  /// 
  void _triggerEditor(Widget widget) async {
    printDebug("VisualFieldWidgetState::_triggerEditor(Widget widget)");

    if (widget is ReactiveIconWidget)
      _showContextMenuIcon(widget.key.currentState.currentPosition, widget);

    if (widget is ReactiveFolderWidget)
      _showContextMenuFolder(widget.key.currentState.currentPosition, widget);
  }

  /// Navigate to folder contents
  /// 
  /// 
  void _navigateToFolderContentDialog(ReactiveFolderWidget folderWidget) async {
    printDebug("_navigateToFolderContentDialog: ${folderWidget.key.currentState.label}");

    var storedIcons = await InheritedAppState.of(context).iconDb.getStoredIcons(folderWidget.id);

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
    printDebug("_buildFolderPopupDialog, length = ${storedIcons.length}");

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
    printDebug("_restoreIconFromStorage(SavedIcon savedIcon)");

    savedIcon.isStored = false;
    savedIcon.storedId = -1;

    await InheritedAppState.of(context).iconDb.update(savedIcon);

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
    printDebug("VisualFieldWidgetState::_toggleSentenceStrip()");

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
    printDebug("_navigateToIconCreatorScreen()");

    EmbeddedIconModel result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => IconCreatorScreen()
      )
    );

    if (result == null) return;

    SavedIcon savedIcon = SavedIcon()
    ..id        = null
    ..iconName  = result.iconText
    ..iconPath  = result.assetLocation
    ..x         = 0.0
    ..y         = 0.0
    ..embedded  = result.isEmbedded
    ..pinned    = false
    ..scale     = 1.0
    ..active    = false
    ..isStored  = false
    ..storedId  = -1
    ..isFolder  = false;

    SavedIcon insert = await InheritedAppState.of(context).iconDb.insert(savedIcon);

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
    printDebug("_navigateToIconCreatorScreen()");
    
    EmbeddedIconModel result = await Navigator.push(context, MaterialPageRoute(
      builder: (context) => FolderCreatorScreen()
      )
    );

    if (result == null) return;

    SavedIcon savedIcon = SavedIcon()
    ..id        = null
    ..iconName  = result.iconText
    ..iconPath  = result.assetLocation
    ..x         = 0.0
    ..y         = 0.0
    ..embedded  = result.isEmbedded
    ..pinned    = false
    ..scale     = 1.0
    ..active    = false
    ..isStored  = false
    ..storedId  = -1
    ..isFolder  = true;

    SavedIcon insert = await InheritedAppState.of(context).iconDb.insert(savedIcon);

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
    printDebug('_buildAutoOutputModeButton()');

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

          _checkAllCurrentMenuOptions();

          await InheritedAppState.of(context).iconDb.saveSettings(boardSettings);
        },
      )
    );
  }

  /// Build auto deselect button
  /// 
  /// 
  AnimatedMenuItem _buildAutoDeselectModeButton() {
    printDebug("_buildAutoDeselectModeButton()");

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

          _checkAllCurrentMenuOptions();

          await InheritedAppState.of(context).iconDb.saveSettings(boardSettings);
        },
      )
    );
  }

  /// Build switch button
  ///
  ///
  AnimatedMenuItem _buildSwitchModeButton() {
    printDebug('_buildSwitchModeButton()');

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

          _checkAllCurrentMenuOptions();

          // Check for positioning on start (for framed speech)
          SchedulerBinding.instance.addPostFrameCallback((_) {
            printDebug("VisualFieldWidgetState::addPostFrameCallback(_)");

            if (boardSettings.checkIsInSingleMode == false)
            {
              _moveIconToTop(null);
            }

            _checkAllCurrentMenuOptions();
          });

          await InheritedAppState.of(context).iconDb.saveSettings(boardSettings);
        },
      )
    );
  }

  /// Build resume button
  ///
  ///
  AnimatedMenuItem _buildResumeChildModeButton() {
    printDebug('_buildResumeChildModeButton()');

    return AnimatedMenuItem(
      labelText: "Resume Child Mode",
      currentButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        heroTag: "resumeTag",
        mini: false,
        child: Icon(Icons.play_arrow),
        onPressed: () async {
          _resumeChildMode();

          _checkAllCurrentMenuOptions();

          await InheritedAppState.of(context).iconDb.saveSettings(boardSettings);
        }
      )
    );
  }

  /// Build icon button 
  ///
  ///
  AnimatedMenuItem _buildAddFolderButton() {
    printDebug('_buildAddFolderButton()');

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
    printDebug('_buildAddIconButton()');

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
    printDebug('_buildAnimatedMenu()');

    return AnimatedMenuWidget(
      parentButton: Icon(Icons.settings),
      isLeft: false,
      childButtons: buttons
    );
  }
}
