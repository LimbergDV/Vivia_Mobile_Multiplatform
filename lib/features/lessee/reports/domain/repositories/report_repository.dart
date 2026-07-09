import 'package:vivia_mobile/features/lessee/reports/domain/models/report_reason_model.dart';

abstract class ReportRepository {
  Future<List<ReportReasonModel>> getReasons();
  Future<void> submitReport({
    required String propertyId,
    required String reasonId,
    required String comment,
  });
}