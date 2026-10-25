import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/config/EnvConfig.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/domain/entities/SkillDemandEntity.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';
import 'package:find_job_app/features/home/presentation/widgets/CompactCard.dart';
import 'package:find_job_app/features/home/presentation/widgets/HomeSection.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';
import 'package:find_job_app/features/orders/domain/repositories/OrdersRepository.dart';
import 'package:find_job_app/features/orders/presentation/pages/OrderDetailsPage.dart';
import 'package:find_job_app/features/orders/presentation/widgets/OrderCard.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/SkillVacanciesPage.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/VacancyDetailsPage.dart';

/// Main tab: picks for the user's profile, recently opened items, skills in
/// demand and the newest orders. Every block loads on its own, so one slow
/// or failed request doesn't hold up the rest. Pull down to reload all.
class HomePage extends StatefulWidget {
  /// Switches the bottom navigation tab (MainShell owns the index).
  final ValueChanged<int> onOpenTab;

  const HomePage({super.key, required this.onOpenTab});

  static const ordersTab = 2;
  static const profileTab = 3;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileRepository _profiles = sl<ProfileRepository>();
  final VacanciesRepository _vacancies = sl<VacanciesRepository>();
  final OrdersRepository _orders = sl<OrdersRepository>();
  final AnalyticsRepository _analytics = sl<AnalyticsRepository>();

  static const _picksCount = 10;
  static const _skillsCount = 15;
  static const _ordersCount = 3;

  /// Null data means the profile is empty, so there is nothing to pick by.
  late Future<Result<List<VacancyEntity>?>> _picks;
  late Future<List<Object>> _recent;
  late Future<Result<List<SkillDemandEntity>>> _skills;
  late Future<Result<List<OrderEntity>>> _freshOrders;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _picks = _loadPicks();
    _recent = _loadRecent();
    _skills = _analytics.getTopSkills(_skillsCount);
    _freshOrders = _orders.getOrders(limit: _ordersCount);
  }

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_picks, _recent, _skills, _freshOrders]);
  }

  /// With skills in the profile: vacancies for each of the first three skills
  /// (the API only matches vacancies that have *all* given skills, so one
  /// request per skill), merged and narrowed by grade and salary.
  /// Without skills: a plain search by the desired salary and grade.
  Future<Result<List<VacancyEntity>?>> _loadPicks() async {
    final profileResult = await _profiles.getProfileByUser(EnvConfig.currentUserId);
    final profile = switch (profileResult) {
      Success(:final data) => data,
      // No profile yet looks the same as an empty one.
      Failed() => null,
    };
    if (profile == null || _isEmpty(profile)) return const Success(null);

    if (profile.skills.isEmpty) {
      return _vacancies.getVacancies(
        filters: VacancyFilters(
          salaryMin: profile.desiredSalary,
          grade: profile.desiredGrade,
        ),
        limit: _picksCount,
      );
    }

    final results = await Future.wait([
      for (final skill in profile.skills.take(3))
        _vacancies.getVacanciesBySkills([skill.id]),
    ]);

    final seen = <int>{};
    final merged = <VacancyEntity>[];
    for (final result in results) {
      if (result case Failed(:final failure)) return Failed(failure);
      for (final vacancy in (result as Success<List<VacancyEntity>>).data) {
        if (seen.add(vacancy.id)) merged.add(vacancy);
      }
    }

    final fitting = merged.where((v) => _fits(v, profile)).toList();
    // Better to show something close than nothing at all.
    final picks = fitting.isNotEmpty ? fitting : merged;
    return Success(picks.take(_picksCount).toList());
  }

  static bool _isEmpty(ProfileEntity profile) =>
      profile.skills.isEmpty &&
      profile.desiredSalary == null &&
      profile.desiredGrade == null;

  /// Unknown grade or salary doesn't rule a vacancy out.
  static bool _fits(VacancyEntity vacancy, ProfileEntity profile) {
    final grade = profile.desiredGrade;
    final salary = profile.desiredSalary;
    final gradeOk = grade == null || vacancy.grade == null || vacancy.grade == grade;
    final salaryOk = salary == null || vacancy.salary == null || vacancy.salary! >= salary;
    return gradeOk && salaryOk;
  }

  /// History only has ids, so load every item. Ones that fail to load
  /// (e.g. removed from the site) are skipped.
  Future<List<Object>> _loadRecent() async {
    final history = await _analytics.getRecentlyViewed();
    final targets = switch (history) {
      Success(:final data) => data,
      Failed() => const <EventTarget>[],
    };

    final results = await Future.wait<Result<Object>>([
      for (final target in targets)
        switch (target) {
          VacancyTarget(:final id) => _vacancies.getVacancy(id),
          OrderTarget(:final id) => _orders.getOrder(id),
        },
    ]);
    return [
      for (final result in results)
        if (result case Success(:final data)) data,
    ];
  }

  void _openVacancy(VacancyEntity vacancy) => _push(VacancyDetailsPage(vacancy: vacancy));

  void _openOrder(OrderEntity order) => _push(OrderDetailsPage(order: order));

  void _push(Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const FindJobAppBar(icon: Symbols.home),
      body: RefreshIndicator(
        onRefresh: _refresh,
        // The page scrolls under the app bar, so show the circle below it.
        edgeOffset: insets.top,
        color: AppColors.accent,
        backgroundColor: AppColors.card,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: insets.top + 8, bottom: insets.bottom + 16),
          children: [
            _buildPicks(),
            _buildRecent(),
            _buildSkills(),
            _buildFreshOrders(),
          ],
        ),
      ),
    );
  }

  Widget _buildPicks() {
    return FutureBuilder<Result<List<VacancyEntity>?>>(
      future: _picks,
      builder: (context, snapshot) {
        const title = 'Подходит вам';
        if (snapshot.connectionState != ConnectionState.done) {
          return const HomeSection.loading(title: title);
        }
        final result = snapshot.data;
        if (result == null) return const HomeSection.error(title: title);

        return result.when(
          success: (vacancies) {
            if (vacancies == null) {
              return HomeSection(
                title: title,
                child: _FillProfileBanner(
                  onTap: () => widget.onOpenTab(HomePage.profileTab),
                ),
              );
            }
            if (vacancies.isEmpty) {
              return HomeSection.message(
                title: title,
                message: 'Пока ничего не нашлось под ваш профиль',
              );
            }
            return HomeSection(
              title: title,
              child: _HorizontalList(
                children: [
                  for (final vacancy in vacancies) _vacancyCard(vacancy),
                ],
              ),
            );
          },
          failure: (_) => const HomeSection.error(title: title),
        );
      },
    );
  }

  Widget _buildRecent() {
    return FutureBuilder<List<Object>>(
      future: _recent,
      builder: (context, snapshot) {
        final items = snapshot.data ?? const [];
        // Nothing to show while loading or when the history is empty:
        // the block just appears once there is something in it.
        if (items.isEmpty) return const SizedBox.shrink();

        return HomeSection(
          title: 'Недавно смотрели',
          child: _HorizontalList(
            children: [
              for (final item in items)
                switch (item) {
                  VacancyEntity() => _vacancyCard(item),
                  OrderEntity() => _orderCard(item),
                  _ => const SizedBox.shrink(),
                },
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkills() {
    return FutureBuilder<Result<List<SkillDemandEntity>>>(
      future: _skills,
      builder: (context, snapshot) {
        const title = 'Востребованные навыки';
        if (snapshot.connectionState != ConnectionState.done) {
          return const HomeSection.loading(title: title);
        }
        final result = snapshot.data;
        if (result == null) return const HomeSection.error(title: title);

        return result.when(
          success: (skills) => HomeSection(
            title: title,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final demand in skills)
                    ActionChip(
                      onPressed: () => _push(SkillVacanciesPage(skill: demand.skill)),
                      backgroundColor: AppColors.card,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      label: Text.rich(
                        TextSpan(
                          text: demand.skill.name,
                          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
                          children: [
                            TextSpan(
                              text: '  ${demand.vacancyCount}',
                              style: TextStyle(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          failure: (_) => const HomeSection.error(title: title),
        );
      },
    );
  }

  Widget _buildFreshOrders() {
    return FutureBuilder<Result<List<OrderEntity>>>(
      future: _freshOrders,
      builder: (context, snapshot) {
        const title = 'Свежие заказы';
        final showAll = TextButton(
          onPressed: () => widget.onOpenTab(HomePage.ordersTab),
          child: const Text('Все'),
        );
        if (snapshot.connectionState != ConnectionState.done) {
          return const HomeSection.loading(title: title);
        }
        final result = snapshot.data;
        if (result == null) return const HomeSection.error(title: title);

        return result.when(
          success: (orders) => HomeSection(
            title: title,
            action: showAll,
            child: Column(
              children: [
                for (final order in orders)
                  OrderCard(
                    order: order,
                    onTap: () => _openOrder(order),
                    onDetails: () => _openOrder(order),
                  ),
              ],
            ),
          ),
          failure: (_) => const HomeSection.error(title: title),
        );
      },
    );
  }

  Widget _vacancyCard(VacancyEntity vacancy) => CompactCard(
        author: vacancy.company.name,
        title: vacancy.jobTitle,
        platform: vacancy.platform,
        money: vacancy.salary,
        onTap: () => _openVacancy(vacancy),
      );

  Widget _orderCard(OrderEntity order) => CompactCard(
        author: order.customer.name,
        title: order.name,
        platform: order.platform,
        money: order.price,
        onTap: () => _openOrder(order),
      );
}

/// Row of [CompactCard]s that scrolls sideways.
class _HorizontalList extends StatelessWidget {
  final List<Widget> children;

  const _HorizontalList({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) => children[index],
      ),
    );
  }
}

/// Shown instead of picks when the profile has no skills, salary or grade.
class _FillProfileBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _FillProfileBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Symbols.person_edit, size: 36, color: AppColors.accent),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Заполните профиль',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Укажите навыки, грейд и зарплату, и здесь появятся подходящие вакансии',
                      style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(onPressed: onTap, child: const Text('Заполнить')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
