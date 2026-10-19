import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/theme/AppColors.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/AsciiLoader.dart';
import 'package:find_job_app/core/widgets/ErrorView.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/LoadingIndicator.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyEntity.dart';
import 'package:find_job_app/features/vacancies/domain/entities/VacancyFilters.dart';
import 'package:find_job_app/features/vacancies/domain/repositories/VacanciesRepository.dart';
import 'package:find_job_app/features/vacancies/presentation/pages/VacancyDetailsPage.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyCard.dart';
import 'package:find_job_app/features/vacancies/presentation/widgets/VacancyFiltersSheet.dart';

class VacanciesPage extends StatefulWidget {
  const VacanciesPage({super.key});

  @override
  State<VacanciesPage> createState() => _VacanciesPageState();
}

class _VacanciesPageState extends State<VacanciesPage> {
  static const _pageSize = 50;

  // Start loading the next page when this many pixels are left to the end,
  // so new cards are usually ready before the user reaches the bottom.
  static const _loadThreshold = 600.0;

  final VacanciesRepository _repository = sl<VacanciesRepository>();
  final ScrollController _scrollController = ScrollController();

  final List<VacancyEntity> _vacancies = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  VacancyFilters _filters = const VacancyFilters();

  // Loaded lazily on the first filters open and reused afterwards.
  Future<Result<List<String>>>? _platforms;

  // Bumped every time the filters change, so a page that was requested with
  // the old filters and arrives late gets thrown away instead of mixed in.
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNextPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < _loadThreshold) {
      _loadNextPage();
    }
  }

  /// Pull-to-refresh: loads the first page again with the current filters.
  /// Old cards stay on screen until the new ones arrive; if the request
  /// fails they stay as they were and a short message is shown.
  Future<void> _refresh() async {
    // Drop any page that is still loading, it belongs to the old list.
    final requestId = ++_requestId;
    setState(() => _isLoading = false);

    final result = await _repository.getVacancies(
      filters: _filters,
      offset: 0,
      limit: _pageSize,
    );
    if (!mounted || requestId != _requestId) return;

    result.when(
      success: (page) => setState(() {
        _vacancies
          ..clear()
          ..addAll(page);
        _hasMore = page.length == _pageSize;
        _error = null;
      }),
      failure: (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось обновить: ${failure.message}')),
      ),
    );
  }

  Future<void> _loadNextPage() async {
    // Scroll events fire many times per second, so ignore them while a page
    // is in flight or once everything is loaded.
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final requestId = _requestId;
    final result = await _repository.getVacancies(
      filters: _filters,
      offset: _vacancies.length,
      limit: _pageSize,
    );
    // The user may have left the screen, or changed the filters,
    // while the request was in flight.
    if (!mounted || requestId != _requestId) return;

    setState(() {
      _isLoading = false;
      result.when(
        success: (page) {
          _vacancies.addAll(page);
          // A short page means the server has nothing more to give.
          _hasMore = page.length == _pageSize;
        },
        failure: (failure) => _error = failure.message,
      );
    });
  }

  Future<void> _openFilters() async {
    _platforms ??= _repository.getPlatforms();
    // Don't keep a failed request cached: try again on the next open.
    _platforms!.then(
      (r) => r.when(success: (_) {}, failure: (_) => _platforms = null),
    );

    final result = await showModalBottomSheet<VacancyFilters>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) =>
          VacancyFiltersSheet(initial: _filters, platforms: _platforms!),
    );
    // null = sheet was swiped away; same filters = nothing to reload.
    if (result == null || result == _filters) return;
    _applyFilters(result);
  }

  /// Starts the list over from the first page with new filters.
  void _applyFilters(VacancyFilters filters) {
    setState(() {
      _filters = filters;
      _requestId++;
      _vacancies.clear();
      _hasMore = true;
      _isLoading = false;
      _error = null;
    });
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
    _loadNextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let the list scroll under the app bar, otherwise the rounded corners
      // would only reveal the plain scaffold background.
      extendBodyBehindAppBar: true,
      appBar: FindJobAppBar(
        icon: Symbols.work,
        actions: [
          IconButton(
            onPressed: _openFilters,
            tooltip: 'Фильтры',
            icon: Badge(
              // Number of active filters, hidden when there are none.
              isLabelVisible: _filters.activeCount > 0,
              label: Text('${_filters.activeCount}'),
              child: const Icon(Symbols.tune, size: 28, weight: 600),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Nothing loaded yet: full-screen spinner or error.
    if (_vacancies.isEmpty) {
      if (_error != null) {
        return ErrorView(message: _error!, onRetry: _loadNextPage);
      }
      if (_isLoading || _hasMore) return const AsciiLoader();
      if (_filters.activeCount > 0) {
        return ErrorView(
          message: 'По этим фильтрам ничего не нашлось',
          onRetry: () => _applyFilters(const VacancyFilters()),
          retryLabel: 'Сбросить фильтры',
        );
      }
      return const Center(child: Text('Вакансий пока нет'));
    }

    // One extra item at the bottom for the "loading more" spinner
    // or the retry button.
    final showFooter = _hasMore || _error != null;

    return RefreshIndicator(
      onRefresh: _refresh,
      // The list scrolls under the app bar, so show the circle below it.
      edgeOffset: MediaQuery.paddingOf(context).top,
      color: AppColors.accent,
      backgroundColor: AppColors.card,
      child: ListView.builder(
        controller: _scrollController,
        // Lets the list be pulled down even when it is shorter than the screen.
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _vacancies.length + (showFooter ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _vacancies.length) return _buildFooter();

          final vacancy = _vacancies[index];
          return VacancyCard(
            vacancy: vacancy,
            onTap: () => _openDetails(vacancy),
            onDetails: () => _openDetails(vacancy),
          );
        },
      ),
    );
  }

  /// Opens the details on top of this screen. The list stays alive under it,
  /// so going back shows it as it was: same items, same scroll position.
  void _openDetails(VacancyEntity vacancy) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VacancyDetailsPage(vacancy: vacancy),
      ),
    );
  }

  Widget _buildFooter() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ErrorView(
          message: _error!,
          onRetry: _loadNextPage,
          showArt: false,
        ),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: LoadingIndicator(),
    );
  }
}
