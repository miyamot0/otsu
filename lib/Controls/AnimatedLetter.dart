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

class AnimatedLetter extends StatefulWidget {
  final String assetPath;
  final double assetSize;
  final double startRotation;

  AnimatedLetter(this.assetPath, this.assetSize, this.startRotation);

  @override
  State<StatefulWidget> createState() {
    return new AnimatedLetterState();
  }
}

class AnimatedLetterState extends State<AnimatedLetter> with SingleTickerProviderStateMixin {
  Animation<double> animation;
  AnimationController controller;

  Image image;

  double pI = (22.0 / 7.0) / 180.0;

  @override
  void dispose() {
    controller.stop();
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    animation = Tween<double>(
      begin: -35.0, 
      end: 35.0
    ).animate(controller);

    animation.addListener(() => setState(() { }));

    if (widget.startRotation < 0.5)
      controller.forward(from: widget.startRotation);
    else
      controller.reverse(from: widget.startRotation);

    animation.addStatusListener((status) {
      if(status == AnimationStatus.completed)
        controller.reverse();
      else if(status == AnimationStatus.dismissed)
        controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {

    if (image == null) {
      image = Image.asset(widget.assetPath,
        width: widget.assetSize,
        height: widget.assetSize,
      );
    }

    return Transform.rotate(
      child: image,
      angle: animation.value * pI,
    );
  }
}