import 'package:flutter/foundation.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/models/report_reason_model.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/usecases/get_report_reasons_usecase.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/usecases/submit_report_usecase.dart';

class ReportViewModel extends ChangeNotifier {
  final String propertyId;
  final SubmitReportUseCase _submitUseCase;
  final GetReportReasonsUseCase _getReasonsUseCase;

  ReportViewModel({
    required this.propertyId,
    required SubmitReportUseCase submitUseCase,
    required GetReportReasonsUseCase getReasonsUseCase,
  })  : _submitUseCase = submitUseCase,
        _getReasonsUseCase = getReasonsUseCase;

  List<ReportReasonModel> _reasons = [];
  ReportReasonModel? _selectedReason;
  String _details = '';
  bool _isLoadingReasons = false;
  bool _isLoading = false;
  String? _error;

  List<ReportReasonModel> get reasons => _reasons;
  ReportReasonModel? get selectedReason => _selectedReason;
  String get details => _details;
  bool get isLoadingReasons => _isLoadingReasons;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get canProceed => _selectedReason != null;
  String get reasonLabel => _selectedReason?.name ?? '';

  Future<void> loadReasons() async {
    _isLoadingReasons = true;
    _error = null;
    notifyListeners();

    try {
      _reasons = await _getReasonsUseCase.execute();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingReasons = false;
      notifyListeners();
    }
  }

  void selectReason(ReportReasonModel reason) {
    _selectedReason = reason;
    notifyListeners();
  }

  void setDetails(String value) {
    _details = value;
    notifyListeners();
  }

  Future<void> submit() async {
    if (_selectedReason == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _submitUseCase.execute(
        propertyId: propertyId,
        reasonId: _selectedReason!.id,
        comment: _details,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}