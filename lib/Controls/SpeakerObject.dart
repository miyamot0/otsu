/// Shawn Gilroy - 2018, MIT - Licensed
///
///

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SpeakerObject extends StatefulWidget {
  final Function emitSpeech;
  final Function toggleDebug;

  SpeakerObject(this.emitSpeech, this.toggleDebug);

  static const platform = const MethodChannel('com.example.dragdropexample/tts');

  /// Pipe text into platform-specific TTS
  /// 
  /// 
  Future<Null> speak(String output) async {
    //debugPrint("speak: $output");
    var sendMap = <String, dynamic> { 'output' : output }; 

    try {
      await platform.invokeMethod('speak', sendMap);
    } on PlatformException catch (e) {
      print('Exception: ${e.message}');
    }
  }

  @override
  State<StatefulWidget> createState() => new SpeakerObjectState();
}

class SpeakerObjectState extends State<SpeakerObject> {
  static const padding = 10.0;

  DateTime emitterPressTime;
  Image image, imageBase, imageActive;
  MediaQueryData mediaQueryData;
  double width;

  static const BoxDecoration box = BoxDecoration(color: Colors.transparent);

  @override
  Widget build(BuildContext context) {

    if (mediaQueryData == null)
    {
      mediaQueryData = MediaQuery.of(context);
      width = (mediaQueryData.size.height - (2 * padding)) * 0.25;
    }

    if (imageBase == null)
    {
      imageBase = Image.asset(
        'images/speaker.png',
        color: Colors.black,
        height: width,
        fit: BoxFit.cover
      );
    }

    if (imageActive == null)
    {
      imageActive = Image.asset(
        'images/speaker.png',
        color: Colors.greenAccent,
        height: width,
        fit: BoxFit.cover
      );
    }

    // default up to cached standard one
    image = imageBase;

    return Positioned(
      left: mediaQueryData.size.width - width - padding,
      top:  padding,
      child: GestureDetector(
        onTapDown: pressSpeechEmitterTest,
        onTapUp: releaseSpeechEmitterTest,
        onTapCancel: cancelActionRedraw,
        child: Container(
          width: width,
          height: width,
          child: Align(
            alignment: Alignment.center,
            child: image
          ),
          decoration: box
        ),
      ),
    ); 
  }

  void cancelActionRedraw() {
    setState(()
    {
      image = imageBase;
    });
  }

  /// Initial tap for emitter
  void pressSpeechEmitterTest(TapDownDetails deets) {
    setState(() 
    { 
      image = imageActive;
      emitterPressTime = DateTime.now(); 
    });
  }

  /// Determine how to handle interaction with emitter
  void releaseSpeechEmitterTest(TapUpDetails deets) {

    if (DateTime.now().difference(emitterPressTime).inSeconds < 5)
    {
      widget.emitSpeech();
    }
    else
    {
      widget.toggleDebug();
    }

    setState(()
    {
      image = imageBase;
    });
  }
}
