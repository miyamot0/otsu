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

final bool outputToTerminal = false;

class FolderCreatorScreen extends StatefulWidget {
  final String documentsDirectory;

  FolderCreatorScreen(this.documentsDirectory);

  @override
  FolderCreatorScreenState createState() => FolderCreatorScreenState();
}

class FolderCreatorScreenState extends State<FolderCreatorScreen> {
  static const double maxDimension = 512.0;

  List<Container> imgs = [];

  PreviewIcon preview;
  String selectedText, assetPath, assetText;
  bool isEmbedded;

  Size previewSize;
  AnimatedMenuWidget animatedMenuWiget;
  CustomFloatingButtonLocation btnLocation = CustomFloatingButtonLocation();

  @override
  void initState() {
    super.initState();
    assetPath = "images/placeholder.png";
    assetText = "Example Icon";
    isEmbedded = true;

    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Folder to Board")
      ),
      body: _buildPhotoGallery(context),
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: _buildAnimatedMenu(), 
      floatingActionButtonLocation: btnLocation,
    );
  }

  /// Build menu
  ///
  ///
  AnimatedMenuWidget _buildAnimatedMenu() {
    if (animatedMenuWiget == null)
    {
      animatedMenuWiget = AnimatedMenuWidget(
        parentButton: Icon(Icons.edit),
        isLeft: true,
        childButtons: [
          _buildSaveButton(), 
          _buildEditLabelButton()
        ]
      );
    }

    return animatedMenuWiget;
  }

  /// Build button 
  ///
  ///
  AnimatedMenuItem _buildSaveButton() {
    debugPrint("_buildSaveButton()");
    
    return AnimatedMenuItem(
      labelText: "Add Current Icon to Board",
      autoDismiss: true,
      currentButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: "addIconBoardTag",
        mini: true,
        child: Icon(Icons.save_alt),
        onPressed: () 
        {
          Navigator.pop(
            context,
            EmbeddedIconModel(
              assetLocation: assetPath, 
              iconText: assetText, 
              isEmbedded: isEmbedded,
            ),
          );
        },
      ),
    );
  }

  /// Build button 
  ///
  ///
  AnimatedMenuItem _buildEditLabelButton() {
    debugPrint("_buildEditLabelButton()");
    
    return AnimatedMenuItem(
      labelText: "Edit Current Label",
      autoDismiss: true,
      currentButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        heroTag: "editLabelTag",
        mini: true,
        child: Icon(Icons.edit),
        onPressed: () async 
        {
          String result = await _showInputDialog();

          if (result == null) return;

          setState(() 
          {
            assetText = result;                
          });
        },
      ),
    );
  }  

  /// Show edit text dialog
  /// 
  /// 
  Future<String> _showInputDialog() async {
    debugPrint("_showInputDialog()");
    
    return await showDialog<String>(
      context: context,
      child: new DialogIconLabel(assetText: assetText),
    );
  }  

  /// Load images
  ///
  ///
  void _loadImages() async {
    debugPrint("_loadImages()");

    var folderAssets = 
    [
      "FolderOpenDarkBlue", 
      "FolderOpenDarkPink", 
      "FolderOpenDarkPurple", 
      "FolderOpenGreen", 
      "FolderOpenLightBlue", 
      "FolderOpenRed"
    ];

    imgs = [];

    setState(() 
    {
      for (var asset in folderAssets)
      {
        imgs.add(new Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black, 
              width: 1.0
            ),
            color: Colors.white,
          ),
          child: GestureDetector(
            child: new Image.asset('images/$asset.png'),
            onTap: () => _changeImage('$asset'),
          ),
        ));
      }
    });
  }

  /// Modify image preview
  /// 
  /// 
  void _changeImage(String assetName) {
    debugPrint("_changeImage()");

    setState(() 
    {
      List<String> splitString = assetName.split(".png");
      String prefix = splitString[0];
    
      assetPath = "images/$prefix.png";

      List<String> cleanSplitString = prefix.split("_");

      if (cleanSplitString.length == 1)
      {
        assetText = "Folder Name";
      }
      else
      {
        for (var i = 0; i < cleanSplitString.length; i++)
        {
          if (i == 0)
            assetText = cleanSplitString[i];            
          else
            assetText = assetText + " " + cleanSplitString[i];
        }
      }

      isEmbedded = true;
    });
  }

  /// Build preview
  ///
  ///
  Column _buildPreview() {
    debugPrint("_buildPreview()");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: Align(child: preview))
      ]
    );
  }

  /// Build grid view
  ///
  ///
  Expanded _buildCategoryGridview() {
    debugPrint("_buildCategoryGridview()");

    return new Expanded(
      child: new SafeArea(
        top: false,
        bottom: false,
        child: new GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          padding: const EdgeInsets.all(4.0),
          childAspectRatio: 1.3,
          children: imgs,
        ),
      ),
    );
  }

  /// Build gallery, in general
  /// 
  /// 
  Row _buildPhotoGallery(BuildContext context) {
    debugPrint("_buildPhotoGallery()");

    final mediaQueryData = MediaQuery.of(context);
    previewSize = Size(mediaQueryData.size.width / 3, mediaQueryData.size.width / 3);

    setState(() 
    {
      preview = PreviewIcon(previewSize, assetPath, assetText, isEmbedded, widget.documentsDirectory);
    });

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new Expanded(
          child: _buildPreview(),
        ),
        new Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryGridview(),
            ],
          ),
        ),
      ],
    );
  }
}
