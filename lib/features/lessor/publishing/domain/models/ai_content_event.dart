sealed class AiContentEvent {
  const AiContentEvent();
}

final class AiContentQueued extends AiContentEvent {
  final int position;
  const AiContentQueued(this.position);
}

final class AiContentTitle extends AiContentEvent {
  final String text;
  const AiContentTitle(this.text);
}

final class AiContentDelta extends AiContentEvent {
  final String text;
  const AiContentDelta(this.text);
}

final class AiContentDone extends AiContentEvent {
  final String generationId;
  final String title;
  final String description;
  const AiContentDone({
    required this.generationId,
    required this.title,
    required this.description,
  });
}

final class AiContentError extends AiContentEvent {
  final String detail;
  const AiContentError(this.detail);
}

final class AiContentPremiumRequired extends AiContentEvent {
  const AiContentPremiumRequired();
}

final class AiContentSubscriptionCheckFailed extends AiContentEvent {
  const AiContentSubscriptionCheckFailed();
}
