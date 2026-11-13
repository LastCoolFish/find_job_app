import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_job_app/app/FindJobApp.dart';
import 'package:find_job_app/app/MainShell.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/domain/entities/EventTarget.dart';
import 'package:find_job_app/features/analytics/domain/entities/SkillDemandEntity.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';
import 'package:find_job_app/features/orders/domain/entities/CustomerEntity.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderFilters.dart';
import 'package:find_job_app/features/orders/domain/repositories/OrdersRepository.dart';
import 'package:find_job_app/features/vacancies/domain/entities/CompanyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';

void main() {
  testWidgets(
    'FindJob tabs, lists, filters and account preview work on mobile',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(() => sl.reset());
      sl.registerSingleton<VacanciesRepository>(_Vacancies());
      sl.registerSingleton<OrdersRepository>(_Orders());
      sl.registerSingleton<AnalyticsRepository>(_Analytics());
      sl.registerSingleton<ProfileRepository>(_Profile());

      await tester.pumpWidget(const FindJobApp());
      expect(find.text('Открываем FindJob'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Создать аккаунт'), findsOneWidget);
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextFormField).first,
        'startup@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'testpass123');
      await tester.tap(find.widgetWithText(FilledButton, 'Войти'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 120));
      final entrance = tester.widget<SlideTransition>(
        find
            .ancestor(
              of: find.byType(MainShell),
              matching: find.byType(SlideTransition),
            )
            .first,
      );
      expect(entrance.position.value.dy, inExclusiveRange(0, .08));
      await tester.pumpAndSettle();
      expect(find.text('Что ищешь?'), findsOneWidget);

      final vacanciesTile = find.widgetWithText(ListTile, 'Вакансии');
      await tester.ensureVisible(vacanciesTile);
      await tester.tap(vacanciesTile);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      final tabFade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.byType(IndexedStack),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(tabFade.opacity.value, inExclusiveRange(0, 1));
      await tester.pumpAndSettle();
      expect(find.text('C/C++ Developer'), findsOneWidget);
      await tester.tap(find.byTooltip('Фильтры'));
      await tester.pumpAndSettle();
      expect(find.text('Показать'), findsOneWidget);
      await tester.ensureVisible(find.text('Показать'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Показать'));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(NavigationDestination, 'Заказы'));
      await tester.pumpAndSettle();
      expect(
        find.text('Разработка B2B-сайта на WordPress для рынка России'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(NavigationDestination, 'Профиль'));
      await tester.pumpAndSettle();
      expect(find.text('startup@example.com'), findsOneWidget);
      expect(find.text('dev-profile'), findsOneWidget);
      await tester.tap(find.text('Выйти из аккаунта'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Войти или зарегистрироваться'));
      await tester.pumpAndSettle();
      final shortSwipe = await tester.startGesture(
        tester.getCenter(find.text('Создать аккаунт')),
      );
      await shortSwipe.moveBy(const Offset(0, -65));
      await tester.pump();
      expect(find.text('Регистрация'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      await shortSwipe.up();
      await tester.pumpAndSettle();
      expect(find.text('Регистрация'), findsNothing);
      await tester.fling(
        find.text('Создать аккаунт'),
        const Offset(0, -170),
        750,
      );
      await tester.pumpAndSettle();
      expect(find.text('Регистрация'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Создать аккаунт'));
      await tester.pumpAndSettle();
      expect(find.text('Введи электронную почту'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'name@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'testpass123');
      await tester.tap(find.widgetWithText(FilledButton, 'Создать аккаунт'));
      await tester.pumpAndSettle();
      expect(find.text('Режим просмотра'), findsOneWidget);
      await tester.tap(find.text('Выйти из аккаунта'));
      await tester.pumpAndSettle();
      expect(find.text('Войти или зарегистрироваться'), findsOneWidget);

      await tester.tap(find.text('Войти или зарегистрироваться'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Войти'));
      await tester.pumpAndSettle();
      expect(find.text('С возвращением!'), findsOneWidget);
      await tester.enterText(
        find.byType(TextFormField).first,
        'name@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'testpass123');
      await tester.tap(find.byTooltip('Показать пароль'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Скрыть пароль'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Войти'));
      await tester.pumpAndSettle();
      expect(find.text('name@example.com'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

// This test only implements repository calls made by the tab flow.
abstract class _UnusedCalls {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Vacancies extends _UnusedCalls implements VacanciesRepository {
  @override
  Future<Result<List<VacancyEntity>>> getVacancies({
    VacancyFilters filters = const VacancyFilters(),
    int offset = 0,
    int limit = 20,
  }) async => const Success([
    VacancyEntity(
      id: 1,
      jobTitle: 'C/C++ Developer',
      salary: null,
      description: '',
      place: 'Новосибирск',
      grade: 1,
      format: 'на месте',
      platform: 'habr',
      platformId: 1,
      siteHref: 'https://example.com',
      skills: [],
      company: CompanyEntity(
        id: 1,
        name: 'Eltex',
        rating: null,
        accreditation: true,
      ),
    ),
  ]);

  @override
  Future<Result<List<String>>> getPlatforms() async => const Success(['habr']);
}

class _Orders extends _UnusedCalls implements OrdersRepository {
  @override
  Future<Result<List<OrderEntity>>> getOrders({
    OrderFilters filters = const OrderFilters(),
    int offset = 0,
    int limit = 20,
  }) async => Success([
    OrderEntity(
      id: 1,
      name: 'Разработка B2B-сайта на WordPress для рынка России',
      description: 'Разработка сайта и SEO',
      price: 1000,
      publicationTimestamp: DateTime(2026, 10, 8),
      platform: 'kwork',
      platformId: 1,
      siteHref: 'https://example.com',
      customer: const CustomerEntity(
        id: 1,
        name: 'Заказчик',
        href: null,
        platform: 'kwork',
      ),
    ),
  ]);

  @override
  Future<Result<List<String>>> getPlatforms() async => const Success(['kwork']);
}

class _Analytics extends _UnusedCalls implements AnalyticsRepository {
  @override
  Future<Result<List<EventTarget>>> getRecentlyViewed({int limit = 10}) async =>
      const Success([]);

  @override
  Future<Result<List<SkillDemandEntity>>> getTopSkills(int count) async =>
      const Success([]);
}

class _Profile implements ProfileRepository {
  @override
  Future<Result<ProfileEntity>> getProfileByUser(int userId) async => Success(
    ProfileEntity(
      id: 1,
      userId: userId,
      username: 'dev-profile',
      name: null,
      desiredSalary: null,
      desiredFormat: null,
      desiredGrade: null,
      skills: [],
    ),
  );

  @override
  Future<Result<UserEntity>> getUser(int userId) async => Success(
    UserEntity(
      id: userId,
      email: 'profile@example.com',
      phone: null,
      role: 'user',
      createdAt: DateTime(2026),
      lastLoginAt: null,
    ),
  );
}
