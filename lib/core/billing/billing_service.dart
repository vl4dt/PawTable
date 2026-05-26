import 'package:flutter_riverpod/flutter_riverpod.dart';

/// RevenueCat abstraction for subscription management
///
/// Plans:
/// - Free: $0
/// - Monthly: $6.99/mo (offerId: monthly)
/// - Annual: $49.99/yr (offerId: annual — default)
/// - Family Monthly: $9.99/mo (offerId: family-monthly)
/// - Family Annual: $79.99/yr (offerId: family-annual)
class BillingService {
  final Ref ref;

  BillingService(this.ref);

  /// Check if user has active premium subscription
  Future<bool> hasPremium() async {
    // TODO: Integrate RevenueCat
    // return await Purchases.getCustomerInfo().user.isPremium;
    return false;
  }

  /// Check if user has active family subscription
  Future<bool> hasFamily() async {
    // TODO: Integrate RevenueCat
    return false;
  }

  /// Purchase a subscription
  Future<void> purchase({
    required String planId,
    bool isFamily = false,
  }) async {
    // TODO: Integrate RevenueCat purchase flow
    // final info = await Purchases.purchasePremium(...);
  }

  /// Restore previous purchases
  Future<void> restore() async {
    // TODO: Integrate RevenueCat restore
    // await Purchases.restorePurchases();
  }

  /// Check freemium limits
  bool canAddPet({int currentPetCount = 0, bool isPremium = false}) {
    if (isPremium) return true;
    return currentPetCount < 1; // Free: 1 pet
  }

  bool hasFamilyMemberLimit({int memberCount = 0, bool isFamily = false}) {
    if (isFamily) return true;
    return memberCount < 2; // Free: 2 members
  }

  /// Get current plan info
  Future<Map<String, dynamic>> getPlanInfo() async {
    // TODO: Integrate RevenueCat to fetch current plan
    return {
      'isPremium': false,
      'isFamily': false,
      'planId': null,
      'expiresAt': null,
    };
  }
}

final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(ref);
});
