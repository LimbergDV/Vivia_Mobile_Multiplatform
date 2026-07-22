import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/lessor/publishing/presentation/widgets/form_section_header.dart';
import 'package:vivia_mobile/shared/property/domain/models/property_filter.dart';

const _kAccent = Color(0xFF0095FF);

class PropertyFilterSheet extends StatefulWidget {
  final PropertyFilter initial;
  final FilterBounds bounds;

  const PropertyFilterSheet({
    super.key,
    required this.initial,
    required this.bounds,
  });

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late RangeValues _price;
  late RangeValues _area;
  late int _bedrooms;
  late int _bathrooms;
  late PropertySort _sort;

  double get _priceLo => widget.bounds.minPrice;
  double get _priceHi =>
      (widget.bounds.maxPrice <= _priceLo) ? _priceLo + 1 : widget.bounds.maxPrice;
  double get _areaLo => widget.bounds.minArea;
  double get _areaHi =>
      (widget.bounds.maxArea <= _areaLo) ? _areaLo + 1 : widget.bounds.maxArea;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _price = RangeValues(
      (f.minPrice ?? _priceLo).clamp(_priceLo, _priceHi),
      (f.maxPrice ?? _priceHi).clamp(_priceLo, _priceHi),
    );
    _area = RangeValues(
      (f.minArea ?? _areaLo).clamp(_areaLo, _areaHi),
      (f.maxArea ?? _areaHi).clamp(_areaLo, _areaHi),
    );
    _bedrooms = f.minBedrooms;
    _bathrooms = f.minBathrooms;
    _sort = f.sort;
  }

  void _clear() => Navigator.of(context).pop(PropertyFilter.empty);

  void _apply() => Navigator.of(context).pop(_buildFilter());

  PropertyFilter _buildFilter() => PropertyFilter(
        minPrice: _price.start > _priceLo ? _price.start : null,
        maxPrice: _price.end < _priceHi ? _price.end : null,
        minArea: _area.start > _areaLo ? _area.start : null,
        maxArea: _area.end < _areaHi ? _area.end : null,
        minBedrooms: _bedrooms,
        minBathrooms: _bathrooms,
        sort: _sort,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Grabber(),
            const SizedBox(height: 12),
            _Header(onClear: _clear),
            const SizedBox(height: 20),
            const FormSectionHeader(
              label: 'Precio',
              iconData: Icons.attach_money_rounded,
            ),
            _RangeRow(
              values: _price,
              min: _priceLo,
              max: _priceHi,
              divisions: 110,
              format: _formatPrice,
              onChanged: (v) => setState(() => _price = v),
            ),
            const SizedBox(height: 20),
            const FormSectionHeader(
              label: 'Área (m²)',
              iconData: Icons.straighten_rounded,
            ),
            _RangeRow(
              values: _area,
              min: _areaLo,
              max: _areaHi,
              divisions: 120,
              format: (v) => '${v.round()} m²',
              onChanged: (v) => setState(() => _area = v),
            ),
            const SizedBox(height: 20),
            const FormSectionHeader(
              label: 'Habitaciones',
              iconData: Icons.bed_outlined,
            ),
            const SizedBox(height: 12),
            _MinChips(
              selected: _bedrooms,
              onSelected: (v) => setState(() => _bedrooms = v),
            ),
            const SizedBox(height: 20),
            const FormSectionHeader(
              label: 'Baños',
              iconData: Icons.bathtub_outlined,
            ),
            const SizedBox(height: 12),
            _MinChips(
              selected: _bathrooms,
              onSelected: (v) => setState(() => _bathrooms = v),
            ),
            const SizedBox(height: 20),
            const FormSectionHeader(
              label: 'Ordenar por',
              iconData: Icons.swap_vert_rounded,
            ),
            const SizedBox(height: 12),
            _SortChips(
              selected: _sort,
              onSelected: (v) => setState(() => _sort = v),
            ),
            const SizedBox(height: 28),
            _Actions(onClear: _clear, onApply: _apply),
          ],
          ),
        ),
      ),
    );
  }
}

String _formatPrice(double value) {
  final digits = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '\$$buffer';
}

class _Grabber extends StatelessWidget {
  const _Grabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClear;
  const _Header({required this.onClear});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filtros',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        GestureDetector(
          onTap: onClear,
          child: Text(
            'Limpiar',
            style: textTheme.labelLarge?.copyWith(
              color: _kAccent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _RangeRow extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<RangeValues> onChanged;

  const _RangeRow({
    required this.values,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _kAccent,
            thumbColor: _kAccent,
            overlayColor: _kAccent.withOpacity(0.12),
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: divisions,
            labels: RangeLabels(format(values.start), format(values.end)),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              format(values.start),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              format(values.end),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MinChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _MinChips({required this.selected, required this.onSelected});

  static const _labels = ['Cualquiera', '1+', '2+', '3+', '4+'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_labels.length, (i) {
        return _Chip(
          label: _labels[i],
          isSelected: selected == i,
          onTap: () => onSelected(i),
        );
      }),
    );
  }
}

class _SortChips extends StatelessWidget {
  final PropertySort selected;
  final ValueChanged<PropertySort> onSelected;

  const _SortChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PropertySort.values.map((sort) {
        return _Chip(
          label: sort.label,
          isSelected: selected == sort,
          onTap: () => onSelected(sort),
        );
      }).toList(),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _kAccent : colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? _kAccent : colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final VoidCallback onClear;
  final VoidCallback onApply;

  const _Actions({required this.onClear, required this.onApply});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onClear,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kAccent,
              side: const BorderSide(color: _kAccent),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Limpiar',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Aplicar',
              style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
