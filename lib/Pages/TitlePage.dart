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

class TitlePage extends StatefulWidget {
  TitlePageState createState() => new TitlePageState();
}

class TitlePageState extends State<TitlePage> with TickerProviderStateMixin {
  Random rng = new Random();
  double iconSize;

  static Paint textStroke = Paint()
    ..color = Colors.deepOrange
    ..strokeWidth = 10.0;

  static TextStyle textStyle = TextStyle(
    fontSize: 42.0,
    fontWeight: FontWeight.bold,
    foreground: textStroke,
  );

  Future<double> monitorLayout(Stream<double> mediaQueryWidth) async {
    await for (double width in mediaQueryWidth) {
      if (width > 0) {
        return width;
      } 
    }

    return -1;
  }

  @override
  Widget build(BuildContext context) {
    printDebug('TitlePage::build()');

    iconSize = (iconSize == null || iconSize == 0) ? MediaQuery.of(context).size.width / 12.0 : iconSize;

    return new Scaffold(
      body: Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 10.0
              ),
              child: FutureBuilder(
                future: monitorLayout(
                  Stream<double>.periodic(
                    Duration(milliseconds: 50), 
                    (_) => MediaQuery.of(context).size.width
                  ),
                ),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData && snapshot.data > 0) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Text(""),
                        AnimatedLetter('images/I.png', iconSize, rng.nextDouble()),
                        AnimatedLetter('images/C.png', iconSize, rng.nextDouble()),
                        AnimatedLetter('images/O.png', iconSize, rng.nextDouble()),
                        AnimatedLetter('images/N.png', iconSize, rng.nextDouble()),
                        Text(""),
                        AnimatedLetter('images/T.png', iconSize, rng.nextDouble()),
                        AnimatedLetter('images/A.png', iconSize, rng.nextDouble()),
                        AnimatedLetter('images/L.png', iconSize, rng.nextDouble()),
                        AnimatedLetter('images/K.png', iconSize, rng.nextDouble()),
                        Text(""),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              )
            ),
            Center(
              child: MaterialButton( 
                height: 40.0, 
                minWidth: 70.0, 
                color: Colors.redAccent, 
                textColor: Colors.white, 
                padding: EdgeInsets.all(20.0),
                child: Text("Load Communication Board",
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ), 
                onPressed: () {
                  Navigator.pushReplacementNamed(
                    context,
                    "/board"
                  );
                },
                splashColor: Colors.blueAccent,
              )
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text("Shawn Gilroy, Louisiana State University (2018-2019)\nBehavioral Engineering Lab\nMIT-Licensed (${InheritedAppState.of(context).appInfo.appName}:${InheritedAppState.of(context).appInfo.version})",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.lightBlueAccent,
    );
  }
}
