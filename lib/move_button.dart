import 'package:flutter/material.dart';

class MoveButton extends StatelessWidget {
  const MoveButton(this.onTap, this.icon, { this.top, this.bottom, this.right, this.left, Key? key }) : super(key: key);
  final double? top, bottom, right, left;
  final VoidCallback onTap;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      right: right,
      left: left,
      child: IconButton(
        icon: Icon(icon),
        iconSize: 34,
        onPressed: onTap,
      )
    );
  }
}