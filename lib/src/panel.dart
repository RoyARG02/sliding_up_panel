/*
Name: Akshath Jain
Date: 3/18/2019 - 4/2/2020
Purpose: Defines the sliding_up_panel widget
Copyright: © 2020, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/physics.dart';

enum SlideDirection {
  UP,
  DOWN,
}

enum PanelState { OPEN, CLOSED }

class SlidingUpPanel extends StatefulWidget {
  /// The Widget that slides into view. When the
  /// panel is collapsed and if [collapsed] is null,
  /// then top portion of this Widget will be displayed;
  /// otherwise, [collapsed] will be displayed overtop
  /// of this Widget. If [panel] and [panelBuilder] are both non-null,
  /// [panel] will be used.
  final Widget panel;

  /// WARNING: This feature is still in beta and is subject to change without
  /// notice. Stability is not gauranteed. Provides a [ScrollController] and
  /// [ScrollPhysics] to attach to a scrollable object in the panel that links
  /// the panel position with the scroll position. Useful for implementing an
  /// infinite scroll behavior. If [panel] and [panelBuilder] are both non-null,
  /// [panel] will be used.
  final Widget Function(ScrollController sc) panelBuilder;

  /// The Widget displayed overtop the [panel] when collapsed.
  /// This fades out as the panel is opened.
  final Widget collapsed;

  /// The Widget that lies underneath the sliding panel.
  /// This Widget automatically sizes itself
  /// to fill the screen.
  final Widget body;

  /// Optional persistent widget that floats above the [panel] and attaches
  /// to the top of the [panel]. Content at the top of the panel will be covered
  /// by this widget. Add padding to the bottom of the `panel` to
  /// avoid coverage.
  final Widget header;

  /// Optional persistent widget that floats above the [panel] and
  /// attaches to the bottom of the [panel]. Content at the bottom of the panel
  /// will be covered by this widget. Add padding to the bottom of the `panel`
  /// to avoid coverage.
  final Widget footer;

  /// The height of the sliding panel when fully collapsed.
  final double minHeight;

  /// The height of the sliding panel when fully open.
  final double maxHeight;

  /// A point between [minHeight] and [maxHeight] that the panel snaps to
  /// while animating. A fast swipe on the panel will disregard this point
  /// and go directly to the open/close position. This value is represented as a
  /// percentage of the total animation distance ([maxHeight] - [minHeight]),
  /// so it must be between 0.0 and 1.0, exclusive.
  final double snapPoint;

  /// A border to draw around the sliding panel sheet.
  final Border border;

  /// If non-null, the corners of the sliding panel sheet are rounded by this [BorderRadiusGeometry].
  final BorderRadiusGeometry borderRadius;

  /// A list of shadows cast behind the sliding panel sheet.
  final List<BoxShadow> boxShadow;

  /// The color to fill the background of the sliding panel sheet.
  final Color color;

  /// The amount to inset the children of the sliding panel sheet.
  final EdgeInsetsGeometry padding;

  /// Empty space surrounding the sliding panel sheet.
  final EdgeInsetsGeometry margin;

  /// Set to false to not to render the sheet the [panel] sits upon.
  /// This means that only the [body], [collapsed], and the [panel]
  /// Widgets will be rendered.
  /// Set this to false if you want to achieve a floating effect or
  /// want more customization over how the sliding panel
  /// looks like.
  final bool renderPanelSheet;

  /// Set to false to disable the panel from snapping open or closed.
  final bool panelSnapping;

  /// This flag is deprecated. Use either [animationController] to give a custom
  /// animation or use [SlidingUpPanel.of] to control the state of the panel.
  @Deprecated(
      'Use animationController to explicitly provide an optional animation controller with custom duration'
      'To control the panel, obtain a reference to the state of the panel using SlidingUpPanel.of()')
  final PanelController controller;

  /// Controls the animation of the panel.
  final AnimationController animationController;

  /// The duration of animation when opening or closing the panel.
  /// Defaults to `Duration(milliseconds: 300)`.
  final Duration animationDuration;

  /// The curve for animating panel when it is opened or expanded.
  /// Defaults to [Curves.linear].
  final Curve expandCurve;

  /// The curve for animating panel when it is closed or collapsed.
  /// Defaults to [Curves.decelerate].
  final Curve collapseCurve;

  /// If non-null, shows a darkening shadow over the [body] as the panel slides open.
  final bool backdropEnabled;

  /// Shows a darkening shadow of this [Color] over the [body] as the panel slides open.
  final Color backdropColor;

  /// The opacity of the backdrop when the panel is fully open.
  /// This value can range from 0.0 to 1.0 where 0.0 is completely transparent
  /// and 1.0 is completely opaque.
  final double backdropOpacity;

  /// Flag that indicates whether or not tapping the
  /// backdrop closes the panel. Defaults to true.
  final bool backdropTapClosesPanel;

  /// If non-null, this callback
  /// is called as the panel slides around with the
  /// current position of the panel. The position is a double
  /// between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is fully open.
  final void Function(double position) onPanelSlide;

  /// If non-null, this callback is called when the
  /// panel is fully opened
  final VoidCallback onPanelOpened;

  /// If non-null, this callback is called when the panel
  /// is fully collapsed.
  final VoidCallback onPanelClosed;

  /// If non-null and true, the SlidingUpPanel exhibits a
  /// parallax effect as the panel slides up. Essentially,
  /// the body slides up as the panel slides up.
  final bool parallaxEnabled;

  /// Allows for specifying the extent of the parallax effect in terms
  /// of the percentage the panel has slid up/down. Recommended values are
  /// within 0.0 and 1.0 where 0.0 is no parallax and 1.0 mimics a
  /// one-to-one scrolling effect. Defaults to a 10% parallax.
  final double parallaxOffset;

  /// Allows toggling of the draggability of the SlidingUpPanel.
  /// Set this to false to prevent the user from being able to drag
  /// the panel up and down. Defaults to true.
  final bool isDraggable;

  /// Either SlideDirection.UP or SlideDirection.DOWN. Indicates which way
  /// the panel should slide. Defaults to UP. If set to DOWN, the panel attaches
  /// itself to the top of the screen and is fully opened when the user swipes
  /// down on the panel.
  final SlideDirection slideDirection;

  /// The default state of the panel; either PanelState.OPEN or PanelState.CLOSED.
  /// This value defaults to PanelState.CLOSED which indicates that the panel is
  /// in the closed position and must be opened. PanelState.OPEN indicates that
  /// by default the Panel is open and must be swiped closed by the user.
  final PanelState defaultPanelState;

  SlidingUpPanel(
      {Key key,
      this.panel,
      this.panelBuilder,
      this.body,
      this.collapsed,
      this.minHeight = 100.0,
      this.maxHeight = 500.0,
      this.snapPoint,
      this.border,
      this.borderRadius,
      this.boxShadow = const <BoxShadow>[
        BoxShadow(
          blurRadius: 8.0,
          color: Color.fromRGBO(0, 0, 0, 0.25),
        )
      ],
      this.color = Colors.white,
      this.padding,
      this.margin,
      this.renderPanelSheet = true,
      this.panelSnapping = true,
      this.controller,
      this.animationController,
      this.animationDuration,
      this.expandCurve = Curves.linear,
      this.collapseCurve = Curves.decelerate,
      this.backdropEnabled = false,
      this.backdropColor = Colors.black,
      this.backdropOpacity = 0.5,
      this.backdropTapClosesPanel = true,
      this.onPanelSlide,
      this.onPanelOpened,
      this.onPanelClosed,
      this.parallaxEnabled = false,
      this.parallaxOffset = 0.1,
      this.isDraggable = true,
      this.slideDirection = SlideDirection.UP,
      this.defaultPanelState = PanelState.CLOSED,
      this.header,
      this.footer})
      : assert(panel != null || panelBuilder != null),
        assert(0 <= backdropOpacity && backdropOpacity <= 1.0),
        assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0),
        super(key: key);

  /// The state from the closest instance of SlidingUpPanel that encloses the
  /// given context.
  ///
  /// Typically used to control the state of the panel.
  ///
  /// If there is no [SlidingUpPanel] in scope, then this will throw an exception.
  static SlidingUpPanelState of(BuildContext context) {
    assert(context != null);
    SlidingUpPanelState result =
        context.findAncestorStateOfType<SlidingUpPanelState>();
    if (result != null) return result;
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
          'SlidingUpPanel.of() called with a context that does not contain a SlidingUpPanel.'),
      ErrorDescription(
          'No SlidingUpPanel ancestor could be found starting from the context that was passed to SlidingUpPanel.of(). '
          'This usually happens when the context provided is from the same StatefulWidget as that '
          'whose build function actually creates the SlidingUpPanel widget being sought.'),
      ErrorHint(
          'There are several ways to avoid this problem. The simplest is to use a Builder to get a '
          'context that is "under" the SlidingUpPanel.'),
      ErrorHint(
          'A more efficient solution is to split your build function into several widgets. This '
          'introduces a new context from which you can obtain the SlidingUpPanel. In this solution, '
          'you would have an outer widget that creates the SlidingUpPanel populated by instances of '
          'your new inner widgets, and then in these inner widgets you would use SlidingUpPanel.of().\n'
          'A less elegant but more expedient solution is assign a GlobalKey to the SlidingUpPanel, '
          'then use the key.currentState property to obtain the SlidingUpPanelState rather than '
          'using the SlidingUpPanel.of() function.'),
      context.describeElement('The context used was')
    ]);
  }

  @override
  SlidingUpPanelState createState() => SlidingUpPanelState();
}

class SlidingUpPanelState extends State<SlidingUpPanel>
    with SingleTickerProviderStateMixin {
  AnimationController _ac;
  ScrollController _sc;
  VelocityTracker _vt = VelocityTracker();

  bool _scrollingEnabled = false;
  bool _isPanelVisible = true;

  @override
  void initState() {
    super.initState();

    _ac = widget.animationController ??
        AnimationController(
            vsync: this,
            duration:
                widget.animationDuration ?? const Duration(milliseconds: 300),
            value: widget.defaultPanelState == PanelState.CLOSED
                ? 0.0
                : 1.0 //set the default panel state (i.e. set initial value of _ac)
            )
      ..addListener(() {
        if (widget.onPanelSlide != null) widget.onPanelSlide(_ac.value);

        if (widget.onPanelOpened != null && _ac.value == 1.0)
          widget.onPanelOpened();

        if (widget.onPanelClosed != null && _ac.value == 0.0)
          widget.onPanelClosed();
      });

    // prevent the panel content from being scrolled only if the widget is
    // draggable and panel scrolling is enabled
    _sc = new ScrollController();
    _sc.addListener(() {
      if (widget.isDraggable && !_scrollingEnabled) _sc.jumpTo(0);
    });

    /// Depracation leftover
    widget.controller?._addState(this);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.slideDirection == SlideDirection.UP
          ? Alignment.bottomCenter
          : Alignment.topCenter,
      children: <Widget>[
        //make the back widget take up the entire back side
        widget.body != null
            ? AnimatedBuilder(
                animation: _ac,
                builder: (context, child) {
                  return Positioned(
                    top: widget.parallaxEnabled ? _getParallax() : 0.0,
                    child: child,
                  );
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: widget.body,
                ),
              )
            : Container(),

        //the backdrop to overlay on the body
        !widget.backdropEnabled
            ? Container()
            : GestureDetector(
                onVerticalDragEnd: widget.backdropTapClosesPanel
                    ? (DragEndDetails dets) {
                        // only trigger a close if the drag is towards panel close position
                        if ((widget.slideDirection == SlideDirection.UP
                                    ? 1
                                    : -1) *
                                dets.velocity.pixelsPerSecond.dy >
                            0) close();
                      }
                    : null,
                onTap: widget.backdropTapClosesPanel ? () => close() : null,
                child: AnimatedBuilder(
                    animation: _ac,
                    builder: (context, _) {
                      return Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,

                        //set color to null so that touch events pass through
                        //to the body when the panel is closed, otherwise,
                        //if a color exists, then touch events won't go through
                        color: _ac.value == 0.0
                            ? null
                            : widget.backdropColor.withOpacity(
                                widget.backdropOpacity * _ac.value),
                      );
                    }),
              ),

        //the actual sliding part
        !_isPanelVisible
            ? Container()
            : _gestureHandler(
                child: AnimatedBuilder(
                  animation: _ac,
                  builder: (context, child) {
                    return Container(
                      height:
                          _ac.value * (widget.maxHeight - widget.minHeight) +
                              widget.minHeight,
                      margin: widget.margin,
                      padding: widget.padding,
                      decoration: widget.renderPanelSheet
                          ? BoxDecoration(
                              border: widget.border,
                              borderRadius: widget.borderRadius,
                              boxShadow: widget.boxShadow,
                              color: widget.color,
                            )
                          : null,
                      child: child,
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      //open panel
                      Positioned(
                          top: widget.slideDirection == SlideDirection.UP
                              ? 0.0
                              : null,
                          bottom: widget.slideDirection == SlideDirection.DOWN
                              ? 0.0
                              : null,
                          width: MediaQuery.of(context).size.width -
                              (widget.margin != null
                                  ? widget.margin.horizontal
                                  : 0) -
                              (widget.padding != null
                                  ? widget.padding.horizontal
                                  : 0),
                          child: Container(
                            height: widget.maxHeight,
                            child: widget.panel != null
                                ? widget.panel
                                : widget.panelBuilder(_sc),
                          )),

                      // header
                      widget.header != null
                          ? Positioned(
                              top: widget.slideDirection == SlideDirection.UP
                                  ? 0.0
                                  : null,
                              bottom:
                                  widget.slideDirection == SlideDirection.DOWN
                                      ? 0.0
                                      : null,
                              child: widget.header,
                            )
                          : Container(),

                      // footer
                      widget.footer != null
                          ? Positioned(
                              top: widget.slideDirection == SlideDirection.UP
                                  ? null
                                  : 0.0,
                              bottom:
                                  widget.slideDirection == SlideDirection.DOWN
                                      ? null
                                      : 0.0,
                              child: widget.footer)
                          : Container(),

                      // collapsed panel
                      Positioned(
                        top: widget.slideDirection == SlideDirection.UP
                            ? 0.0
                            : null,
                        bottom: widget.slideDirection == SlideDirection.DOWN
                            ? 0.0
                            : null,
                        width: MediaQuery.of(context).size.width -
                            (widget.margin != null
                                ? widget.margin.horizontal
                                : 0) -
                            (widget.padding != null
                                ? widget.padding.horizontal
                                : 0),
                        child: Container(
                          height: widget.minHeight,
                          child: widget.collapsed == null
                              ? Container()
                              : FadeTransition(
                                  opacity:
                                      Tween(begin: 1.0, end: 0.0).animate(_ac),

                                  // if the panel is open ignore pointers (touch events) on the collapsed
                                  // child so that way touch events go through to whatever is underneath
                                  child: IgnorePointer(
                                      ignoring: isPanelOpen,
                                      child: widget.collapsed),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  @override
  void dispose() {
    _ac.dispose();
    _sc.dispose();
    super.dispose();
  }

  double _getParallax() {
    if (widget.slideDirection == SlideDirection.UP)
      return -_ac.value *
          (widget.maxHeight - widget.minHeight) *
          widget.parallaxOffset;
    else
      return _ac.value *
          (widget.maxHeight - widget.minHeight) *
          widget.parallaxOffset;
  }

  // returns a gesture detector if panel is used
  // and a listener if panelBuilder is used.
  // this is because the listener is designed only for use with linking the scrolling of
  // panels and using it for panels that don't want to linked scrolling yields odd results
  Widget _gestureHandler({Widget child}) {
    if (!widget.isDraggable) return child;

    if (widget.panel != null) {
      return GestureDetector(
        onVerticalDragUpdate: (DragUpdateDetails dets) =>
            _onGestureSlide(dets.delta.dy),
        onVerticalDragEnd: (DragEndDetails dets) =>
            _onGestureEnd(dets.velocity),
        child: child,
      );
    }

    return Listener(
      onPointerDown: (PointerDownEvent p) =>
          _vt.addPosition(p.timeStamp, p.position),
      onPointerMove: (PointerMoveEvent p) {
        _vt.addPosition(p.timeStamp,
            p.position); // add current position for velocity tracking
        _onGestureSlide(p.delta.dy);
      },
      onPointerUp: (PointerUpEvent p) => _onGestureEnd(_vt.getVelocity()),
      child: child,
    );
  }

  // handles the sliding gesture
  void _onGestureSlide(double dy) {
    // only slide the panel if scrolling is not enabled
    if (!_scrollingEnabled) {
      if (widget.slideDirection == SlideDirection.UP)
        _ac.value -= dy / (widget.maxHeight - widget.minHeight);
      else
        _ac.value += dy / (widget.maxHeight - widget.minHeight);
    }

    // if the panel is open and the user hasn't scrolled, we need to determine
    // whether to enable scrolling if the user swipes up, or disable closing and
    // begin to close the panel if the user swipes down
    if (isPanelOpen && _sc.hasClients && _sc.offset <= 0) {
      setState(() {
        if (dy < 0) {
          _scrollingEnabled = true;
        } else {
          _scrollingEnabled = false;
        }
      });
    }
  }

  // handles when user stops sliding
  void _onGestureEnd(Velocity v) {
    double minFlingVelocity = 365.0;
    double kSnap = 8;

    //let the current animation finish before starting a new one
    if (_ac.isAnimating) return;

    // if scrolling is allowed and the panel is open, we don't want to close
    // the panel if they swipe up on the scrollable
    if (isPanelOpen && _scrollingEnabled) return;

    //check if the velocity is sufficient to constitute fling to end
    double visualVelocity =
        -v.pixelsPerSecond.dy / (widget.maxHeight - widget.minHeight);

    // reverse visual velocity to account for slide direction
    if (widget.slideDirection == SlideDirection.DOWN)
      visualVelocity = -visualVelocity;

    // get minimum distances to figure out where the panel is at
    double d2Close = _ac.value;
    double d2Open = 1 - _ac.value;
    double d2Snap = ((widget.snapPoint ?? 3) - _ac.value)
        .abs(); // large value if null results in not every being the min
    double minDistance = min(d2Close, min(d2Snap, d2Open));

    // check if velocity is sufficient for a fling
    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      // snapPoint exists
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity ||
            minDistance == d2Snap)
          _ac.fling(velocity: visualVelocity);
        else
          _flingPanelToPosition(widget.snapPoint, visualVelocity);

        // no snap point exists
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);

        // panel snapping disabled
      } else {
        _ac.animateTo(
          _ac.value + visualVelocity * 0.16,
          duration: widget.animationDuration,
          curve: widget.collapseCurve,
        );
      }

      return;
    }

    // check if the controller is already halfway there
    if (widget.panelSnapping) {
      if (minDistance == d2Close) {
        close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.snapPoint, visualVelocity);
      } else {
        open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final Simulation simulation = SpringSimulation(
        SpringDescription.withDampingRatio(
          mass: 1.0,
          stiffness: 500.0,
          ratio: 1.0,
        ),
        _ac.value,
        targetPos,
        velocity);

    _ac.animateWith(simulation);
  }

  /// Closes the sliding panel to its collapsed state (i.e. to [SlidingUpPanel.minHeight]).
  ///
  /// See [SlidingUpPanel.of] for information about how to obtain the [SlidingUpPanelState].
  Future<void> close() {
    return _ac.fling(velocity: -1.0);
  }

  /// Opens the sliding panel fully (i.e. to the [SlidingUpPanel.maxHeight])
  ///
  /// See [SlidingUpPanel.of] for information about how to obtain the [SlidingUpPanelState].
  Future<void> open() {
    return _ac.fling(velocity: 1.0);
  }

  /// Hides the sliding panel (i.e. is invisible)
  ///
  /// See [SlidingUpPanel.of] for information about how to obtain the [SlidingUpPanelState].
  Future<void> hide() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = false;
      });
    });
  }

  /// Shows the sliding panel in its collapsed state (i.e. "un-hide" the sliding panel).
  ///
  /// See [SlidingUpPanel.of] for information about how to obtain the [SlidingUpPanelState].
  Future<void> show() {
    return _ac.fling(velocity: -1.0).then((x) {
      setState(() {
        _isPanelVisible = true;
      });
    });
  }

  /// Animates the panel position to the value.
  ///
  /// The value must between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is completely open.
  ///
  /// Can optionally specify a duration which overrides [SlidingUpPanel.animationDuration],
  /// and a curve which overrides [SlidingUpPanel.expandCurve].
  Future<void> animatePanelToPosition(double value,
      {Duration duration, Curve curve}) {
    assert(0.0 <= value && value <= 1.0);
    return _ac.animateTo(value,
        duration: duration ?? widget.animationDuration,
        curve: curve ?? widget.expandCurve);
  }

  /// Animates the panel position to the snap point.
  ///
  /// Requires that [SlidingUpPanel.snapPoint] property is not null.
  ///
  /// Can optionally specify a duration which overrides [SlidingUpPanel.animationDuration],
  /// and a curve which overrides [SlidingUpPanel.expandCurve].
  //! NOTE: This feature is still in beta and may have some problems.
  //! Please open an issue on GitHub if you encounter something unexpected.
  Future<void> animatePanelToSnapPoint({Duration duration, Curve curve}) {
    assert(widget.snapPoint != null);
    return _ac.animateTo(widget.snapPoint,
        duration: duration ?? widget.animationDuration,
        curve: curve ?? widget.expandCurve);
  }

  /// Evaluates to the current panel position (a value between 0.0 and 1.0) where 0.0 is closed and 1.0 is open.
  /// Any value assigned to this property must be between 0.0 and 1.0, inclusive.
  set panelPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    _ac.value = value;
  }

  /// Provides the current panel position, as the percentage offset from
  /// collapsed state between 0.0 and 1.0.
  double get panelPosition => _ac.value;

  /// Returns whether or not the panel is currently animating.
  bool get isPanelAnimating => _ac.isAnimating;

  /// Returns whether or not the panel is open.
  bool get isPanelOpen => _ac.value == 1.0;

  /// Returns whether or not the panel is collapsed.
  bool get isPanelClosed => _ac.value == 0.0;

  /// Returns whether or not the panel is shown/hidden.
  bool get isPanelShown => _isPanelVisible;
}

@Deprecated(
    'To control the panel, obtain a reference to the state of the panel using SlidingUpPanel.of()')
class PanelController {
  SlidingUpPanelState _panelState;

  void _addState(SlidingUpPanelState panelState) {
    this._panelState = panelState;
  }

  /// Determine if the panelController is attached to an instance
  /// of the SlidingUpPanel (this property must return true before any other
  /// functions can be used)
  bool get isAttached => _panelState != null;

  /// Closes the sliding panel to its collapsed state (i.e. to the  minHeight)
  Future<void> close() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.close();
  }

  /// Opens the sliding panel fully
  /// (i.e. to the maxHeight)
  Future<void> open() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.open();
  }

  /// Hides the sliding panel (i.e. is invisible)
  Future<void> hide() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.hide();
  }

  /// Shows the sliding panel in its collapsed state
  /// (i.e. "un-hide" the sliding panel)
  Future<void> show() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.show();
  }

  /// Animates the panel position to the value.
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToPosition(double value,
      {Duration duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    return _panelState.animatePanelToPosition(value,
        duration: duration, curve: curve);
  }

  /// Animates the panel position to the snap point
  /// Requires that the SlidingUpPanel snapPoint property is not null
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToSnapPoint(
      {Duration duration, Curve curve = Curves.linear}) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(_panelState.widget.snapPoint != null,
        "SlidingUpPanel snapPoint property must not be null");
    return _panelState.animatePanelToSnapPoint(
        duration: duration, curve: curve);
  }

  /// Sets the panel position (without animation).
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  set panelPosition(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    _panelState.panelPosition = value;
  }

  /// Gets the current panel position.
  /// Returns the % offset from collapsed state
  /// to the open state
  /// as a decimal between 0.0 and 1.0
  /// where 0.0 is fully collapsed and
  /// 1.0 is full open.
  double get panelPosition {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.panelPosition;
  }

  /// Returns whether or not the panel is
  /// currently animating.
  bool get isPanelAnimating {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.isPanelAnimating;
  }

  /// Returns whether or not the
  /// panel is open.
  bool get isPanelOpen {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.isPanelOpen;
  }

  /// Returns whether or not the
  /// panel is closed.
  bool get isPanelClosed {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.isPanelClosed;
  }

  /// Returns whether or not the
  /// panel is shown/hidden.
  bool get isPanelShown {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState.isPanelShown;
  }
}
