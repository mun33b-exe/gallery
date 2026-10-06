import '../domain/user_entitlement.dart';

/// Read-only repository interface for user entitlements.
abstract class EntitlementRepository {
  Future<UserEntitlement> getEntitlement();
}

/// In-memory mock implementation of [EntitlementRepository].
class MockEntitlementRepository implements EntitlementRepository {
  final UserEntitlement currentEntitlement;

  const MockEntitlementRepository({
    this.currentEntitlement = UserEntitlement.freeTier,
  });

  @override
  Future<UserEntitlement> getEntitlement() async {
    return currentEntitlement;
  }
}
