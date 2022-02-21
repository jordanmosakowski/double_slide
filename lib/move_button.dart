import 'package:flutter/material.dart';

class MoveButton extends StatelessWidget {
  const MoveButton(this.onTap, this.icon, {
    required this.iconSize, this.tooltip,
    Key? key }) : super(key: key);
  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  final String? tooltip;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      onPressed: onTap,
      tooltip: tooltip,
    );
  }
}