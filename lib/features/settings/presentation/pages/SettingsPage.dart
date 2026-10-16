import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/PlaceholderView.dart';

/// Settings screen, opened from the gear button on ProfilePage.
/// Skeleton for now.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBodyBehindAppBar: true,
      // Back arrow is added by AppBar automatically, since this screen is pushed.
      appBar: FindJobAppBar(title: 'Настройки'),
      body: PlaceholderView(
        icon: Symbols.settings,
        title: 'Настройки',
        subtitle: 'Скоро здесь можно будет выбрать тему и другие параметры',
      ),
    );
  }
}
