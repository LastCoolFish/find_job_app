import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/PlaceholderView.dart';

/// Main tab. Skeleton for now.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      extendBodyBehindAppBar: true,
      appBar: FindJobAppBar(icon: Symbols.home),
      body: PlaceholderView(
        icon: Symbols.home,
        title: 'Главная',
        subtitle: 'Скоро здесь появится подборка вакансий и заказов',
      ),
    );
  }
}
