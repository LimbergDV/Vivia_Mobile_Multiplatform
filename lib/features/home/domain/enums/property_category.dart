enum PropertyCategory { todas, casas, departamentos, terrenos, otras }

extension PropertyCategoryLabel on PropertyCategory {
  String get label {
    switch (this) {
      case PropertyCategory.todas:
        return 'Todas';
      case PropertyCategory.casas:
        return 'Casas';
      case PropertyCategory.departamentos:
        return 'Departamentos';
      case PropertyCategory.terrenos:
        return 'Terrenos';
      case PropertyCategory.otras:
        return 'Otras';
    }
  }
}