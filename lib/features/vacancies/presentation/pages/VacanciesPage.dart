import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/ErrorView.dart';
import 'package:find_job_app/core/widgets/LoadingIndicator.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';

class VacanciesPage extends StatefulWidget {
  const VacanciesPage({super.key});

  @override
  State<VacanciesPage> createState() => _VacanciesPageState();
}

class _VacanciesPageState extends State<VacanciesPage> {
  final VacanciesRepository _repository = sl<VacanciesRepository>();

  // Kept in a field, not created in build(): otherwise every rebuild
  // would fire a new request.
  late Future<Result<List<VacancyEntity>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getVacancies();
  }

  void _retry() {
    setState(() {
      _future = _repository.getVacancies();
    });
  }

  void _openFilters() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SizedBox(
        // Empty for now, filters will go here.
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let the list scroll under the app bar, otherwise the rounded corners
      // would only reveal the plain scaffold background.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        clipBehavior: Clip.antiAlias,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.person_search, size: 32, weight: 700),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'FindJob',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _openFilters,
            tooltip: 'Фильтры',
            icon: const Icon(Symbols.tune, size: 28, weight: 600),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<Result<List<VacancyEntity>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorView(message: snapshot.error.toString(), onRetry: _retry);
          }

          return snapshot.data!.when(
            success: (vacancies) => _buildList(vacancies),
            failure: (failure) => ErrorView(message: failure.message, onRetry: _retry),
          );
        },
      ),
    );
  }

  Widget _buildList(List<VacancyEntity> vacancies) {
    return ListView.builder(
      itemCount: vacancies.length,
      itemBuilder: (context, index) {
        final vacancy = vacancies[index];
        return VacancyCard(
          vacancy: vacancy,
          onDetails: () => launchUrl(
            Uri.parse(vacancy.siteHref),
            mode: LaunchMode.externalApplication,
          ),
        );
      },
    );
  }
}
