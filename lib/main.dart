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

import 'resources.dart';

void main() {
  printDebug("main::main()");

  SystemChrome.setEnabledSystemUIOverlays([]).then((_) 
  {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, 
      DeviceOrientation.landscapeLeft]).then((_)
      {
        runApp(new MainApp());
      }); 
  });
}

class MainApp extends StatefulWidget {
  @override
  ApplicationState createState() => ApplicationState();
}

class ApplicationState extends State<MainApp> {
  IconDatabase iconDb;
  String dir;
  GlobalKey key = GlobalKey();
  PackageInfo appInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @protected
  Future<bool> loadAllReferences(BuildContext context) async {
    iconDb = new IconDatabase();
    await iconDb.open();
    
    dir = (await getApplicationDocumentsDirectory()).path;
    appInfo = await PackageInfo.fromPlatform();

    return true;
  }

  @override
  Widget build(BuildContext context) 
  {
    printDebug("ApplicationState::build()");

    return new FutureBuilder(
      future: loadAllReferences(context),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          return InheritedAppState(
            iconDb: iconDb,
            dir: dir,
            appInfo: appInfo,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              showPerformanceOverlay: false,
              initialRoute: '/',
              routes: {
                '/':      (context) => TitlePage(),
                '/board': (context) => VisualFieldWidget(
                    key: key
                ),
              },
            ),
          );
        } else {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
      },
    );
  }
}

