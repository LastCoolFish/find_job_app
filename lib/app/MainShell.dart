import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/features/auth/presentation/pages/AuthPage.dart';
import 'package:find_job_app/features/home/presentation/pages/HomePage.dart';
import 'package:find_job_app/features/orders/presentation/pages/OrdersPage.dart';
import 'package:find_job_app/features/profile/presentation/pages/ProfilePage.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/VacanciesPage.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialPreviewEmail});

  final String? initialPreviewEmail;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late String? _previewEmail = widget.initialPreviewEmail;
  late final _tabMotion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
    value: 1,
  );
  late final _tabEntrance = _tabMotion.drive(
    CurveTween(curve: Curves.easeOutCubic),
  );

  void _selectTab(int index) {
    if (index == _index) return;
    setState(() => _index = index);
    if (!MediaQuery.disableAnimationsOf(context)) {
      _tabMotion.forward(from: 0);
    } else {
      _tabMotion.value = 1;
    }
  }

  @override
  void dispose() {
    _tabMotion.dispose();
    super.dispose();
  }

  Future<void> _openAccount() async {
    final email = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const AuthPage()));
    if (mounted && email != null) setState(() => _previewEmail = email);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: FadeTransition(
      opacity: _tabEntrance,
      child: IndexedStack(
        index: _index,
        children: [
          HomePage(onOpenTab: _selectTab),
          const VacanciesPage(),
          const OrdersPage(),
          ProfilePage(
            previewEmail: _previewEmail,
            onOpenAccount: _openAccount,
            onExitPreview: () => setState(() => _previewEmail = null),
          ),
        ],
      ),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(15, 0, 15, 12),
      child: Align(
        heightFactor: 1,
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 490),
          child: Material(
            color: AppColors.card,
            elevation: 4,
            shadowColor: AppColors.primary.withValues(alpha: .20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
              side: BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: MediaQuery.removePadding(
              context: context,
              removeBottom: true,
              child: NavigationBar(
                height: 72,
                selectedIndex: _index,
                onDestinationSelected: _selectTab,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Symbols.home),
                    label: 'Главная',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.work),
                    label: 'Вакансии',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.assignment),
                    label: 'Заказы',
                  ),
                  NavigationDestination(
                    icon: Icon(Symbols.person),
                    label: 'Профиль',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
