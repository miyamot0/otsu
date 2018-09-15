import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final bool outputToTerminal = true;

class SpeakerObject extends StatefulWidget {
  final Function emitSpeech;
  final Function toggleDebug;

  SpeakerObject(this.emitSpeech, this.toggleDebug);
  Image image;
  MediaQueryData mediaQueryData;

  double width;

  static const platform = const MethodChannel('com.example.dragdropexample/tts');
  /// Pipe text into platform-specific TTS
  /// 
  /// TODO: handle re-speaking
  Future<Null> speak(String output) async {
    debugPrint("speak: $output");
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
  final padding = 10.0;

  DateTime emitterPressTime;

  @override
  Widget build(BuildContext context) {
    if (widget.mediaQueryData == null)
    {
      widget.mediaQueryData = MediaQuery.of(context);

      widget.width = (widget.mediaQueryData.size.height - (2 * padding)) * 0.25;
    }

    if (widget.image == null)
    {
      widget.image = Image.asset('images/speaker.png',
                                                    height: widget.width,
                                                    fit: BoxFit.cover);
    }

    return Positioned(
            left: widget.mediaQueryData.size.width - widget.width - padding,
            top:  padding,
            child: GestureDetector(onTapDown: pressSpeechEmitterTest,
                                   onTapUp: releaseSpeechEmitterTest,
                                   onTapCancel: cancelActionRedraw,
                                   child: Container(width: widget.width,
                                      height: widget.width,
                                      child: Align(alignment: Alignment.center,
                                                    child: widget.image),
                                   decoration: BoxDecoration(color: Colors.transparent)),
                ),
          ); 
  }

  void cancelActionRedraw() {
    setState(()
    {
      widget.image = Image.asset('images/speaker.png',
                                  height: widget.width,
                                  color: Colors.black,
                                  fit: BoxFit.cover);
    });
  }

  /// Initial tap for emitter
  void pressSpeechEmitterTest(TapDownDetails deets) {
    setState(() 
    { 
      widget.image = Image.asset('images/speaker.png',
                                  height: widget.width,
                                  color: Colors.greenAccent,
                                  fit: BoxFit.cover);
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
      widget.image = Image.asset('images/speaker.png',
                                  height: widget.width,
                                  color: Colors.black,
                                  fit: BoxFit.cover);
    });
  }

  void debugPrint(String toTerminal) {
    if (outputToTerminal == false) return;

    print("Speaker Object: $toTerminal");
  }
}
