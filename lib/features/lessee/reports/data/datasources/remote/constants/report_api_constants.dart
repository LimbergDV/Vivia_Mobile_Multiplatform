import 'package:vivia_mobile/features/auth/data/datasources/remote/constants/auth_api_constants.dart';

class ReportApiConstants {
  ReportApiConstants._();

  static String get submit => '${AuthApiConstants.baseUrl}/reports';
  static String get reasons => '${AuthApiConstants.baseUrl}/reports/reasons';
}