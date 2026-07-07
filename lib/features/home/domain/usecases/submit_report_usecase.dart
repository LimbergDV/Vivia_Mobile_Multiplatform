import 'package:vivia_mobile/features/home/domain/repositories/report_repository.dart';

class SubmitReportUseCase {
  final ReportRepository _repository;

  SubmitReportUseCase(this._repository);

  Future<void> execute({
    required String propertyId,
    required String reasonId,
    required String comment,
  }) =>
      _repository.submitReport(
        propertyId: propertyId,
        reasonId: reasonId,
        comment: comment,
      );
}