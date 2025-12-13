import 'package:flutter/material.dart';

class NextAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuPressed;
  final bool automaticallyImplyLeading;

  const NextAppBar({
    super.key,
    this.onMenuPressed,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Row(
        children: [
          Image.asset('assets/images/next_healt_logo.png', height: 20),
          const SizedBox(width: 10),
          const Text(
            'NEXT – Saúde One',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, size: 20),
          onPressed: onMenuPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
