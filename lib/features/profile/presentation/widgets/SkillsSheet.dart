import 'package:flutter/material.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/widgets/ErrorView.dart';
import 'package:find_job_app/features/profile/domain/entities/ProfileEntity.dart';
import 'package:find_job_app/features/profile/domain/repositories/ProfileRepository.dart';
import 'package:find_job_app/features/analytics/domain/repositories/AnalyticsRepository.dart';
import 'package:find_job_app/features/vacancies/domain/entities/SkillEntity.dart';

class SkillsSheet extends StatefulWidget {
  const SkillsSheet({super.key, required this.profile});
  final ProfileEntity profile;

  @override
  State<SkillsSheet> createState() => _SkillsSheetState();
}

class _SkillsSheetState extends State<SkillsSheet> {
  final _repository = sl<ProfileRepository>();
  final _search = TextEditingController();
  late final List<SkillEntity> _selected = List.of(widget.profile.skills);
  late Future<Result<List<SkillEntity>>> _skills;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _skills = _loadSkills();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<Result<List<SkillEntity>>> _loadSkills() async {
    final (all, popular) = await (
      _repository.getSkills(),
      sl<AnalyticsRepository>().getTopSkills(10),
    ).wait;
    if (all is! Success<List<SkillEntity>>) return all;

    final alphabetical = List<SkillEntity>.of(all.data)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    final seen = <int>{};
    return Success([
      if (popular case Success(:final data))
        for (final demand in data)
          if (seen.add(demand.skill.id)) demand.skill,
      for (final skill in alphabetical)
        if (seen.add(skill.id)) skill,
    ]);
  }

  void _retry() => setState(() => _skills = _loadSkills());

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final result = await _repository.setSkills(
        widget.profile.id,
        _selected.map((skill) => skill.id).toList(),
      );
      if (!mounted) return;
      switch (result) {
        case Success():
          Navigator.of(context).pop(List<SkillEntity>.of(_selected));
        case Failed():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось сохранить навыки. Попробуйте ещё раз.'),
            ),
          );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось сохранить навыки. Попробуйте ещё раз.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final availableHeight =
        screenHeight - keyboard - MediaQuery.paddingOf(context).top;
    return PopScope(
      canPop: !_saving,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboard),
        child: SizedBox(
          width: double.infinity,
          height: (screenHeight * .7).clamp(
            0.0,
            availableHeight.clamp(0.0, screenHeight),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Поиск навыков',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        tooltip: 'Закрыть',
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _search,
                    enabled: !_saving,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Введите название навыка',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FutureBuilder<Result<List<SkillEntity>>>(
                        future: _skills,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState !=
                              ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final result = snapshot.data;
                          if (result is! Success<List<SkillEntity>>) {
                            return ErrorView(
                              message: 'Не удалось загрузить навыки',
                              showArt: false,
                              onRetry: _retry,
                            );
                          }
                          final query = _search.text.trim().toLowerCase();
                          final matches = result.data
                              .where(
                                (skill) =>
                                    skill.name.toLowerCase().contains(query) &&
                                    !_selected.any(
                                      (item) => item.id == skill.id,
                                    ),
                              )
                              .toList();
                          if (matches.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text('Навыки не найдены'),
                            );
                          }
                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: matches.length,
                            itemExtent: 36,
                            itemBuilder: (context, index) => ListTile(
                              dense: true,
                              title: Text(
                                matches[index].name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: _saving
                                  ? null
                                  : () => setState(() {
                                      _selected.add(matches[index]);
                                      _search.clear();
                                    }),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ваши навыки',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    flex: 3,
                    child: SingleChildScrollView(
                      child: _selected.isEmpty
                          ? const Text('Навыки не выбраны')
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final skill in _selected)
                                  InputChip(
                                    label: Text(skill.name),
                                    onPressed: _saving
                                        ? null
                                        : () => setState(
                                            () => _selected.removeWhere(
                                              (item) => item.id == skill.id,
                                            ),
                                          ),
                                    onDeleted: _saving
                                        ? null
                                        : () => setState(
                                            () => _selected.removeWhere(
                                              (item) => item.id == skill.id,
                                            ),
                                          ),
                                  ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Сохраняем...' : 'Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
