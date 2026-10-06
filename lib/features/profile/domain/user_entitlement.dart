import 'package:equatable/equatable.dart';

/// Available subscription / feature entitlement tiers.
enum EntitlementTier { free, premium }

/// Models user entitlement status and feature capabilities.
/// Strictly decoupled from payment processing or billing SDKs per Section 9.
class UserEntitlement extends Equatable {
  final EntitlementTier tier;
  final bool hasUnlimitedAiSearch;
  final bool hasLosslessRawExport;
  final bool hasSemanticClustering;
  final String statusDescription;

  const UserEntitlement({
    required this.tier,
    this.hasUnlimitedAiSearch = false,
    this.hasLosslessRawExport = false,
    this.hasSemanticClustering = false,
    this.statusDescription = 'Free Plan',
  });

  bool get isPremium => tier == EntitlementTier.premium;

  static const UserEntitlement freeTier = UserEntitlement(
    tier: EntitlementTier.free,
    hasUnlimitedAiSearch: false,
    hasLosslessRawExport: false,
    hasSemanticClustering: false,
    statusDescription: 'Free Plan',
  );

  static const UserEntitlement premiumTier = UserEntitlement(
    tier: EntitlementTier.premium,
    hasUnlimitedAiSearch: true,
    hasLosslessRawExport: true,
    hasSemanticClustering: true,
    statusDescription: 'Pro Member',
  );

  @override
  List<Object?> get props => [
    tier,
    hasUnlimitedAiSearch,
    hasLosslessRawExport,
    hasSemanticClustering,
    statusDescription,
  ];
}
