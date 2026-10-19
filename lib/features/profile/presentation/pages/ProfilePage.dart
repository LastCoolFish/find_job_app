import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/config/EnvConfig.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/AsciiLoader.dart';
import 'package:find_job_app/core/widgets/ErrorView.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/InfoRow.dart';
import 'package:find_job_app/core/widgets/InitialsAvatar.dart';
import 'package:find_job_app/core/widgets/SectionCard.dart';
import 'package:find_job_app/core/widgets/Tag.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/entities/UserEntity.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';
import 'package:find_job_app/features/settings/presentation/pages/SettingsPage.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';

/// Profile tab: avatar, nickname and name, profile/account fields and skills.
/// There is no login yet, so it shows [EnvConfig.currentUserId].
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

/// Profile and account loaded together, since the screen needs both.
typedef _ProfileData = ({ProfileEntity profile, UserEntity user});

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _repository = sl<ProfileRepository>();

  late Future<Result<_ProfileData>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Result<_ProfileData>> _load() async {
    const userId = EnvConfig.currentUserId;
    // Both requests run at the same time.
    final (profileResult, userResult) = await (
      _repository.getProfileByUser(userId),
      _repository.getUser(userId),
    ).wait;

    return profileResult.when(
      success: (profile) => userResult.when(
        success: (user) => Success((profile: profile, user: user)),
        failure: Failed.new,
      ),
      failure: Failed.new,
    );
  }

  void _retry() => setState(() => _future = _load());

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FindJobAppBar(
        icon: Symbols.person,
        actions: [
          IconButton(
            onPressed: _openSettings,
            tooltip: 'Настройки',
            icon: const Icon(Symbols.settings, size: 28, weight: 600),
          ),
        ],
      ),
      body: FutureBuilder<Result<_ProfileData>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AsciiLoader();
          }
          final result = snapshot.data;
          if (result == null) {
            return ErrorView(message: '${snapshot.error}', onRetry: _retry);
          }
          return result.when(
            success: (data) => _buildContent(data.profile, data.user),
            failure: (failure) => ErrorView(message: failure.message, onRetry: _retry),
          );
        },
      ),
    );
  }

  Widget _buildContent(ProfileEntity profile, UserEntity user) {
    final textTheme = Theme.of(context).textTheme;
    final grade = profile.desiredGrade;
    final gradeLabel = grade != null && grade >= 0 && grade < VacancyCard.grades.length
        ? VacancyCard.grades[grade]
        : null;
    // Space taken by the app bar and the bottom navigation bar,
    // since the list scrolls under both of them.
    // final insets = MediaQuery.paddingOf(context);


    return ListView(
      padding: EdgeInsets.all(12),
      // padding: EdgeInsets.fromLTRB(12, insets.top + 12, 12, insets.bottom + 12),
      children: [
        // Header: photo, nickname (big) and name (smaller) next to it.
        SectionCard(
          child: Row(
            children: [
              InitialsAvatar(name: profile.name ?? profile.username, size: 72),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.name ?? 'Имя не указано',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SectionCard(
          title: 'Что ищу',
          child: Column(
            children: [
              InfoRow(
                icon: Symbols.payments,
                label: 'Желаемая зарплата',
                value: profile.desiredSalary == null
                    ? null
                    : formatMoney(profile.desiredSalary!),
              ),
              InfoRow(
                icon: Symbols.work,
                label: 'Формат работы',
                value: profile.desiredFormat,
              ),
              InfoRow(
                icon: Symbols.stacks,
                label: 'Грейд',
                value: gradeLabel,
              ),
            ],
          ),
        ),

        SectionCard(
          title: 'Аккаунт',
          child: Column(
            children: [
              InfoRow(icon: Symbols.mail, label: 'Email', value: user.email),
              InfoRow(icon: Symbols.call, label: 'Телефон', value: user.phone),
              InfoRow(
                icon: Symbols.calendar_month,
                label: 'На сайте с',
                value: formatDateTime(user.createdAt),
              ),
            ],
          ),
        ),

        SectionCard(
          title: 'Навыки',
          child: profile.skills.isEmpty
              ? Text('Навыки не указаны', style: TextStyle(color: AppColors.muted))
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final skill in profile.skills) Tag(label: skill.name),
                  ],
                ),
        ),
      ],
    );
  }
}
