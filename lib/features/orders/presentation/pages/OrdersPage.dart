import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:find_job_app/core/di/InjectionContainer.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/AsciiLoader.dart';
import 'package:find_job_app/core/widgets/ErrorView.dart';
import 'package:find_job_app/core/widgets/FindJobAppBar.dart';
import 'package:find_job_app/core/widgets/LoadingIndicator.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderEntity.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderFilters.dart';
import 'package:find_job_app/features/orders/domain/repositories/OrdersRepository.dart';
import 'package:find_job_app/features/orders/presentation/widgets/OrderCard.dart';
import 'package:find_job_app/features/orders/presentation/widgets/OrderFiltersSheet.dart';

/// Freelance orders list with infinite scroll and filters.
/// Same loading logic as VacanciesPage.
class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  static const _pageSize = 20;

  // Start loading the next page when this many pixels are left to the end.
  static const _loadThreshold = 600.0;

  final OrdersRepository _repository = sl<OrdersRepository>();
  final ScrollController _scrollController = ScrollController();

  final List<OrderEntity> _orders = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  OrderFilters _filters = const OrderFilters();

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

  Future<void> _loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final requestId = _requestId;
    final result = await _repository.getOrders(
      filters: _filters,
      offset: _orders.length,
      limit: _pageSize,
    );
    // The user may have left the screen, or changed the filters,
    // while the request was in flight.
    if (!mounted || requestId != _requestId) return;

    setState(() {
      _isLoading = false;
      result.when(
        success: (page) {
          _orders.addAll(page);
          _hasMore = page.length == _pageSize;
        },
        failure: (failure) => _error = failure.message,
      );
    });
  }

  Future<void> _openFilters() async {
    _platforms ??= _repository.getPlatforms();
    // Don't keep a failed request cached: try again on the next open.
    _platforms!.then((r) => r.when(success: (_) {}, failure: (_) => _platforms = null));

    final result = await showModalBottomSheet<OrderFilters>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => OrderFiltersSheet(
        initial: _filters,
        platforms: _platforms!,
      ),
    );
    // null = sheet was swiped away; same filters = nothing to reload.
    if (result == null || result == _filters) return;
    _applyFilters(result);
  }

  /// Starts the list over from the first page with new filters.
  void _applyFilters(OrderFilters filters) {
    setState(() {
      _filters = filters;
      _requestId++;
      _orders.clear();
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
      extendBodyBehindAppBar: true,
      appBar: FindJobAppBar(
        icon: Symbols.assignment,
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
    if (_orders.isEmpty) {
      if (_error != null) {
        return ErrorView(message: _error!, onRetry: _loadNextPage);
      }
      if (_isLoading || _hasMore) return const AsciiLoader();
      if (_filters.activeCount > 0) {
        return ErrorView(
          message: 'По этим фильтрам ничего не нашлось',
          onRetry: () => _applyFilters(const OrderFilters()),
          retryLabel: 'Сбросить фильтры',
        );
      }
      return const Center(child: Text('Заказов пока нет'));
    }

    final showFooter = _hasMore || _error != null;

    return ListView.builder(
      controller: _scrollController,
      itemCount: _orders.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _orders.length) return _buildFooter();

        final order = _orders[index];
        return OrderCard(
          order: order,
          onDetails: () => launchUrl(
            Uri.parse(order.siteHref),
            mode: LaunchMode.externalApplication,
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ErrorView(message: _error!, onRetry: _loadNextPage, showArt: false),
      );
    }
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: LoadingIndicator(),
    );
  }
}
