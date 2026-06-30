sealed class DraftStatusEvent {
  const DraftStatusEvent();
}

final class DraftStatusUpdate extends DraftStatusEvent {
  final String draftId;
  final String status;
  final DateTime updatedAt;

  const DraftStatusUpdate({
    required this.draftId,
    required this.status,
    required this.updatedAt,
  });

  factory DraftStatusUpdate.fromJson(Map<String, dynamic> j) =>
      DraftStatusUpdate(
        draftId: j['draftId'] as String,
        status: j['status'] as String,
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );
}

final class DraftPublicationSuccess extends DraftStatusEvent {
  final String id;
  final String mainImageUrl;
  final String title;
  final double listedPrice;
  final double areaM2;
  final int bedrooms;
  final double bathrooms;
  final String propertyTypeName;

  const DraftPublicationSuccess({
    required this.id,
    required this.mainImageUrl,
    required this.title,
    required this.listedPrice,
    required this.areaM2,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyTypeName,
  });

  factory DraftPublicationSuccess.fromJson(Map<String, dynamic> j) =>
      DraftPublicationSuccess(
        id: j['id'] as String,
        mainImageUrl: j['mainImageUrl'] as String,
        title: j['title'] as String,
        listedPrice: (j['listedPrice'] as num).toDouble(),
        areaM2: (j['areaM2'] as num).toDouble(),
        bedrooms: j['bedrooms'] as int,
        bathrooms: (j['bathrooms'] as num).toDouble(),
        propertyTypeName: j['propertyTypeName'] as String,
      );
}

final class DraftPublicationFailed extends DraftStatusEvent {
  final String draftId;
  final String status;
  final String reason;

  const DraftPublicationFailed({
    required this.draftId,
    required this.status,
    required this.reason,
  });

  factory DraftPublicationFailed.fromJson(Map<String, dynamic> j) =>
      DraftPublicationFailed(
        draftId: j['draftId'] as String,
        status: j['status'] as String,
        reason: j['reason'] as String,
      );
}
