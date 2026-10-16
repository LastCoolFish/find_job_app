import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/PlaceholderView.dart';
import 'package:find_job_app/features/settings/presentation/pages/SettingsPage.dart';

/// Profile tab. Skeleton for now; the gear button opens SettingsPage.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FindJobAppBar(
        actions: [
          IconButton(
            onPressed: () => _openSettings(context),
            tooltip: 'Настройки',
            icon: const Icon(Symbols.settings, size: 28, weight: 600),
          ),
        ],
      ),
      body: const PlaceholderView(
        icon: Symbols.person,
        title: 'Профиль',
        subtitle: 'Скоро здесь появятся ваши данные и избранное',
      ),
    );
  }
}
