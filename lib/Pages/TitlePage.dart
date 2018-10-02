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

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:animated_background/animated_background.dart';
import 'package:animated_background/particles.dart';

import 'package:otsu/Controls/AnimatedLetter.dart';

class TitlePage extends StatefulWidget {

  TitlePageState createState() => new TitlePageState();
}

class TitlePageState extends State<TitlePage> with TickerProviderStateMixin {

  double pI = (22.0 / 7.0) / 180.0;
  Random rng = new Random();

  ParticleOptions particleOptions;
  Paint particlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  static Paint textStroke = Paint()
    ..color = Colors.deepOrange
    ..strokeWidth = 10.0;

  static TextStyle textStyle = TextStyle(
    fontSize: 42.0,
    fontWeight: FontWeight.bold,
    foreground: textStroke,
  );

  @override
  void dispose() {
    particleOptions = null;
    particlePaint = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('build call title');

    double iconSize = MediaQuery.of(context).size.width / 12.0;

    if (particleOptions == null)
    {
      particleOptions = ParticleOptions(
        image: Image.asset('images/color_bubbles.png'),
        baseColor: Colors.blue,
        spawnOpacity: 0.5,
        minOpacity: 0.4,
        maxOpacity: 0.8,
        spawnMinSpeed: 125.0,
        spawnMaxSpeed: 250.0,
        spawnMinRadius: 50.0,
        spawnMaxRadius: 50.0,
        particleCount: 30,
      );
    }

    return new Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: particleOptions,
          paint: particlePaint,
        ),
        vsync: this,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 10.0
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  AnimatedLetter('titleimages/F.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/A.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/S.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/T.png', iconSize, rng.nextDouble()),
                  Text(""),
                  AnimatedLetter('titleimages/T.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/A.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/L.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/K.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/E.png', iconSize, rng.nextDouble()),
                  AnimatedLetter('titleimages/R.png', iconSize, rng.nextDouble()),
                ],
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
              child: Text("Fast Talker (Flutter-port) was developed by Shawn Gilroy, \nLouisiana State University (2018) \nMIT-Licensed",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
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
