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

AlertDialog showStartupWindow(BuildContext context) {
  const fontSize = 24.0;
  const paddingBottom = const EdgeInsets.only(bottom: 10);
  const textStyle = TextStyle(
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.normal,
    fontSize: fontSize,
  );
  const textStyleBold = TextStyle(
    fontWeight: FontWeight.bold,
    fontStyle: FontStyle.normal,
    fontSize: fontSize,
  );
  final dimension = MediaQuery.of(context).size.height * 0.75;

  return AlertDialog(
    title: Center(
      child: Text(
        "OpenAAC Project: (${InheritedAppState.of(context).appInfo.appName}:${InheritedAppState.of(context).appInfo.version})"
      ),
    ),
    content: Container(
      child: Wrap(
        alignment: WrapAlignment.start,
        children: <Widget> [
          Padding(
            padding: paddingBottom,
            child: Text(
              "This app is designed to be a free tool used alongside function-based communication training. This app is capable of using single icon and frame-based output (i.e., sentence strip).",
              style: textStyle,
            ),
          ),
          Padding(
            padding: paddingBottom,
            child: Text(
              "The board begins empty and you may edit all settings for the field holding the SPEAKER for ~5 seconds.",
              style: textStyleBold,
            ),
          ),
          Padding(
            padding: paddingBottom,
            child: Text(
              "Once in this mode you may add or reside/edit icons, include folders (i.e., pages), and even change the nature of the communication response.",
              style: textStyle,
            ),
          ),
        ],
      ),
    width: dimension,
    height: dimension,
    ),
  );
}