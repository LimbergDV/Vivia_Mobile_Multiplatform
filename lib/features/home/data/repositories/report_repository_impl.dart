import 'package:vivia_mobile/features/home/data/datasources/remote/report_remote_datasource.dart';
import 'package:vivia_mobile/features/home/data/models/report_request_model.dart';
import 'package:vivia_mobile/features/home/domain/models/report_reason_model.dart';
import 'package:vivia_mobile/features/home/domain/repositories/report_repository.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDatasource _remote;

  ReportRepositoryImpl({required ReportRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<List<ReportReasonModel>> getReasons() async {
    final dtos = await _remote.getReasons();
    return dtos.map((d) => d.toModel()).toList();
  }

  @override
  Future<void> submitReport({
    required String propertyId,
    required String reasonId,
    required String comment,
  }) =>
      _remote.submitReport(
        ReportRequestModel(
          propertyId: propertyId,
          reasonId: reasonId,
          comment: comment,
        ),
      );
}