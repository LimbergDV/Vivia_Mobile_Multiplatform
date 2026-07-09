enum VerificationDocumentType {
  ineFront('INE_FRONT'),
  ineBack('INE_BACK'),
  selfie('SELFIE');

  final String apiValue;
  const VerificationDocumentType(this.apiValue);
}
