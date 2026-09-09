import 'package:flutter/material.dart';

class NrdMotion {
  static const Duration tap = Duration(milliseconds: 55);
  static const Duration fast = Duration(milliseconds: 90);
  static const Duration medium = Duration(milliseconds: 120);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutCubic;
}

class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    super.key,
    this.onTap,
    this.scale = .985,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final BorderRadius? borderRadius;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? widget.scale : 1,
      duration: NrdMotion.tap,
      curve: NrdMotion.standard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          onHighlightChanged: _setPressed,
          child: widget.child,
        ),
      ),
    );
  }
}

class MotionEntrance extends StatefulWidget {
  const MotionEntrance({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.offset = const Offset(0, .012),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<MotionEntrance> createState() => _MotionEntranceState();
}

class _MotionEntranceState extends State<MotionEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _visible = true;
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: NrdMotion.fast,
      curve: NrdMotion.standard,
      child: widget.child,
    );
  }
}

class NrdPageRoute<T> extends PageRouteBuilder<T> {
  NrdPageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: NrdMotion.fast,
          reverseTransitionDuration: NrdMotion.fast,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: NrdMotion.standard);
            return FadeTransition(opacity: curved, child: child);
          },
        );
}
