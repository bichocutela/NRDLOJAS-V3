import 'package:flutter/material.dart';

class NrdMotion {
  static const Duration tap = Duration(milliseconds: 95);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 210);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}

class PressScale extends StatefulWidget {
  const PressScale({
    required this.child,
    super.key,
    this.onTap,
    this.scale = .965,
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
    this.offset = const Offset(0, .035),
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
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : widget.offset,
      duration: NrdMotion.medium,
      curve: NrdMotion.standard,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: NrdMotion.fast,
        curve: NrdMotion.standard,
        child: widget.child,
      ),
    );
  }
}

class NrdPageRoute<T> extends PageRouteBuilder<T> {
  NrdPageRoute({required WidgetBuilder builder})
      : super(
          transitionDuration: NrdMotion.medium,
          reverseTransitionDuration: NrdMotion.fast,
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: NrdMotion.standard);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(.035, .015),
                  end: Offset.zero,
                ).animate(curved),
                child: ScaleTransition(
                  scale: Tween<double>(begin: .985, end: 1).animate(curved),
                  child: child,
                ),
              ),
            );
          },
        );
}
