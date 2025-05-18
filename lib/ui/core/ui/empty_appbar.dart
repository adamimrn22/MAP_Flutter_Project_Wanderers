import 'package:flutter/material.dart';

class EmptyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmptyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: const Color(0xFF8E4A58));
  }

  @override
  Size get preferredSize => Size(0.0, 0.0);
}
