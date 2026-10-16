import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// App bar shared by all screens: rounded bottom corners and a title with an
/// icon in front. By default it shows the "FindJob" logo; pass [title] and
/// [icon] to change them (`icon: null` hides the icon). Screens add their own
/// buttons through [actions]. A back arrow appears automatically on pushed
/// screens.
///
/// Use it with `Scaffold(extendBodyBehindAppBar: true)` so the list scrolls
/// under the rounded corners.
class FindJobAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData? icon;
  final List<Widget> actions;

  const FindJobAppBar({
    super.key,
    this.title = 'FindJob',
    this.icon = Symbols.person_search,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 32, weight: 700),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      actions: [...actions, if (actions.isNotEmpty) const SizedBox(width: 8)],
    );
  }
}
