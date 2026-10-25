import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/features/home/presentation/pages/HomePage.dart';
import 'package:find_job_app/features/orders/presentation/pages/OrdersPage.dart';
import 'package:find_job_app/features/profile/presentation/pages/ProfilePage.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/VacanciesPage.dart';

/// Root screen with the bottom navigation bar:
/// Главная · Вакансии · Заказы · Профиль.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let the lists scroll under the bar, otherwise the rounded corners
      // would only reveal the plain scaffold background (same as the app bar).
      extendBody: true,
      // IndexedStack keeps both pages alive, so switching tabs doesn't
      // reload the lists or lose the scroll position.
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onOpenTab: (index) => setState(() => _index = index)),
          const VacanciesPage(),
          const OrdersPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (index) => setState(() => _index = index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Symbols.home),
              selectedIcon: Icon(Symbols.home, fill: 1),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Symbols.work),
              selectedIcon: Icon(Symbols.work, fill: 1),
              label: 'Вакансии',
            ),
            NavigationDestination(
              icon: Icon(Symbols.assignment),
              selectedIcon: Icon(Symbols.assignment, fill: 1),
              label: 'Заказы',
            ),
            NavigationDestination(
              icon: Icon(Symbols.person),
              selectedIcon: Icon(Symbols.person, fill: 1),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
