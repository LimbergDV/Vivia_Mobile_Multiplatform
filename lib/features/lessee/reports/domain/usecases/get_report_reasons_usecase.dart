import 'package:vivia_mobile/features/lessee/reports/domain/models/report_reason_model.dart';
import 'package:vivia_mobile/features/lessee/reports/domain/repositories/report_repository.dart';

class GetReportReasonsUseCase {
  final ReportRepository _repository;

  GetReportReasonsUseCase(this._repository);

  Future<List<ReportReasonModel>> execute() => _repository.getReasons();
}