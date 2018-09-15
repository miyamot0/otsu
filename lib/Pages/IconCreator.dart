/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../Controls/PreviewIcon.dart';
import '../Controls/CustomFloatingButtonLocation.dart';
import '../Controls/AnimatedMenu.dart';
import '../Dialogs/DialogIconLabel.dart';
import '../Models/EmbeddedIconModel.dart';

class IconCreatorScreen extends StatefulWidget {
  final String documentsDirectory;

  IconCreatorScreen(this.documentsDirectory);

  @override
  _IconCreatorState createState() => _IconCreatorState();
}

class _IconCreatorState extends State<IconCreatorScreen> {
  static const double maxDimension = 512.0;
  static const List<String> categoryList = ["AAC","abstract","action","adjective","adverb","aid","alcohol","alphabet","amount","animal","ask","astronomy","beef","bird","body","breakfast","cake","calendar","celebration","Christian","class","climate","clinic","clothes","communication","computer","cooking","country","dairy","dessert","diary","direction","DIY","drink","Easter","electric","emotion","equipment","expression","face","family","farm","features","feeding","feeling","finance","fish","flag","food","footwear","forecast","fraction","fruit","games","gardening","grooming","halloween","hat","health","holiday","home","hospital","house","ingredient","insect","instrument","jewellery","job","juice","kitchen","lamb","letter","mammal","maths","meal","meat","medical","money","music","office","people","percent","pet","planets","plant","play","playground","pork","position","profession","query","question","relationship","relatives","reptile","salad","school","season","sentence","shape","shellfish","size","sleepwear","snack","soccer","sport","stationery","sweet","swimwear","team","time","tools","toys","transport","travel","underwear","uniform","utensil","vegetable","vehicle","weather","wild","woman","work","workshop","zoo"];

  List<dynamic> jsonResponse, jsonAssets;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Add Icon to Board")),
                    body: _buildPhotoGallery(context),
                    backgroundColor: Colors.lightBlueAccent,
                    floatingActionButton: _buildAnimatedMenu(),                    
                    floatingActionButtonLocation: btnLocation,);
  }

  /// Build menu
  ///
  ///
  AnimatedMenuWidget _buildAnimatedMenu() {
    //debugPrint("_buildAnimatedMenu()");

    if (animatedMenuWiget == null)
    {
      List<AnimatedMenuItem> buttons = [];

      buttons.add(_buildSaveButton());
      buttons.add(_buildEditLabelButton());
      buttons.add(_buildImageIconButton());
      buttons.add(_buildPhotoIconButton());

      animatedMenuWiget = AnimatedMenuWidget(backgroundColor: Color.fromRGBO(255, 255, 255, 0.6),
                                            parentButtonBackground: Colors.redAccent,
                                            orientation: AnimatedMenuOrientation.VERTICAL,
                                            parentButton: Icon(Icons.edit),                                            
                                            hasBackground: false,
                                            isLeft: true,                                                          
                                            childButtons: buttons);
    }

    return animatedMenuWiget;
  }

  /// Build button 
  ///
  ///
  AnimatedMenuItem _buildSaveButton() {
    //debugPrint("_buildSaveButton()");
    return AnimatedMenuItem(
      hasLabel: true,
      labelText: "Add Current Icon to Board",
      labelColor: Colors.black,
      currentButton: FloatingActionButton(
        backgroundColor: Colors.green,
        heroTag: "addIconBoardTag",
        mini: true,
        child: Icon(Icons.save_alt),
        onPressed: () {
          Navigator.pop(context, EmbeddedIconModel(assetLocation: assetPath, 
                                                    iconText: assetText, 
                                                    isEmbedded: isEmbedded,));
        }
      ),
    );
  }

  /// Build button 
  ///
  ///
  AnimatedMenuItem _buildEditLabelButton() {
    //debugPrint("_buildEditLabelButton()");
    return AnimatedMenuItem(
      hasLabel: true,
      labelText: "Edit Current Label",
      labelColor: Colors.black,
      currentButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        heroTag: "editLabelTag",
        mini: true,
        child: Icon(Icons.edit),
        onPressed: () async {
          String result = await _showInputDialog();

          if (result == null) return;

          setState(() {
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
    //debugPrint("_showInputDialog()");
    return await showDialog<String>(
      context: context,
      child: new DialogIconLabel(assetText: assetText),
    );
  }  

  /// Build button 
  ///
  ///
  AnimatedMenuItem _buildPhotoIconButton() {
    //debugPrint("_buildPhotoIconButton()");
    return AnimatedMenuItem(
      hasLabel: true,
      labelText: "Take a Photo",
      labelColor: Colors.black,
      currentButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        heroTag: "addPhotoTag",
        mini: true,
        child: Icon(Icons.add_a_photo),
        onPressed: ()
        async {
          File image = await ImagePicker.pickImage(source: ImageSource.camera, maxHeight: maxDimension, maxWidth: maxDimension);

          if (image == null) return;

          _createLocalCopy(image);
        },
      ),
    );
  }

  /// Build button 
  ///
  ///
  AnimatedMenuItem _buildImageIconButton() {
    //debugPrint("_buildImageIconButton()");
    return AnimatedMenuItem(
      hasLabel: true,
      labelText: "Load a Stored Image",
      labelColor: Colors.black,
      currentButton: FloatingActionButton(
        backgroundColor: Colors.grey,
        heroTag: "addImageTag",
        mini: true,
        child: Icon(Icons.image),
        onPressed: ()
        async {
          File image = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: maxDimension, maxWidth: maxDimension);

          if (image == null) return;

          _createLocalCopy(image);
        },
      ),
    );
  }

  /// Create a local copy of image
  /// 
  /// 
  void _createLocalCopy(File image) async {
    //debugPrint("_createLocalCopy()");
    String stamp = formatDate(DateTime.now(), [yyyy,'.',mm,'.',dd,'.',HH,'.',nn,'.',ss]);
    String filename = "$stamp.png";

    File newImage = await image.copy('${widget.documentsDirectory}/$filename');

    if (newImage.existsSync())
    {
      setState(() 
      {
        assetText = "unnamed";
        assetPath = filename;
        isEmbedded = false;
      });
    }    
  }

  /// Load individual categories
  /// 
  /// 
  Future<String> _loadCategoriesJson(String fileName) async {
    return await rootBundle.loadString('json/$fileName.json');
  }

  /// Load images
  ///
  ///
  void _loadImages(String category) async {
    //debugPrint("_loadImages()");
    String distancesText = await _loadCategoriesJson(category);
    jsonAssets = json.decode(distancesText) as List;

    imgs = [];

    setState(() 
    {
      for (var asset in jsonAssets)
      {
        imgs.add(new Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 1.0),
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
    //debugPrint("_changeImage()");

    setState(() {
      List<String> splitString = assetName.split(".png");
      String prefix = splitString[0];
    
      assetPath = "images/$prefix.png";

      List<String> cleanSplitString = prefix.split("_");

      if (cleanSplitString.length == 1)
      {
        assetText = "$prefix";
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
    //debugPrint("_buildPreview()");
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: Align(child: preview))
      ],
    );
  }

  /// Build dropdown
  ///
  ///
  InputDecorator _buildDropDown() {
    //debugPrint("_buildDropDown()");
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Select an Icon Category', 
        labelStyle: TextStyle(
          fontSize: 24.0
        ),
      ),
      child: DropdownButtonHideUnderline( 
        child: DropdownButton<String>( 
          value: selectedText,
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
          isDense: false,
          onChanged: (String newValue) {
            setState(() {
              selectedText = newValue;
              _loadImages(selectedText);
            });
          },
          items: categoryList.map((String value) 
          {
            return new DropdownMenuItem<String>(
              value: "$value",
              child: new Text("$value"),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Build grid view
  ///
  ///
  Expanded _buildCategoryGridview() {
    //debugPrint("_buildCategoryGridview()");
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
    //debugPrint("_buildPhotoGallery()");

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
              _buildDropDown(),
              _buildCategoryGridview(),
            ]
          ),
        ),
      ],
    );
  }
}
