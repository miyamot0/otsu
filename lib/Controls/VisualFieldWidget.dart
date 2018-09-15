import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../Controls/AnimatedMenu.dart';
import '../Controls/ReactiveIconWidget.dart';
import '../Controls/SpeakerObject.dart';
import '../Controls/StripObject.dart';

import '../Models/IconType.dart';

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

    setState(() {

        stackElements.add(ReactiveIconWidget(label: "almost hack",
                                             iconType: IconType.Icon,
                                             assetPath: 'images/almond.png', 
                                             isInSingleMode: boardSettings.checkIsInSingleMode,
                                             isEmbbedded: true,
                                             isStored: false, 
                                             isInPlay: false,
                                             scale: 1.0,
                                             defaultWidth: 200.0,
                                             moveToTop: moveIconToTop,//todo
                                             initialPosition: Offset(100.0, 100.0),));

        stackElements.add(ReactiveIconWidget(label: "almost hack",
                                             iconType: IconType.Icon,
                                             assetPath: 'images/almond.png', 
                                             isInSingleMode: boardSettings.checkIsInSingleMode,
                                             isEmbbedded: true,
                                             isStored: false, 
                                             isInPlay: false,
                                             scale: 1.0,
                                             defaultWidth: 200.0,
                                             moveToTop: moveIconToTop,//todo
                                             initialPosition: Offset(200.0, 120.0),));
        
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

  void moveIconToTop(ReactiveIconWidget widget) {
    print("moveTestIconToTop(TestIcon widget)");

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

      widget.key.currentState.setState(() {
        widget.key.currentState.isInPlay = true;
      });

      if (boardSettings.checkIsAutoSpeaking) {
        emitSpeech();
      }
    }

    //int index = stackElements.indexOf(widget);

    //widget.
    

    //ReactiveIconWidget.of(context).isInPlay = true;
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
            onPressed: () => print("STUB: ADD ICON"),//_navigateToIconCreatorScreen(context),
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