import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';
import 'package:vivia_mobile/features/lessee/reports/data/datasources/remote/constants/report_api_constants.dart';
import 'package:vivia_mobile/features/lessee/reports/data/models/report_reason_dto.dart';
import 'package:vivia_mobile/features/lessee/reports/data/models/report_request_model.dart';

abstract class ReportRemoteDatasource {
  Future<List<ReportReasonDto>> getReasons();
  Future<void> submitReport(ReportRequestModel request);
}

class ReportRemoteDatasourceImpl implements ReportRemoteDatasource {
  final http.Client _client;
  static const _timeout = Duration(seconds: 15);

  ReportRemoteDatasourceImpl(this._client);

  @override
  Future<List<ReportReasonDto>> getReasons() async {
    final res = await _client
        .get(
      Uri.parse(ReportApiConstants.reasons),
      headers: AuthApiConstants.headers(),
    )
        .timeout(_timeout);

    final json = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode != 200 || json['success'] != true) {
      throw Exception(json['message'] ?? 'Error ${res.statusCode}');
    }

    final list = json['data'] as List<dynamic>;
    return list
        .map((e) => ReportReasonDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> submitReport(ReportRequestModel request) async {
    final res = await _client
        .post(
      Uri.parse(ReportApiConstants.submit),
      headers: AuthApiConstants.headers(),
      body: jsonEncode(request.toJson()),
    )
        .timeout(_timeout);

    if (res.statusCode != 200 && res.statusCode != 201) {
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      throw Exception(json['message'] ?? 'Error ${res.statusCode}');
    }
  }
}