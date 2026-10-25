import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Big "Открыть на сайте" button pinned to the bottom of a details screen.
class OpenOnSiteBar extends StatelessWidget {
  final VoidCallback onPressed;

  const OpenOnSiteBar({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Symbols.open_in_new),
          label: const Text('Открыть на сайте'),
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
