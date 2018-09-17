/// Shawn Gilroy - 2018, MIT - Licensed
///
///
/// based on:
/// https://github.com/tiagojencmartins/unicornspeeddial

import 'package:flutter/material.dart';

class AnimatedMenuItem extends FloatingActionButton {
  final FloatingActionButton currentButton;
  String labelText;

  AnimatedMenuItem(
  {
    this.currentButton,
    this.labelText,
  }) : assert(currentButton != null);

  Widget returnLabel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(
          color: Colors.black, 
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.all(10.0),
      child: Text(
        this.labelText,
        style: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return this.currentButton;
  }
}

class AnimatedMenuWidget extends StatefulWidget {
  final Icon parentButton;
  final Icon finalButtonIcon;
  final List<AnimatedMenuItem> childButtons;
  final Function onMainButtonPressed;
  final Object parentHeroTag;
  final bool isLeft;
  Function updateState;

  AnimatedMenuWidget({
    this.parentButton,
    this.childButtons,
    this.onMainButtonPressed,
    this.parentHeroTag = "parent",
    this.finalButtonIcon,
    this.isLeft = false,
  }) : assert(parentButton != null);

  _AnimatedMenuWidget createState() => _AnimatedMenuWidget();
}

class _AnimatedMenuWidget extends State<AnimatedMenuWidget> with TickerProviderStateMixin {
  AnimationController _animationController;

  bool isOpen = false;

  @override
  void initState() {
    this._animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
    );

    super.initState();

    widget.updateState = () {
      setState(() {});
    };
  }

  @override
  dispose() {
    this._animationController.dispose();
    super.dispose();
  }

  void mainActionButtonOnPressed() {
    if (this._animationController.isDismissed) {
      this._animationController.forward();
    } else {
      this._animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    FloatingActionButton mainFAB = FloatingActionButton(
      isExtended: false,
      heroTag: widget.parentHeroTag,
      backgroundColor: Colors.redAccent,
      onPressed: () 
      {
        mainActionButtonOnPressed();

        if (widget.onMainButtonPressed != null) 
        {
          widget.onMainButtonPressed();
        }
      },
      child: AnimatedBuilder(
        animation: this._animationController,
        builder: (BuildContext context, Widget child) {
          return Transform(
            transform: new Matrix4.rotationZ(
              this._animationController.value * 0.8
            ),
            alignment: FractionalOffset.center,
            child: new Icon(
              this._animationController.isDismissed
                ? widget.parentButton.icon
                : widget.finalButtonIcon == null
                ? Icons.settings
                : widget.finalButtonIcon.icon
              ),
          );
        })
      );

      List<Widget> childButtonsList = List.generate(widget.childButtons.length, (index) {
      double intervalValue = index == 0 ? 0.9 : ((widget.childButtons.length - index) / widget.childButtons.length) - 0.2;
      intervalValue = intervalValue < 0.0 ? (1 / index) * 0.5 : intervalValue;

      FloatingActionButton childFAB = FloatingActionButton(
        onPressed: () 
        {
          if (widget.childButtons[index].currentButton.onPressed != null) 
          {
            widget.childButtons[index].currentButton.onPressed();
          }

          this._animationController.reverse();
        },
        child: widget.childButtons[index].currentButton.child,
        heroTag: widget.childButtons[index].currentButton.heroTag,
        backgroundColor: widget.childButtons[index].currentButton.backgroundColor,
        mini: true,
        tooltip: widget.childButtons[index].currentButton.tooltip,
        key: widget.childButtons[index].currentButton.key,
        elevation: widget.childButtons[index].currentButton.elevation,
        foregroundColor: widget.childButtons[index].currentButton.foregroundColor,
        highlightElevation: widget.childButtons[index].currentButton.highlightElevation,
        isExtended: widget.childButtons[index].currentButton.isExtended,
        shape: widget.childButtons[index].currentButton.shape,
      );

      return Positioned(
        left: (!widget.isLeft) ? null : 8.0,
        right: (widget.isLeft) ? null : 8.0,
        bottom: ((widget.childButtons.length - index) * 55.0) + 15,
        child: !widget.isLeft ?
          Row(children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: this._animationController,
                curve: Interval(
                  intervalValue, 1.0, 
                  curve: Curves.linear,
                ),
              ),
              alignment: FractionalOffset.center,
              child: Container(
                padding: EdgeInsets.only(
                  right: 4.0,
                ),
                child: widget.childButtons[index].returnLabel(),
              ),
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: this._animationController,
                curve:
                Interval(
                  intervalValue, 1.0, 
                  curve: Curves.linear,
                ),
              ),
              alignment: FractionalOffset.center,
              child: childFAB,
            )
          ]) :
          Row(children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: this._animationController,
                curve:
                Interval(
                  intervalValue, 1.0, 
                  curve: Curves.linear,
                ),
              ),
              alignment: FractionalOffset.center,
              child: childFAB,
            ),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: this._animationController,
                curve: Interval(
                  intervalValue, 1.0, 
                  curve: Curves.linear,
                ),
              ),
              alignment: FractionalOffset.center,
              child: Container(
                padding: EdgeInsets.only(
                  left: 4.0,
                ),
                child: widget.childButtons[index].returnLabel(),
              ),
            ),
          ]),
        );
      });

      Container mainMenuWidget = Container(
        height: double.infinity,
        child: Stack(
          alignment: FractionalOffset.bottomRight,
          overflow: Overflow.visible,
          children: childButtonsList.toList()
            ..add(Positioned(
                right: null,
                bottom: null,
                child: mainFAB
            ),
          ),
        ),
      );

      return mainMenuWidget;
  }
}