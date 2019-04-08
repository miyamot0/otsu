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

class PreviewBox extends StatelessWidget {

  final Offset position = new Offset(0.0, 0.0);
  final Size size;
  final String label;
  final String assetPath;
  final Color backgroundColor;
  final Function editFunction;
  final String documentsDirectory;
  final bool showEditOptions;
  final bool isPinnedToLocation;
  final bool isEmbedded;

  final double opacity;

  PreviewBox({
    this.size,
    this.label,
    this.assetPath,
    this.opacity: 1.0,
    this.backgroundColor,
    this.editFunction,
    this.showEditOptions,
    this.isPinnedToLocation,
    this.isEmbedded,
    this.documentsDirectory,
  });

  static const TextStyle defaultStyle = TextStyle(
    color: Colors.black, 
    decoration: TextDecoration.none, 
    fontSize: 20.0
  );

  static Border thickBorder = Border.all(
    color: const Color(0xFF000000),
    width: 5.0,
  );

  static const Align pinnedIcon = Align(
    child: Icon(
      Icons.pin_drop,
    ),
  );

  static const childArray = [pinnedIcon];

  static Row topRow = Row(
    children: childArray, 
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    verticalDirection: VerticalDirection.up,
  );

  @override
  Widget build(BuildContext context) {
    Image imgAsset = Image.asset(
      isEmbedded == true ? assetPath : "$documentsDirectory/$assetPath",
      height: size.height * 0.7,
      fit: BoxFit.cover
    );

    Column centerColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Flexible(
          child: Opacity(
            child: topRow,
            opacity: 0.0,
          ),
          flex: 1,
        ),
        Flexible(
          child: Align(
            alignment: Alignment.center, 
            child: imgAsset,
          ), 
          flex: 6,
        ),
        Flexible(
          child: Align(
            alignment: Alignment.center, 
            child: Text(
              label, 
              style: defaultStyle,
            ),
          ), 
          flex: 2,
        ),
      ]
    );

    return new Container(
      width: size.width,
      height: size.height,
      key: GlobalKey(),
      decoration: BoxDecoration(
        border: thickBorder,
        color: backgroundColor,
      ),
      child: Column(
        children: [
          Expanded(
            child: centerColumn,
          ),
        ],
      ),
    );
  }
}
