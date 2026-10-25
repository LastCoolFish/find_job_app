import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/AsciiLoader.dart';
import 'package:find_job_app/core/widgets/ErrorView.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/features/vacancies/domain/entities/SkillEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/VacancyDetailsPage.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';

/// All vacancies that ask for one skill. Opened from the skill chips on the
/// home screen.
class SkillVacanciesPage extends StatefulWidget {
  final SkillEntity skill;

  const SkillVacanciesPage({super.key, required this.skill});

  @override
  State<SkillVacanciesPage> createState() => _SkillVacanciesPageState();
}

class _SkillVacanciesPageState extends State<SkillVacanciesPage> {
  final VacanciesRepository _repository = sl<VacanciesRepository>();
  late Future<Result<List<VacancyEntity>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Result<List<VacancyEntity>>> _load() =>
      _repository.getVacanciesBySkills([widget.skill.id]);

  void _openDetails(VacancyEntity vacancy) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => VacancyDetailsPage(vacancy: vacancy)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: FindJobAppBar(title: widget.skill.name, icon: Symbols.code),
      body: FutureBuilder<Result<List<VacancyEntity>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AsciiLoader();
          }
          final result = snapshot.data;
          if (result == null) {
            return ErrorView(
              message: '${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          return result.when(
            success: (vacancies) => ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: vacancies.length,
              itemBuilder: (context, index) {
                final vacancy = vacancies[index];
                return VacancyCard(
                  vacancy: vacancy,
                  onTap: () => _openDetails(vacancy),
                  onDetails: () => _openDetails(vacancy),
                );
              },
            ),
            failure: (failure) => ErrorView(
              message: failure.message,
              onRetry: () => setState(() => _future = _load()),
            ),
          );
        },
      ),
    );
  }
}
