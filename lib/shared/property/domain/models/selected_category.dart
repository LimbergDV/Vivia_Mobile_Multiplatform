import 'package:vivia_mobile/shared/property/domain/models/property_type_model.dart';

sealed class SelectedCategory {
  const SelectedCategory();
  String get label;
}

final class AllCategory extends SelectedCategory {
  const AllCategory();
  @override
  String get label => 'Todas';
}

final class FavoritesCategory extends SelectedCategory {
  const FavoritesCategory();
  @override
  String get label => 'Favoritos';
}

final class TypeCategory extends SelectedCategory {
  final PropertyTypeModel type;
  const TypeCategory(this.type);
  @override
  String get label => type.name;

  @override
  bool operator ==(Object other) =>
      other is TypeCategory && other.type == type;

  @override
  int get hashCode => type.hashCode;
}
