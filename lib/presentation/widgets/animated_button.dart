import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedInteractiveItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool scaleOnHover;
  final bool scaleOnPress;

  const AnimatedInteractiveItem({
    super.key,
    required this.child,
    this.onTap,
    this.scaleOnHover = true,
    this.scaleOnPress = true,
  });

  @override
  State<AnimatedInteractiveItem> createState() => _AnimatedInteractiveItemState();
}

class _AnimatedInteractiveItemState extends State<AnimatedInteractiveItem> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget animated = widget.child;

    if (widget.scaleOnHover) {
      animated = animated.animate(target: _isHovered && !_isPressed ? 1 : 0).scale(
        end: const Offset(1.03, 1.03),
        duration: 150.ms,
        curve: Curves.easeOut,
      );
    }

    if (widget.scaleOnPress) {
      animated = animated.animate(target: _isPressed ? 1 : 0).scale(
        end: const Offset(0.95, 0.95),
        duration: 100.ms,
        curve: Curves.easeInOut,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => setState(() => _isPressed = true),
        onPointerUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onPointerCancel: (_) => setState(() => _isPressed = false),
        child: animated,
      ),
    );
  }
}
