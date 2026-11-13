import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/config/EnvConfig.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Formatters.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/LoadingIndicator.dart';
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
  const ProfilePage({
    super.key,
    required this.previewEmail,
    required this.onOpenAccount,
    required this.onExitPreview,
  });

  final String? previewEmail;
  final VoidCallback onOpenAccount;
  final VoidCallback onExitPreview;

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
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
  }

  @override
  Widget build(BuildContext context) {
    final email = widget.previewEmail;
    return Scaffold(
      appBar: FindJobAppBar(
        section: 'Профиль',
        actions: [
          IconButton.filledTonal(
            onPressed: _openSettings,
            tooltip: 'Настройки',
            icon: const Icon(Symbols.settings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          SectionCard(
            title: 'Аккаунт FindJob',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (email == null)
                  FilledButton(
                    onPressed: widget.onOpenAccount,
                    child: const Text('Войти или зарегистрироваться'),
                  )
                else ...[
                  Text(email),
                  const Text('Режим просмотра'),
                  TextButton.icon(
                    onPressed: widget.onExitPreview,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Выйти из аккаунта'),
                  ),
                ],
              ],
            ),
          ),
          FutureBuilder<Result<_ProfileData>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const FindJobLoading(message: 'Загружаем профиль');
              }
              final result = snapshot.data;
              if (result == null) {
                return ErrorView(message: '${snapshot.error}', onRetry: _retry);
              }
              return result.when(
                success: (data) => _buildContent(data.profile, data.user),
                failure: (failure) =>
                    ErrorView(message: failure.message, onRetry: _retry),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ProfileEntity profile, UserEntity user) {
    final textTheme = Theme.of(context).textTheme;
    final grade = profile.desiredGrade;
    final gradeLabel =
        grade != null && grade >= 0 && grade < VacancyCard.grades.length
        ? VacancyCard.grades[grade]
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.muted,
                      ),
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
              InfoRow(icon: Symbols.stacks, label: 'Грейд', value: gradeLabel),
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
              ? Text(
                  'Навыки не указаны',
                  style: TextStyle(color: AppColors.muted),
                )
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
