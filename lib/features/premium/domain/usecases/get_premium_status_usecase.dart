import 'package:vivia_mobile/features/premium/domain/models/premium_status.dart';
import 'package:vivia_mobile/features/premium/domain/repositories/premium_repository.dart';

class GetPremiumStatusUseCase {
  final PremiumRepository _repository;
  const GetPremiumStatusUseCase(this._repository);

  Future<PremiumStatus> execute() => _repository.getPremiumStatus();
}
