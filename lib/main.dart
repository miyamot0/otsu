/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Controls/VisualFieldWidget.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]).then((_) {
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
  @override
  Widget build(BuildContext context) 
  {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      //showPerformanceOverlay: true,
      home: SafeArea(
        child: Scaffold(
          body: VisualFieldWidget(),
          resizeToAvoidBottomPadding: false,
        ),
      ),
    );
  }
}