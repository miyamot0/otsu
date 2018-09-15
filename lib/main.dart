import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Controls/IconField.dart';
import 'Storage/IconDatabase.dart';

void main() async {

  IconDatabase iconDb = new IconDatabase();
  await iconDb.open();  

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight, 
    DeviceOrientation.landscapeLeft]).then((_)
  {
    runApp(new MainApp(iconDb: iconDb,));
  }); 
}

class MainApp extends StatefulWidget {
  MainApp({this.iconDb});

  final IconDatabase iconDb;

  @override
  ApplicationState createState() => ApplicationState(iconDb: iconDb);
}

class ApplicationState extends State<MainApp> {
  ApplicationState({this.iconDb});

  final IconDatabase iconDb;

  @override
  Widget build(BuildContext context) 
  {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(child: Scaffold(body: IconField(iconDb: iconDb,))),
    );
  }
}