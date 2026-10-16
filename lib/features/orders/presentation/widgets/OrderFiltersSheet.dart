import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:find_job_app/core/utils/Result.dart';
import 'package:find_job_app/core/widgets/FilterSheetParts.dart';
import 'package:find_job_app/features/orders/domain/entities/OrderFilters.dart';

/// Content of the orders filters bottom sheet. Closes with
/// `Navigator.pop(filters)` on "Показать"; swiping it away returns null.
class OrderFiltersSheet extends StatefulWidget {
  final OrderFilters initial;

  /// Platform codes from `GET /orders/platforms`, loaded once by the page.
  final Future<Result<List<String>>> platforms;

  const OrderFiltersSheet({
    super.key,
    required this.initial,
    required this.platforms,
  });

  @override
  State<OrderFiltersSheet> createState() => _OrderFiltersSheetState();
}

class _OrderFiltersSheetState extends State<OrderFiltersSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceMinController;
  late final TextEditingController _priceMaxController;
  String? _platform;
  late OrderSort _sort;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _nameController = TextEditingController(text: f.name ?? '');
    _priceMinController = TextEditingController(text: f.priceMin?.toString() ?? '');
    _priceMaxController = TextEditingController(text: f.priceMax?.toString() ?? '');
    _platform = f.platform;
    _sort = f.sort;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _nameController.clear();
      _priceMinController.clear();
      _priceMaxController.clear();
      _platform = null;
      _sort = OrderSort.newest;
    });
  }

  void _apply() {
    final name = _nameController.text.trim();
    Navigator.of(context).pop(
      OrderFilters(
        name: name.isEmpty ? null : name,
        priceMin: int.tryParse(_priceMinController.text),
        priceMax: int.tryParse(_priceMaxController.text),
        platform: _platform,
        sort: _sort,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FilterSheetFrame(
      onReset: _reset,
      onApply: _apply,
      children: [
        FilterSection(
          title: 'Название',
          child: TextField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: filterInputDecoration('Например, Telegram или Python'),
          ),
        ),
        FilterSection(
          title: 'Цена, ₽',
          child: Row(
            children: [
              Expanded(child: _priceField(_priceMinController, 'от')),
              const SizedBox(width: 8),
              Expanded(child: _priceField(_priceMaxController, 'до')),
            ],
          ),
        ),
        FilterSection(
          title: 'Площадка',
          child: PlatformChoices(
            platforms: widget.platforms,
            selected: _platform,
            onChanged: (value) => setState(() => _platform = value),
          ),
        ),
        FilterSection(
          title: 'Сортировка',
          child: FilterChoices<OrderSort>(
            values: OrderSort.values,
            selected: _sort,
            labelOf: (sort) => sort.label,
            // One sort option is always selected.
            allowNone: false,
            onChanged: (value) => setState(() => _sort = value!),
          ),
        ),
      ],
    );
  }

  Widget _priceField(TextEditingController controller, String hint) => TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: filterInputDecoration(hint),
      );
}
