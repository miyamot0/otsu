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

class PreviewIcon extends StatelessWidget {
  final Size previewSize;
  final String assetPath;
  final String text;
  final String documentsDirectory;
  final bool isEmbedded;

  static const backgroundColor = Colors.white;
  static const showingEditOptions = false;
  static const isPinnedToCurrentLocation = true;
  static const currentOpacity = 1.0;

  PreviewIcon(this.previewSize, this.assetPath, this.text, this.isEmbedded, this.documentsDirectory);

  @override
  Widget build(BuildContext context) {

    return PreviewBox(
      size: previewSize,
      label: text,
      assetPath: assetPath,
      opacity: currentOpacity,
      isPinnedToLocation: isPinnedToCurrentLocation,
      showEditOptions: showingEditOptions,
      isEmbedded: isEmbedded,
      documentsDirectory: documentsDirectory,
      editFunction: () {},
      backgroundColor: backgroundColor);
  }
}