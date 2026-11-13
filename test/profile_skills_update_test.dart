import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/features/analytics/domain/entities/SkillDemandEntity.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';
import 'package:find_job_app/features/profile/presentation/pages/ProfilePage.dart';
import 'package:find_job_app/features/profile/presentation/widgets/SkillsSheet.dart';
import 'package:find_job_app/features/vacancies/domain/entities/SkillEntity.dart';

class FakeProfile implements ProfileRepository {
  static const skill = SkillEntity(id: 1, name: 'Dart');
  final profile = const ProfileEntity(
    id: 1,
    userId: 1,
    username: 'User',
    name: null,
    desiredSalary: null,
    desiredFormat: null,
    desiredGrade: null,
    skills: [],
  );
  @override
  Future<Result<ProfileEntity>> getProfileByUser(int id) async =>
      Success(profile);
  @override
  Future<Result<UserEntity>> getUser(int id) async => Success(
    UserEntity(
      id: 1,
      email: 'test@example.com',
      phone: null,
      role: 'user',
      createdAt: DateTime(2024),
      lastLoginAt: null,
    ),
  );
  @override
  Future<Result<List<SkillEntity>>> getSkills() async => const Success([skill]);
  @override
  Future<Result<ProfileEntity>> setSkills(int id, List<int> ids) async =>
      Success(profile);
}

class FakeAnalytics implements AnalyticsRepository {
  @override
  Future<Result<List<SkillDemandEntity>>> getTopSkills(int count) async =>
      const Success([]);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('saving skills closes sheet and updates profile', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() async {
      await sl.reset();
      await tester.binding.setSurfaceSize(null);
    });
    sl.registerSingleton<ProfileRepository>(FakeProfile());
    sl.registerSingleton<AnalyticsRepository>(FakeAnalytics());
    await tester.pumpWidget(
      MaterialApp(
        home: ProfilePage(
          previewEmail: 'test@example.com',
          onOpenAccount: () {},
          onExitPreview: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Изменить навыки'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Изменить навыки'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dart'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сохранить'));
    await tester.pumpAndSettle();
    expect(find.byType(SkillsSheet), findsNothing);
    expect(find.text('Dart'), findsOneWidget);
    expect(find.text('Навыки не указаны'), findsNothing);
  });
}
