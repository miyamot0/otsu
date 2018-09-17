/// Shawn Gilroy - 2018, MIT - Licensed
///
///
/// based on:
/// https://github.com/tiagojencmartins/unicornspeeddial

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class AnimatedMenuItem extends FloatingActionButton {
  final FloatingActionButton currentButton;
  String labelText;
  final double labelFontSize;
  final Color labelColor;
  final Color labelBackgroundColor;
  final Color labelShadowColor;
  final bool labelHasShadow;
  final bool hasLabel;

  AnimatedMenuItem({
    this.currentButton,
    this.labelText,
    this.labelFontSize = 14.0,
    this.labelColor,
    this.labelBackgroundColor,
    this.labelShadowColor,
    this.labelHasShadow = true,
    this.hasLabel = false})
  : assert(currentButton != null);

  Widget returnLabel() {
    return Container(
        decoration: BoxDecoration(
            boxShadow: this.labelHasShadow ? [
              new BoxShadow(
                color: this.labelShadowColor == null ? Color.fromRGBO(204, 204, 204, 1.0) : this.labelShadowColor,
                blurRadius: 3.0,
              ),
            ] : null,
            color: this.labelBackgroundColor == null ? Colors.white : this.labelBackgroundColor,
            borderRadius: BorderRadius.circular(1.0),
            border: Border.all(color: Colors.black, width: 1.0)),
        padding: EdgeInsets.all(10.0),
        child: Text(this.labelText,
            style: TextStyle(
                fontSize: this.labelFontSize,
                fontWeight: FontWeight.bold,
                color: this.labelColor == null ? Color.fromRGBO(119, 119, 119, 1.0) : this.labelColor)));
  }

  @override
  Widget build(BuildContext context) {
    return this.currentButton;
  }
}

class AnimatedMenuWidget extends StatefulWidget {
  final Icon parentButton;
  final Icon finalButtonIcon;
  //final bool hasBackground;
  final Color parentButtonBackground;
  final List<AnimatedMenuItem> childButtons;
  final int animationDuration;
  final double childPadding;
  final Color backgroundColor;
  final Function onMainButtonPressed;
  final Object parentHeroTag;
  final bool hasNotch;
  final bool isLeft;
  Function updateState;

  AnimatedMenuWidget({
    this.parentButton,
    this.parentButtonBackground,
    this.childButtons,
    this.onMainButtonPressed,
    this.backgroundColor = Colors.white30,
    this.parentHeroTag = "parent",
    this.finalButtonIcon,
    this.animationDuration = 180,
    this.childPadding = 4.0,
    this.isLeft = false,
    this.hasNotch = false})
  : assert(parentButton != null);

  _AnimatedMenuWidget createState() => _AnimatedMenuWidget();
}

class _AnimatedMenuWidget extends State<AnimatedMenuWidget> with TickerProviderStateMixin {
  AnimationController _animationController;
  AnimationController _parentController;

  bool isOpen = false;

  @override
  void initState() {
    this._animationController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: widget.animationDuration
      )
    );

    this._parentController = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: 200),
      value: 1.0
    );

    super.initState();

    widget.updateState = () {
      setState(() {});
    };
  }

  @override
  dispose() {
    this._animationController.dispose();
    this._parentController.dispose();
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
    AnimatedBuilder mainFAB = AnimatedBuilder(
      animation: this._parentController,
      builder: (BuildContext context, Widget child) {
        return Transform(
          transform: new Matrix4.diagonal3(
            vector.Vector3(
              _parentController.value,
              _parentController.value,
              _parentController.value
            )
          ),
          alignment: FractionalOffset.center,
          child: FloatingActionButton(
            isExtended: false,
            heroTag: widget.parentHeroTag,
            backgroundColor: widget.parentButtonBackground,
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
                      ? Icons.close
                      : widget.finalButtonIcon.icon
                    ),
                );
              })
            )
          );
      });

      AnimatedBuilder mainFloatingButton = AnimatedBuilder(
        animation: this._animationController,
        builder: (BuildContext context, Widget child) {
          return Transform.rotate(
            angle: this._animationController.value * 0.8, 
            child: mainFAB,
          );
        });

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
                      right: widget.childPadding,
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
                child: childFAB)
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
                    left: widget.childPadding,
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
                child: mainFloatingButton,
              ),
            ),
          ),
        );

      ScaleTransition modal = ScaleTransition(
        scale: CurvedAnimation(
          parent: this._animationController,
          curve: Interval(
            1.0, 1.0, 
            curve: Curves.linear,
          ),
        ),
        alignment: FractionalOffset.center,
        child: GestureDetector(
          onTap: mainActionButtonOnPressed,
          child: Container(
            color: widget.backgroundColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        ),
      );

      return mainMenuWidget;
  }
}