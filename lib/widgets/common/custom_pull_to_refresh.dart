import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Custom Scissors Pull to Refresh Indicator
class CustomPullToRefresh extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  State<CustomPullToRefresh> createState() => _CustomPullToRefreshState();
}

class _CustomPullToRefreshState extends State<CustomPullToRefresh> {
  double _pullOffset = 0.0;
  bool _isRefreshing = false;
  static const double _refreshTriggerOffset = 75.0;

  @override
  Widget build(BuildContext context) {
    final progress = (_pullOffset / _refreshTriggerOffset).clamp(0.0, 1.0);

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isRefreshing) return false;

        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          // If pulling down at the top of the scrollable (pixels < 0)
          if (metrics.pixels < 0) {
            setState(() {
              _pullOffset = -metrics.pixels;
            });
          } else if (_pullOffset > 0) {
            setState(() {
              _pullOffset = 0.0;
            });
          }
        } else if (notification is ScrollEndNotification) {
          if (_pullOffset >= _refreshTriggerOffset) {
            _triggerRefresh();
          } else {
            setState(() {
              _pullOffset = 0.0;
            });
          }
        }
        return false;
      },
      child: Stack(
        children: [
          // Background animated scissors loading header
          if (_pullOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _isRefreshing ? 65 : _pullOffset,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedScissors(
                  progress: progress,
                  isRefreshing: _isRefreshing,
                ),
              ),
            ),

          // Main scrollable child with offset animation
          AnimatedContainer(
            duration: _pullOffset == 0 ? const Duration(milliseconds: 250) : Duration.zero,
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0,
              _isRefreshing ? 65.0 : _pullOffset,
              0,
            ),
            child: widget.child,
          ),
        ],
      ),
    );
  }

  Future<void> _triggerRefresh() async {
    setState(() {
      _isRefreshing = true;
      _pullOffset = 0.0;
    });

    try {
      await widget.onRefresh();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isRefreshing = false;
      });
    }
  }
}

// ─── Scissors Painter & Widget ──────────────────────────────────────────────

class AnimatedScissors extends StatefulWidget {
  final double progress;
  final bool isRefreshing;
  const AnimatedScissors({
    super.key,
    required this.progress,
    required this.isRefreshing,
  });

  @override
  State<AnimatedScissors> createState() => _AnimatedScissorsState();
}

class _AnimatedScissorsState extends State<AnimatedScissors>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _animation = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isRefreshing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedScissors oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRefreshing && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isRefreshing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final currentAngle = widget.isRefreshing
            ? _animation.value
            : (0.1 + 0.4 * widget.progress);

        return CustomPaint(
          size: const Size(50, 50),
          painter: ScissorsPainter(
            angle: currentAngle,
            color: kPrimary,
          ),
        );
      },
    );
  }
}

class ScissorsPainter extends CustomPainter {
  final double angle; // angle of openness in radians
  final Color color;

  ScissorsPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Save canvas, translate to center
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Draw Blade 1 (rotated by -angle/2)
    canvas.save();
    canvas.rotate(-angle / 2);
    // Blade tip line going upwards
    canvas.drawLine(Offset.zero, const Offset(-4, -22), paint);
    // Handle ring going downwards
    canvas.drawCircle(const Offset(5, 12), 6.5, paint);
    canvas.restore();

    // Draw Blade 2 (rotated by angle/2)
    canvas.save();
    canvas.rotate(angle / 2);
    // Blade tip line going upwards
    canvas.drawLine(Offset.zero, const Offset(4, -22), paint);
    // Handle ring going downwards
    canvas.drawCircle(const Offset(-5, 12), 6.5, paint);
    canvas.restore();

    // Pivot pin
    canvas.drawCircle(Offset.zero, 2.5, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScissorsPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
  }
}
