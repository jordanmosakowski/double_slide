import 'package:flutter/material.dart';

class MoveButton extends StatelessWidget {
  const MoveButton(this.onTap, this.icon, { 
    this.top, this.bottom, this.right, this.left,
    required this.iconSize,
    Key? key }) : super(key: key);
  final double? top, bottom, right, left;
  final VoidCallback onTap;
  final IconData icon;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      iconSize: iconSize,
      onPressed: onTap,
    );
  }
}