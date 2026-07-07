import 'package:vivia_mobile/features/home/domain/models/report_reason_model.dart';

abstract class ReportRepository {
  Future<List<ReportReasonModel>> getReasons();
  Future<void> submitReport({
    required String propertyId,
    required String reasonId,
    required String comment,
  });
}