import 'package:vivia_mobile/features/home/domain/models/report_reason_model.dart';

class ReportReasonDto {
  final String id;
  final String name;
  final String description;
  final String priority;

  const ReportReasonDto({
    required this.id,
    required this.name,
    required this.description,
    required this.priority,
  });

  factory ReportReasonDto.fromJson(Map<String, dynamic> json) => ReportReasonDto(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    priority: json['priority'] as String? ?? 'LOW',
  );

  ReportReasonModel toModel() => ReportReasonModel(
    id: id,
    name: name,
    description: description,
    priority: priority,
  );
}