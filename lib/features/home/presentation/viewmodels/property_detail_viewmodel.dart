import 'package:flutter/material.dart';
import 'package:vivia_mobile/features/home/domain/models/property_detail.dart';
import 'package:vivia_mobile/features/home/domain/usecases/get_property_by_id_usecase.dart';

enum PropertyDetailStatus { idle, loading, success, error }

/// ViewModel del detalle de una propiedad. Se instancia una vez por pantalla
/// de detalle (es per-propiedad, no global).
class PropertyDetailViewModel extends ChangeNotifier {
  final GetPropertyByIdUseCase _getPropertyById;

  PropertyDetailViewModel({
    required GetPropertyByIdUseCase getPropertyByIdUseCase,
  }) : _getPropertyById = getPropertyByIdUseCase;

  PropertyDetailStatus _status = PropertyDetailStatus.idle;
  PropertyDetail? _detail;

  PropertyDetailStatus get status => _status;
  PropertyDetail? get detail => _detail;

  Future<void> load(String id) async {
    if (_status == PropertyDetailStatus.loading) return;

    _status = PropertyDetailStatus.loading;
    notifyListeners();

    try {
      _detail = await _getPropertyById.execute(id);
      _status = PropertyDetailStatus.success;
    } catch (_) {
      _status = PropertyDetailStatus.error;
    } finally {
      notifyListeners();
    }
  }
}
