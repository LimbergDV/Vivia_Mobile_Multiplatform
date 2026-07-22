import 'package:vivia_mobile/shared/property/domain/models/property_model.dart';

class FilterBounds {
  final double minPrice;
  final double maxPrice;
  final double minArea;
  final double maxArea;

  const FilterBounds({
    required this.minPrice,
    required this.maxPrice,
    required this.minArea,
    required this.maxArea,
  });

  static const fixed = FilterBounds(
    minPrice: 0,
    maxPrice: 11000000,
    minArea: 0,
    maxArea: 120,
  );
}

enum PropertySort {
  relevance('Relevancia'),
  priceAsc('Precio: menor a mayor'),
  priceDesc('Precio: mayor a menor');

  final String label;
  const PropertySort(this.label);
}

class PropertyFilter {
  final double? minPrice;
  final double? maxPrice;
  final double? minArea;
  final double? maxArea;
  final int minBedrooms;
  final int minBathrooms;
  final PropertySort sort;

  const PropertyFilter({
    this.minPrice,
    this.maxPrice,
    this.minArea,
    this.maxArea,
    this.minBedrooms = 0,
    this.minBathrooms = 0,
    this.sort = PropertySort.relevance,
  });

  static const empty = PropertyFilter();

  bool get isActive =>
      minPrice != null ||
      maxPrice != null ||
      minArea != null ||
      maxArea != null ||
      minBedrooms > 0 ||
      minBathrooms > 0;

  int get activeCount {
    var count = 0;
    if (minPrice != null || maxPrice != null) count++;
    if (minArea != null || maxArea != null) count++;
    if (minBedrooms > 0) count++;
    if (minBathrooms > 0) count++;
    return count;
  }

  bool matches(PropertyModel p) =>
      _inRange(p.price, minPrice, maxPrice) &&
      _inRange(p.area, minArea, maxArea) &&
      p.bedrooms >= minBedrooms &&
      p.bathrooms >= minBathrooms;

  bool _inRange(double value, double? min, double? max) =>
      (min == null || value >= min) && (max == null || value <= max);
}
