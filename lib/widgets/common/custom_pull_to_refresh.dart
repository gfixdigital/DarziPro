import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Premium sleek pull to refresh indicator wrapper
class CustomPullToRefresh extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const CustomPullToRefresh({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kPrimary,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 60,
      edgeOffset: 10,
      onRefresh: onRefresh,
      child: child,
    );
  }
}

