class ReportRequestModel {
  final String propertyId;
  final String reasonId;
  final String comment;

  const ReportRequestModel({
    required this.propertyId,
    required this.reasonId,
    required this.comment,
  });

  Map<String, dynamic> toJson() => {
    'propertyId': propertyId,
    'reasonId': reasonId,
    'comment': comment,
  };
}