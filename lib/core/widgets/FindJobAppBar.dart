import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// App bar shared by all screens: rounded bottom corners and the "FindJob"
/// logo. Screens add their own buttons through [actions]. Pass [title] to
/// show plain text instead of the logo (e.g. "Настройки"); a back arrow
/// appears automatically on pushed screens.
///
/// Use it with `Scaffold(extendBodyBehindAppBar: true)` so the list scrolls
/// under the rounded corners.
class FindJobAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget> actions;
  final String? title;

  const FindJobAppBar({super.key, this.actions = const [], this.title});

  static const _logo = Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Symbols.person_search, size: 32, weight: 700),
      SizedBox(width: 10),
      Flexible(
        child: Text(
          'FindJob',
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      clipBehavior: Clip.antiAlias,
      title: title == null
          ? _logo
          : Text(title!, style: const TextStyle(fontWeight: FontWeight.w800)),
      actions: [...actions, if (actions.isNotEmpty) const SizedBox(width: 8)],
    );
  }
}
