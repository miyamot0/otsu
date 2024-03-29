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

class SpeakerObject extends StatefulWidget {
  final Function emitSpeech;
  final Function toggleDebug;

  SpeakerObject(this.emitSpeech, this.toggleDebug);

  static const platform = const MethodChannel('com.smallnstats.otsu/tts');

  /// Pipe text into platform-specific TTS
  /// 
  /// 
  Future<Null> speak(String output) async {
    var sendMap = <String, dynamic> { 'output' : output }; 

    try {
      await platform.invokeMethod('speak', sendMap);
    } on PlatformException catch (e) {
      printDebug('Exception: ${e.message}');
    }
  }

  @override
  State<StatefulWidget> createState() => new SpeakerObjectState();
}

class SpeakerObjectState extends State<SpeakerObject> {
  static const padding = 10.0;

  DateTime emitterPressTime;
  Image image,
        imageBase, 
        imageActive;
  MediaQueryData mediaQueryData;
  double width;

  static const BoxDecoration box = BoxDecoration(
    color: Colors.transparent
  );

  @override
  Widget build(BuildContext context) {
    mediaQueryData = mediaQueryData ?? MediaQuery.of(context);
    width = (mediaQueryData.size.height - (2 * padding)) * 0.25;

    imageBase = imageBase ?? Image.asset(
      'images/speaker.png',
      color: Colors.black,
      height: width,
      fit: BoxFit.cover
    );

    image = imageBase;

    imageActive = imageActive ?? Image.asset(
      'images/speaker.png',
      color: Colors.greenAccent,
      height: width,
      fit: BoxFit.cover
    );

    return AlignPositioned(
      alignment: Alignment.topRight,
      dy: padding,
      dx: -padding,
      child: GestureDetector(
        onTapDown: pressSpeechEmitterTest,
        onTapUp: releaseSpeechEmitterTest,
        onTapCancel: cancelActionRedraw,
        child: Container(
          width: width,
          height: width,
          child: image,
          decoration: box,
        ),
      ),
    );
  }

  /// Back to base graphics
  ///
  ///
  void cancelActionRedraw() {
    setState(()
    {
      image = imageBase;
    });
  }

  /// Initial tap for emitter
  /// 
  /// 
  void pressSpeechEmitterTest(TapDownDetails deets) {
    setState(() 
    { 
      image = imageActive;
      emitterPressTime = DateTime.now(); 
    });
  }

  /// Determine how to handle interaction with emitter
  /// 
  /// 
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
